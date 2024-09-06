//
//  TenTimeNowPlayable.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 18/09/2023.
//

import Foundation
import MediaPlayer

class TenTimeNowPlayable: NowPlayable {
    func handleNowPlayableConfiguration(commands: [NowPlayableCommand], disabledCommands: [NowPlayableCommand], commandHandler: @escaping (NowPlayableCommand, MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus)  {
        configureRemoteCommands(commands, disabledCommands: disabledCommands, commandHandler: commandHandler)
    }
    
    func handleNowPlayableItemChange(metadata: NowPlayableStaticMetadata?) {
        setNowPlayingMetadata(metadata)
    }
    
    func handleNowPlayablePlaybackChange(playing: Bool, metadata: NowPlayableDynamicMetadata?) {
        setNowPlayingPlaybackInfo(metadata)
    }
    
    
    func removeNotificationCenter(commands: [NowPlayableCommand]) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
        commands.forEach { command in
            command.removeHandler()
        }
    }
}
