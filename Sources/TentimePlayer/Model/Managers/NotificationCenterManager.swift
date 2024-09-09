//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 12/08/2024.
//

import AVFoundation
import MediaPlayer

protocol NotificationCenterManagerDelegate: AnyObject {
    func playFromNotificationCenter()
    func pauseFromNotificationCenter()
    func skipForwardFromNotificationCenter()
    func skipBackwardFromNotificationCenter()
    func seekFromNotificationCenter(to time: CMTime)
}

class NotificationCenterManager: NotificationCenterManaging {
    var nowPlayable: NowPlayable? = TenTimeNowPlayable()

    var supportedCommand: [NowPlayableCommand]  = []

    var nowPlayableDynamicMetadata: NowPlayableDynamicMetadata?

    var nowPlayableStaticMetadata: NowPlayableStaticMetadata? {
        didSet {
            nowPlayable?.handleNowPlayableItemChange(metadata: nowPlayableStaticMetadata)
        }
    }

    weak var delegate: NotificationCenterManagerDelegate?

    func updateNowPlayableDynamicMetadata(isCurrentlyPlaying: Bool) {
        nowPlayable?.handleNowPlayablePlaybackChange(
            playing: isCurrentlyPlaying,
            metadata: nowPlayableDynamicMetadata)
    }

    func reinstallCommandsMetadeta(playerData: PlayerData) {
        addNotificationCenterCommands()
        updatePlayableStaticMetdata(playerData)
    }

    fileprivate func addNotificationCenterCommands() {
        nowPlayable?.handleNowPlayableConfiguration(commands: supportedCommand, disabledCommands: []) {[weak self] command, event in
            guard let self = self else {return .commandFailed}
            switch command {
            case .play:
                delegate?.playFromNotificationCenter()
//                self.play()
//                self.delegate?.didPlayFromRemoteControl()
            case .pause:
                delegate?.pauseFromNotificationCenter()
//                self.pause()
//                self.delegate?.didPauseFromRemoteControl()
            case .skipForward:
                delegate?.skipForwardFromNotificationCenter()

//                DispatchQueue.main.async {
//                    self.seekToCurrentTime(delta: 10)
//                }
            case .skipBackward:
                delegate?.skipBackwardFromNotificationCenter()
//                DispatchQueue.main.async {
//                    self.seekToCurrentTime(delta: -10)
//                }
            case .changePlaybackPosition:
                guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
                let time = CMTime(seconds: event.positionTime, preferredTimescale: 1)
                delegate?.seekFromNotificationCenter(to: time)
            default:
                ()
            }
            return .success
        }
    }

    public func setupCommands(supportedCommand: [NowPlayableCommand]) {
        self.supportedCommand = supportedCommand
        addNotificationCenterCommands()
    }

    public func updatePlayableStaticMetdata(_ playerData: PlayerData) {
        setupCommands(supportedCommand: self.supportedCommand   )
        nowPlayableStaticMetadata = NowPlayableStaticMetadata(
            assetURL: playerData.moviePath,
            mediaType: .video,
            isLiveStream: false,
            title: playerData.movieName ?? "",
            artist: nil,
            artwork: playerData.thumbImage,
            albumArtist: nil,
            albumTitle: nil)
    }

    func removeNotificationCenter() {
        nowPlayable?.removeNotificationCenter(commands: supportedCommand )
    }

}
