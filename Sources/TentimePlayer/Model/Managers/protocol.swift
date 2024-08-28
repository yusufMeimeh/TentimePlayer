//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 12/08/2024.
//

import AVKit
import GoogleInteractiveMediaAds

protocol AssetManager {
    func loadAsset(name: String, url: URL, isOfflinePlayback: Bool, with keys: inout [String], completion: @escaping (Result<AVURLAsset, Error>) -> Void)
}

protocol LoadManaging {
    func loadMedia(from playerData: PlayerData,
                   completion: (@escaping  (Result<PlayerItemManager?,Error>) -> Void))
}

protocol NotificationCenterManaging {
    var nowPlayableDynamicMetadata: NowPlayableDynamicMetadata? {get set}
    var nowPlayableStaticMetadata: NowPlayableStaticMetadata? {get set}
    func updateNowPlayableDynamicMetadata(isCurrentlyPlaying: Bool) 
    func setupCommands(supportedCommand: [NowPlayableCommand])
    func removeNotificationCenter()
    var delegate: NotificationCenterManagerDelegate? {get set}
}

protocol SeekManaging {
    var supposedCurrentTime: CMTime? {get set}
    var isSeeking: Bool {get set}
    func seekToCurrentTime(delta: Int64)
    func seek(to percent: Float64, completion: @escaping ((Bool) -> Void))
    func getCurrentSeekingSecond() -> TimeInterval?
    func seekToEnd()
    func seekToBeginning()
}

protocol PipModeManaging: AnyObject {
    var isPipModeEnabled: Bool { get set }
    var isPipModeStarted: Bool { get set }
    var pipModeStatus: PipModeStatus? { get set }
    var pipCompletionHandler: ((Bool) -> Void)? { get set }

    func configurePipMode(for player: AVPlayer, withProxy proxy: IMAPictureInPictureProxy?)
    func startPipMode()
    func cleanUpObserver()
}
