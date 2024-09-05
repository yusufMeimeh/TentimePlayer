//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 12/08/2024.
//

import AVKit
protocol PlaybackManaging {
    var playbackStatus: PlaybackStatus {get set}
    func play()
    func pause()
    func togglePlayPause()
    func seek(to time: CMTime)
    func skipForward(by seconds: Double)
    func skipBackward(by seconds: Double)
    func mute()
    func unmute()
    func forceStop()
}
public enum PlaybackStatus {
    case play
    case pause
    case forceStop
}
class PlaybackManager: PlaybackManaging {
//    var isCurrentlyPlaying: Bool = false
    var playbackStatus: PlaybackStatus = .play
    let player: AVPlayer

    init(player: AVPlayer) {
        self.player = player
    }

    public func play() {
        player.play()
        playbackStatus = .play
//        isCurrentlyPlaying = true
    }

    public func pause() {
        player.pause()
        playbackStatus = .pause
//        isCurrentlyPlaying = false
    }

    public func togglePlayPause() {
        if playbackStatus == .play {
            pause()
        } else {
            play()
        }
    }

    func seek(to time: CMTime) {

    }

    func skipForward(by seconds: Double) {

    }

    func skipBackward(by seconds: Double) {

    }

    func mute() {
        player.isMuted = true
    }

    func unmute() {
        player.isMuted = false
    }


    func forceStop() {
        playbackStatus = .forceStop
        player.pause()
    }

}
