//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 12/08/2024.
//

import AVKit
protocol PlaybackManaging {
    var isCurrentlyPlaying: Bool {get set}
    func play()
    func pause()
    func togglePlayPause()
    func seek(to time: CMTime)
    func skipForward(by seconds: Double)
    func skipBackward(by seconds: Double)
    func mute()
    func unmute()
}

class PlaybackManager: PlaybackManaging {
    var isCurrentlyPlaying: Bool = false

    let player: AVPlayer

    init(player: AVPlayer) {
        self.player = player
    }

    public func play() {
        player.play()
        isCurrentlyPlaying = true
    }

    public func pause() {
        player.pause()
        isCurrentlyPlaying = false
    }

    public func togglePlayPause() {
        if isCurrentlyPlaying {
            pause()
        }else {
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
}
