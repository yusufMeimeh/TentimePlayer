//
//  Player+PlayerItemDelegate.swift
//
//
//  Created by Qamar Al Amassi on 25/09/2024.
//

import AVFoundation

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
