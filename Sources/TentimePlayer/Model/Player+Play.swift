//
//  Player+Play.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 18/09/2023.
//

import Foundation


extension TenTimePlayer {
    
    func play() {
        isCurrentlyPlaying = true
        player?.play()
        isPlay = true
    }
    
    func pause() {
        isCurrentlyPlaying = false
        player?.pause()
        isPlay = false
    }
    
    func togglePlayerPause() {
        if isCurrentlyPlaying {
            pause()
        }else {
            play()
        }
    }
}
