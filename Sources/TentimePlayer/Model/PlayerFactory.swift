//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 08/07/2024.
//

import Foundation


protocol MediaPlayerFactory {
    static func createPlayer(items: [PlayerData], playbackStrategy: any PlaybackStrategy) -> MediaPlayer
}


public class VideoMediaPlayerFactory: MediaPlayerFactory {
    static func createPlayer(items: [PlayerData], playbackStrategy: any PlaybackStrategy) -> any MediaPlayer {
        let videMediaPlayer = VideoMediaPlayer(items: items, strategy: playbackStrategy)
        return videMediaPlayer
    }
}


public class MusicMediaPlayerFactory: MediaPlayerFactory {
    static func createPlayer(items: [PlayerData], playbackStrategy: any PlaybackStrategy) -> any MediaPlayer {
        let musicMediaPlayer = MusicMediaPlayer(items: items, strategy: playbackStrategy)
        return musicMediaPlayer
    }
}
