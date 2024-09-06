//
//  NowPlayable.swift
//  TenTime
//
//  Created by Jean-Pierre Kayle on 12/11/2021.
//  Copyright © 2021 TenTime. All rights reserved.
//

import Foundation
import MediaPlayer
import Kingfisher


protocol NowPlayable {
    func handleNowPlayableItemChange(metadata: NowPlayableStaticMetadata?)
    func handleNowPlayablePlaybackChange(playing: Bool, metadata: NowPlayableDynamicMetadata?)
    func handleNowPlayableConfiguration(commands: [NowPlayableCommand],
                                        disabledCommands: [NowPlayableCommand],
                                        commandHandler: @escaping (NowPlayableCommand, MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus)
    func removeNotificationCenter(commands: [NowPlayableCommand])
}


extension NowPlayable {
    // Install handlers for registered commands, and disable commands as necessary.
    func configureRemoteCommands(_ commands: [NowPlayableCommand],
                                 disabledCommands: [NowPlayableCommand],
                                 commandHandler: @escaping (NowPlayableCommand, MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus) {

        // Check that at least one command is being handled.
        guard commands.count > 1 else { return }
        // Configure each command.
        for command in NowPlayableCommand.allCases {
            // Remove any existing handler.
            command.removeHandler()
            // Add a handler if necessary.
            if commands.contains(command) {
                command.addHandler(commandHandler)
            }
            // Disable the command if necessary.
            command.setDisabled(disabledCommands.contains(command))
        }
    }
    
    func setNowPlayingMetadata(_ metadata: NowPlayableStaticMetadata?) {
        guard  let metadata = metadata else { return }
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()
        
        
        if let assetURL = metadata.assetURL {
            nowPlayingInfo[MPNowPlayingInfoPropertyAssetURL] = URL(string: assetURL)
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = metadata.mediaType.rawValue
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = metadata.isLiveStream
        nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = metadata.artist
        nowPlayingInfo[MPMediaItemPropertyAlbumArtist] = metadata.albumArtist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = metadata.albumTitle
        
        getArtwork(thumb: metadata.artwork ?? "") { image in
            
            if let image = image {
                let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: {  (_) -> UIImage in
                  return image
                })
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            }
            nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        }
    }
    
    // Set playback info. Implementations of `handleNowPlayablePlaybackChange(playing:rate:position:duration:)`
    // will typically invoke this method.
    func setNowPlayingPlaybackInfo(_ metadata: NowPlayableDynamicMetadata?) {
        guard  let metadata = metadata else { return }
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = metadata.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = metadata.position
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = metadata.rate
//        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
        nowPlayingInfo[MPNowPlayingInfoPropertyCurrentLanguageOptions] = metadata.currentLanguageOptions
        nowPlayingInfo[MPNowPlayingInfoPropertyAvailableLanguageOptions] = metadata.availableLanguageOptionGroups
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = metadata.isLiveStream
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    private func getArtwork(thumb:String,_ handler: @escaping (UIImage?) -> Void) {
        
        guard let url = URL(string: thumb) else {
            handler(UIImage(named:"icDefaultSquare"))
            return
        }
        let resource = KF.ImageResource(downloadURL: url)
        
        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
            switch result {
            case .success(let value):
                handler(value.image)
            case .failure( _):
                handler(UIImage(named:"icDefaultSquare"))
            }
        }
    }
}


