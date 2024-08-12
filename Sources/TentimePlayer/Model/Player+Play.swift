//
//  Player+Play.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 18/09/2023.
//

import Foundation


extension TenTimePlayer {
    
    public func play() {
        isCurrentlyPlaying = true
        player?.play()
        isPlay = true
    }
    
    public func pause() {
        isCurrentlyPlaying = false
        player?.pause()
        isPlay = false
    }
    
    public  func togglePlayerPause() {
        if isCurrentlyPlaying {
            pause()
        }else {
            play()
        }
    }
}
