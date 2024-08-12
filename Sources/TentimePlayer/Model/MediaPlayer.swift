//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 08/07/2024.
//

import Foundation
 

protocol MediaPlayer {
    var items: [PlayerData] {get set}
    var currentQueueIndex: Int { get set }
    var playbackStrategy: PlaybackStrategy { get set }
    
    init(items: [PlayerData], strategy: PlaybackStrategy)
    func playNext()
    func playPrevious()
    func setPlaybackStrategy(_ strategy: PlaybackStrategy)
}

 class VideoMediaPlayer: MediaPlayer {
    var items: [PlayerData]
    
    var currentQueueIndex: Int = 0
    
    var playbackStrategy: any PlaybackStrategy
    
    required init(items: [PlayerData], strategy: any PlaybackStrategy) {
        self.items = items
        self.playbackStrategy = strategy
    }
    
    func playNext() {
        currentQueueIndex = playbackStrategy.nextIndex(currentIndex: currentQueueIndex, totalItems: items.count) ?? 0
        
    }
    
    func playPrevious() {
        currentQueueIndex = playbackStrategy.prevIndex(currentIndex: currentQueueIndex, totalItems: items.count) ?? 0
    }
    
    func setPlaybackStrategy(_ strategy: any PlaybackStrategy) {
        self.playbackStrategy = strategy
    }
    
}


class MusicMediaPlayer: MediaPlayer {
    var items: [PlayerData]
    
    var currentQueueIndex: Int = 0
    
    var playbackStrategy: any PlaybackStrategy
    
    required init(items: [PlayerData], strategy: any PlaybackStrategy) {
        self.items = items
        self.playbackStrategy = strategy
    }
    
    func playNext() {
        currentQueueIndex = playbackStrategy.nextIndex(currentIndex: currentQueueIndex, totalItems: items.count) ?? 0
    
    }
    
    func playPrevious() {
        currentQueueIndex = playbackStrategy.prevIndex(currentIndex: currentQueueIndex, totalItems: items.count) ?? 0
    }
    
    func setPlaybackStrategy(_ strategy: any PlaybackStrategy) {
        self.playbackStrategy = strategy
    }
}
