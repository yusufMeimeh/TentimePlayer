//
//  Player.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 11/09/2023.
//

import AVFoundation
import CoreGraphics
import AVKit
import Combine
import GoogleInteractiveMediaAds

public enum PipModeStatus: Int {
    case start = 1
    case end = 2
    case restoreUserInterface  = 3
    case stop = 4
}

open class TenTimePlayer: NSObject, ObservableObject {

    // Create a shared instance as a singleton
    public static let shared = TenTimePlayer()

    internal var player: AVPlayer = AVPlayer(playerItem: nil)

    internal var playerLayer: AVPlayerLayer?

    var playerItem: AVPlayerItem?

    var playerData : PlayerData?

    @Published public var isCurrentlyPlaying: Bool = true

    @Published public var playbackStatus: PlaybackStatus = .play

    var queueItem: [PlayerData] = []

    var currentQueueIndex = -1

    @Published public var isLoading: Bool = false

    @Published public var mediaPrepared: Bool = false

    @Published public var isPipModeEnabled: Bool = false

    @Published public var shouldShowUpNextContent: Bool = false

    @Published public var shouldHideUpNextContent: Bool = false

    @Published public var didFinishPlaying: Bool = false

    @Published public var pipModeStatus: PipModeStatus?

    @Published public var isMuted: Bool = false

    @Published public var timeObservation: TimeObservation = TimeObservation()

    var remainingTime: Double = 0

    var isLoadingVideo: Bool = true

    var isPipModeStarted: Bool {
        return pipModeManager.isPipModeStarted
    }
    //Ads varibales
    var contentPlayhead: IMAAVPlayerContentPlayhead?

    let adTagURLString = "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator="

    var adsLoader: IMAAdsLoader!

    var adsManager: IMAAdsManager!

    var isAdPlayback = false

    //up next content
    var isCanceledUpNextContent: Bool? = nil

    public var showUpNextBefore: Double = 30

    public var showUpNextContent: Bool = false

    var currentIndex = 0

    internal var drmManager: DRMManager
    internal var playbackManager: PlaybackManaging
    internal var loaderManager: LoadManaging
    internal var notificationCenterManager: NotificationCenterManaging
    internal var seekManager: SeekManaging
    internal var pipModeManager: PipModeManager
    var cancallable = Set<AnyCancellable>()
    internal var playerItemManager: PlayerItemManager?
    internal var timeObserverManager: TimeObserverManaging

    override init() {
        self.drmManager = DRMManager()
        self.playbackManager = PlaybackManager(player: player)
        self.loaderManager = LoadManager(player: player)
        self.notificationCenterManager = NotificationCenterManager()
        self.seekManager = SeekManager(player: player)
        self.timeObserverManager = TimeObservationManager(player: player)
        self.pipModeManager = PipModeManager()

        super.init()
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player)
        handleSessionStart()
        setUpAdsLoader()
        notificationCenterManager.delegate = self
    }

    func handleSessionStart() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: .moviePlayback)
            try audioSession.setActive(true)
        } catch {
            print("Audio session failed")
        }
    }

    private func observerPipStatus(){
        bind(pipModeManager.$pipModeStatus,
             to: handlePipMode,
             storeIn: &cancallable)
    }

    func observeRquiredItem() {
        self.observePlayCurrentTime()
        setupNotificationObservers()
    }

    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }

    func removeNotificationObservers() {

        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }

    private func handlePipMode(_ status: PipModeStatus?) {
        self.pipModeStatus = pipModeManager.pipModeStatus
        switch status {
        case .start:
            ()
        case .end:
            endPlayer()
        case .restoreUserInterface:
            isCurrentlyPlaying = player.rate != 0
            if isCurrentlyPlaying {
                playbackManager.play()
            } else {
                playbackManager.pause()
            }
        case .stop:
            ()
        case nil:
            ()
        }
    }

    func handleNotificationCenter(supporterdCommand: [NowPlayableCommand] ) {
        notificationCenterManager.setupCommands(supportedCommand: supporterdCommand)
    }

    @objc func playerDidFinishPlaying(_ noti: Notification) {
        guard mediaPrepared else {return}
        if let p = noti.object as? AVPlayerItem,
           p == player.currentItem {
            // Check if the player has reached the end
            let duration = p.duration.seconds
            let currentTime = player.currentTime().seconds
            let tolerance: Double = 0.05  // 50 milliseconds toleranc
            if abs(currentTime - duration) <= tolerance {
                playbackManager.pause()
                if !didFinishPlaying {
                    didFinishPlaying = true
                }
            }
        }
    }

    fileprivate func updateNotificationCenterData(_ cTime: Float64, _ playerItem: AVPlayerItem) {
        notificationCenterManager.nowPlayableDynamicMetadata = NowPlayableDynamicMetadata(
            rate: player.rate,
            position: cTime,
            duration: Float(playerItem.duration.seconds),
            currentLanguageOptions: [],
            availableLanguageOptionGroups: [],
            isLiveStream: false)
    }

    func observePlayCurrentTime() {
        timeObserverManager.startObserving(interval: CMTimeMake(value: 1, timescale: 2))
        timeObserverManager.onTimeUpdate = {[weak self] timeObservation in
            self?.timeObservation = timeObservation
        }
    }

    func getPlayer() -> AVPlayer {
        return player
    }

    private func cleanUpObservers() {
        //remove player periodic observer
        timeObserverManager.stopObserving()
    }

    public func endPlayer() {
        mediaPrepared = false
        playbackManager.pause()

        notificationCenterManager.removeNotificationCenter()
        removeNotificationObservers()
        cleanUpObservers()

        playerLayer?.removeFromSuperlayer()
        player.replaceCurrentItem(with: nil)
        playerItemManager = nil
        print("end player step")
    }

    internal func handleProgresSeeking(finished: Bool) {
        if finished, let supposedCurrentTime = seekManager.supposedCurrentTime {
            updatePlayerState(for: supposedCurrentTime)
            //reset player to it's init state
            if playbackManager.playbackStatus == .forceStop {
                player.play()
            }
        }
    }

    public func configureDRM(drmProxy: String, licenseURL: String) {
        drmManager.configureDRM(drmProxy: drmProxy, licenseURL: licenseURL)
    }

    func updatePlayerState(for time: CMTime) {
        guard let playerItem = player.currentItem
        else { return }

        self.timeObservation = timeObserverManager.calculateTimeObservation(for: time)
        updateNotificationCenterData(time.seconds, playerItem)
    }

    internal func resetPlayerItemValues() {
        didFinishPlaying = false
        pipModeStatus = nil
        isCanceledUpNextContent = nil
    }

    deinit {
        cleanUpObservers()
    }

}
