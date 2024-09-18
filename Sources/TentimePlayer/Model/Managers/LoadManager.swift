//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 12/08/2024.
//

import AVKit

class LoadManager: LoadManaging {
    let player: AVPlayer

    init(player: AVPlayer) {
        self.player = player
    }

    public func loadMedia(from playerData: PlayerData,
                           completion: (@escaping  (Result<PlayerItemManager?, Error>) -> Void)) {
        player.automaticallyWaitsToMinimizeStalling = false
//        isCurrentlyPlaying = autoPlay
        guard let url = URL(string: playerData.moviePath) else {return}

        let playerAssetManager = ManagerFactory.createAssetLoadManager()

        var keys: [String] = []
        playerAssetManager.loadAsset(
            name: playerData.movieName ?? "",
            url: url,
            isOfflinePlayback: false,
            with: &keys) { result  in
            switch result {
            case .failure(let error):
                print("Error loading media ", error)
                completion(.failure(error))
            case .success(let assets):
                let playerItem = PlayerItemManager()
                let avplayerItem = playerItem.setupPlayerItem(with: assets)
                self.player.replaceCurrentItem(with: avplayerItem)
                playerItem.observableAttributes = [.status,.isPlaybackBufferEmpty,.isPlaybackBufferFull,.isPlaybackLikelyToKeepUp, .track]
                playerItem.delegate = self
                completion(.success(playerItem))
            }
        }
    }

//    public func loadListOfMedia(from players: [PlayerData], autoPlay: Bool = true) {
//        player.automaticallyWaitsToMinimizeStalling = false
//        guard let playerData = players.first,
//              let url = URL(string:playerData.moviePath) else {return}
//        isCurrentlyPlaying = autoPlay
//        currentQueueIndex = 0
//        queueItem = players
//
//        playerItem = AVPlayerItem(url: url)
////        playerItem?.delegate = self
//        player?.replaceCurrentItem(with: playerItem)
//        player?.seek(second: playerData.elapsedTime)
//        isCurrentlyPlaying ? player?.play() :  player?.pause()
//        self.playerData = playerData
//        resetPlayerItemValues()
//        updatePlayableStaticMetdata(playerData)
//    }

//   
}
