//
//  Player+NotificationCenterManagerDelegate.swift
//  
//
//  Created by Qamar Al Amassi on 25/09/2024.
//

import AVFoundation

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
