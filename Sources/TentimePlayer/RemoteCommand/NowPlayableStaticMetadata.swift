//
//  NowPlayableStaticMetadata.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 18/09/2023.
//

import Foundation
import MediaPlayer

struct NowPlayableStaticMetadata {
    let assetURL: String?                   // MPNowPlayingInfoPropertyAssetURL
    let mediaType: MPNowPlayingInfoMediaType
    // MPNowPlayingInfoPropertyMediaType
    let isLiveStream: Bool              // MPNowPlayingInfoPropertyIsLiveStream
    
    let title: String                   // MPMediaItemPropertyTitle
    let artist: String?                 // MPMediaItemPropertyArtist
    let artwork: String?                // MPMediaItemPropertyArtwork
    
    let albumArtist: String?            // MPMediaItemPropertyAlbumArtist
    let albumTitle: String?             // MPMediaItemPropertyAlbumTitle
}
