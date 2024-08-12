//
//  Player+loading.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 18/09/2023.
//

import Foundation
import AVFoundation

extension TenTimePlayer {
    public func loadMedia(from playerData: PlayerData, autoPlay: Bool = true) {
        player?.automaticallyWaitsToMinimizeStalling = false
        isCurrentlyPlaying = autoPlay
        isPlay = autoPlay
        guard let url = URL(string: playerData.moviePath) else {return}
        
        let keyHandler = prepateKeyHandler()
        let playerAssetManager = PlayerAssetManager(keyHandler: keyHandler)
        var keys: [String] = []

        playerAssetManager.loadAsset(name: playerData.movieName, url: url, isOfflinePlayback: false, with: &keys) { result  in
            switch result {
            case .failure(let error):
                print("Error loading media ", error)
            case .success(let assets):
                self.playerItem = AVPlayerItem(asset: assets)
        //        playerItem?.delegate = self
                self.player?.replaceCurrentItem(with: self.playerItem)
                self.player?.seek(second: playerData.elapsedTime)
                self.isCurrentlyPlaying ? self.player?.play() :  self.player?.pause()
                self.playerData = playerData
                self.resetPlayerItemValues()
                self.updatePlayableStaticMetdata(playerData)
            }
        }
      

    }
    
    private func prepateKeyHandler() -> AssetKeyHandler {
        
        let keyHandler: AssetKeyHandler
        #if targetEnvironment(simulator)
        keyHandler = SimulatorAssetKeyHandler()
        #else
        keyHandler = DeviceAssetKeyHandler()
        #endif
        return keyHandler
    }
    
    public func loadListOfMedia(from players: [PlayerData], autoPlay: Bool = true) {
        player?.automaticallyWaitsToMinimizeStalling = false
        guard let playerData = players.first,
              let url = URL(string:playerData.moviePath) else {return}
        isCurrentlyPlaying = autoPlay
        currentQueueIndex = 0
        queueItem = players
        isPlay = autoPlay
        playerItem = AVPlayerItem(url: url)
//        playerItem?.delegate = self
        player?.replaceCurrentItem(with: playerItem)
        player?.seek(second: playerData.elapsedTime)
        isCurrentlyPlaying ? player?.play() :  player?.pause()
        self.playerData = playerData
        resetPlayerItemValues()
        updatePlayableStaticMetdata(playerData)
    }
    
    private func resetPlayerItemValues() {
        didFinishPlaying = false
        pipModeStatus = nil
        isCanceledUpNextContent = nil 
    }

   
}

//
//extension TenTimePlayer: CachingPlayerItemDelegate {
//    
//    func playerItemIsLoading() {
//        isLoading = true
//    }
//
//    func playerItemStopLoading() {
//        if isCurrentlyPlaying {
//            player?.play()
//        }else {
//            player?.pause()
//        }
//       isLoading = false
//        
//    }
//    
//    func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {
//        isLoading = false
//        isLoadingVideo = false
//        durationSeconds = playerItem.duration.seconds
//    }
//    
//}
