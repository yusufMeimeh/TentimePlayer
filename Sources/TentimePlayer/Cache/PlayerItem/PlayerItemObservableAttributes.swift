//
//  PlayerItemObservableAttributes.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 20/09/2023.
//

import AVFoundation

enum PlayerItemObservableAttributes: CaseIterable {
    case status, isPlaybackBufferEmpty, isPlaybackLikelyToKeepUp, isPlaybackBufferFull, track
    
    var observableAttribute: String {
        switch self {
        case .status:
            return  #keyPath(AVPlayerItem.status)
        case .isPlaybackBufferEmpty:
            return  #keyPath(AVPlayerItem.isPlaybackBufferEmpty)
        case .isPlaybackLikelyToKeepUp:
            return  #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp)
        case .isPlaybackBufferFull:
            return  #keyPath(AVPlayerItem.isPlaybackBufferFull)
        case .track:
            return  #keyPath(AVPlayerItem.tracks)
        }
    }
    
}
