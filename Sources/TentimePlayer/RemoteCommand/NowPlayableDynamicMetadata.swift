//
//  NowPlayableDynamicMetadata.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 18/09/2023.
//

import Foundation
import MediaPlayer

struct NowPlayableDynamicMetadata {
    
    let rate: Float                     // MPNowPlayingInfoPropertyPlaybackRate
    let position: Float64                 // MPNowPlayingInfoPropertyElapsedPlaybackTime
    let duration: Float                 // MPMediaItemPropertyPlaybackDuration
    
    var currentLanguageOptions: [MPNowPlayingInfoLanguageOption] = []
    // MPNowPlayingInfoPropertyCurrentLanguageOptions
    var availableLanguageOptionGroups: [MPNowPlayingInfoLanguageOptionGroup] = []
    // MPNowPlayingInfoPropertyAvailableLanguageOptions
    let isLiveStream: Bool              // MPNowPlayingInfoPropertyIsLiveStream
}
