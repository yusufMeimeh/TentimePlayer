//
//  Player+loading.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 18/09/2023.
//

import Foundation


extension TenTimePlayer {
    func loadMedia(from playerData: PlayerData, autoPlay: Bool = true) {
        print("Load medi step")
        player?.automaticallyWaitsToMinimizeStalling = false
         guard let url = URL(string: playerData.moviePath) else {return}
        playerItem = CachingPlayerItem(url: url)
        playerItem?.delegate = self
        player?.replaceCurrentItem(with: playerItem)
        player?.seek(second: playerData.elapsedTime)
        player?.play()
        self.playerData = playerData
        resetPlayerItemValues()

        updatePlayableStaticMetdata(playerData)
    }
    
    private func resetPlayerItemValues() {
        didFinishPlaying = false
        pipModeStatus = nil
        isCanceledUpNextContent = false
    }

   
}


extension TenTimePlayer: CachingPlayerItemDelegate {
    
    func playerItemIsLoading() {
        isLoading = true
    }

    func playerItemStopLoading() {
        if isCurrentlyPlaying {
            player?.play()
        }else {
            player?.pause()
        }
       isLoading = false
        
    }
    
    func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {
        isLoading = false
        isLoadingVideo = false
    }
    
}
