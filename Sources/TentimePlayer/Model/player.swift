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

    var isSeeking = false

    var playerData : PlayerData?

    @Published public var isCurrentlyPlaying: Bool = true

    @Published public var playbackStatus: PlaybackStatus = .play

    var supposedCurrentTime: CMTime?

    var timeObserverToken: Any?

    var queueItem: [PlayerData] = []

    var currentQueueIndex = -1

    @Published public var isLoading: Bool = false

    @Published public var mediaPrepared: Bool = false

    @Published public var didUpdateTime: (String, String, Double, Double)?

    @Published public var isPipModeEnabled: Bool = false

    @Published public var shouldShowUpNextContent: Bool = false

    @Published public var shouldHideUpNextContent: Bool = false

    @Published public var didFinishPlaying: Bool = false

    @Published public var pipModeStatus: PipModeStatus?

    @Published public var progressValue: Double = 0.0

    @Published public var durationTimeFormatted: String = ""

    @Published public var durationSeconds: Double = 0.0

    @Published public var currentTimeFormatted: String = ""

    @Published public var isMuted: Bool = false

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

    var currentTime: CMTime?

    var pipCompletionHandler: ((Bool) -> Void)?

    internal var drmManager: DRMManager
    internal var playbackManager: PlaybackManaging
    internal var loaderManager: LoadManaging
    internal var notificationCenterManager: NotificationCenterManaging
    internal var seekManager: SeekManaging
    internal var pipModeManager: PipModeManager
    var cancallable = Set<AnyCancellable>()
    internal var playerItemManager: PlayerItemManager?

    override init() {
        self.drmManager = DRMManager()
        self.playbackManager = PlaybackManager(player: player)
        self.loaderManager = LoadManager(player: player)
        self.notificationCenterManager = NotificationCenterManager()
        self.seekManager = SeekManager(player: player)
        self.pipModeManager = PipModeManager()

        super.init()
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player)

        setUpAdsLoader()
        notificationCenterManager.delegate = self
    }

    private func observerPipStatus(){
        bind(pipModeManager.$pipModeStatus,
             to: handlePipMode,
             storeIn: &cancallable)
    }

    func observeRquiredItem() {
        self.observePlayCurrentTime()

        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
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
        if let p = noti.object as? AVPlayerItem,
            p == player.currentItem {
            playbackManager.pause()
            if !didFinishPlaying {
                didFinishPlaying = true
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
        guard timeObserverToken == nil, !isSeeking else { return }
        let interval = CMTimeMake(value: 1, timescale: 2)

        timeObserverToken =  player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            guard let self =  self else {return}
            didUpdateTime = (time.toDisplayString(),
                             self.player.currentItem?.duration.toDisplayString() ?? "00:00",
                             time.seconds,
                             self.player.currentItem?.duration.seconds ?? 0.0
            )
            guard let playerItem = player.currentItem else {return}

            self.currentTime = time

            let duration = Float(playerItem.duration.seconds)

            self.progressValue = Double((currentTime?.seconds ?? 0) /  Double(duration))

            self.currentTimeFormatted = time.toDisplayString()
            self.durationTimeFormatted =   self.player.currentItem?.duration.toDisplayString() ?? "00:00"

            let cTime = CMTimeGetSeconds(self.player.currentTime())
            updateNotificationCenterData(cTime, playerItem)
            if showUpNextContent {
                handleUpNext(currentTime: currentTime?.seconds ?? 0, duration: Double(duration))
            }
            self.supposedCurrentTime = time
        }
    }

    func getPlayer() -> AVPlayer {
        return player
    }

    private func cleanUpObservers() {
        //remove player periodic observer
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }

    public func endPlayer() {
        cleanUpObservers()
        mediaPrepared = false
        playbackManager.pause()
        notificationCenterManager.removeNotificationCenter()
        playerLayer?.removeFromSuperlayer()
        player.replaceCurrentItem(with: nil)
        playerItemManager = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)

        print("end player step")
        //        player = nil
        //        currentlyPlayingURL = nil
        //        cleanUpObservers()
    }

    internal func handleProgresSeeking(finished: Bool, wasPlay: Bool) {
        if finished, let supposedCurrentTime = seekManager.supposedCurrentTime {
            self.didUpdateTime = (supposedCurrentTime.toDisplayString(),
                                  self.player.currentItem?.duration.toDisplayString() ?? "00:00",
                                  supposedCurrentTime.seconds,
                                  self.player.currentItem?.duration.seconds ?? 0.0)
            let duration = Float(self.player.currentItem?.duration.seconds ?? 0.0)
            self.progressValue = Double((self.supposedCurrentTime?.seconds ?? 0) / Double(duration))

            self.currentTimeFormatted = supposedCurrentTime.toDisplayString()
            self.durationTimeFormatted = self.player.currentItem?.duration.toDisplayString() ?? "00:00"
            if wasPlay{
                self.playbackManager.play()
            }
        }
    }

    internal func handleSeekToEnd() {
        guard let duration = player.currentItem?.duration  else { return}
        self.currentTimeFormatted = currentTime?.toDisplayString() ?? ""
        self.durationTimeFormatted =  duration.toDisplayString()
        self.progressValue = 1
        didFinishPlaying = true
    }
    
    internal func handleSeekToBegin() {
        didUpdateTime = ("00:00",
                         player.currentItem?.duration.toDisplayString() ?? "00:00",
                         0,
                         durationTimeSeconds: player.currentItem?.duration.seconds ?? 0.0)
        self.progressValue = 0.0

        self.currentTimeFormatted = "00:00"
        self.durationTimeFormatted =   self.player.currentItem?.duration.toDisplayString() ?? "00:00"
    }
    public func configureDRM(drmProxy: String, licenseURL: String) {
        drmManager.configureDRM(drmProxy: drmProxy, licenseURL: licenseURL)
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

extension TenTimePlayer: NotificationCenterManagerDelegate {
    func playFromNotificationCenter() {
        playbackManager.play()
    }

    func pauseFromNotificationCenter() {
        playbackManager.pause()
    }

    func skipForwardFromNotificationCenter() {

    }

    func skipBackwardFromNotificationCenter() {

    }

    func seekFromNotificationCenter(to time: CMTime) {

    }
}

extension TenTimePlayer: PlayerItemDelegate {
    func playerItemManager(_ playerItemManager: any PlayerItemManaging, didUpdate isLoad: Bool) {
        print("didUpdate  playerItemManager ", isLoad)
        self.isLoading = isLoad

        if !isLoad  {
            // Fix https://tentime.atlassian.net/browse/TTAB-22159
            if isCurrentlyPlaying  {
                self.play()
            } 
        }
    }
    

}
