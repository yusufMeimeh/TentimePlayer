//
//  NowPlayableCommand.swift
//  TenTime
//
//  Created by Jean-Pierre Kayle on 12/11/2021.
//  Copyright © 2021 TenTime. All rights reserved.
//

import Foundation
import MediaPlayer

public enum NowPlayableCommand: CaseIterable {

    case pause, play, stop, togglePausePlay
    case nextTrack, previousTrack, changeRepeatMode, changeShuffleMode
    case changePlaybackRate, seekBackward, seekForward, skipBackward, skipForward, changePlaybackPosition
    case rating, like, dislike
    case bookmark
    case enableLanguageOption, disableLanguageOption
    
    var remoteCommand: MPRemoteCommand {
        let remoteCommandCenter = MPRemoteCommandCenter.shared()
        switch self {
        case .pause:
            return remoteCommandCenter.pauseCommand
        case .play:
            return remoteCommandCenter.playCommand
        case .stop:
            return remoteCommandCenter.stopCommand
        case .togglePausePlay:
            return remoteCommandCenter.togglePlayPauseCommand
        case .nextTrack:
            return remoteCommandCenter.nextTrackCommand
        case .previousTrack:
            return remoteCommandCenter.previousTrackCommand
        case .changeRepeatMode:
            return remoteCommandCenter.changeRepeatModeCommand
        case .changeShuffleMode:
            return remoteCommandCenter.changeShuffleModeCommand
        case .changePlaybackRate:
            return remoteCommandCenter.changePlaybackRateCommand
        case .seekBackward:
            return remoteCommandCenter.seekBackwardCommand
        case .seekForward:
            return remoteCommandCenter.seekForwardCommand
        case .skipBackward:
            return remoteCommandCenter.skipBackwardCommand
        case .skipForward:
            return remoteCommandCenter.skipForwardCommand
        case .changePlaybackPosition:
            return remoteCommandCenter.changePlaybackPositionCommand
        case .rating:
            return remoteCommandCenter.ratingCommand
        case .like:
            return remoteCommandCenter.likeCommand
        case .dislike:
            return remoteCommandCenter.dislikeCommand
        case .bookmark:
            return remoteCommandCenter.bookmarkCommand
        case .enableLanguageOption:
            return remoteCommandCenter.enableLanguageOptionCommand
        case .disableLanguageOption:
            return remoteCommandCenter.disableLanguageOptionCommand
        }
    }
    
    // Remove all handlers associated with this command.
    
    func removeHandler() {
        remoteCommand.removeTarget(nil)
    }
    
    // Install a handler for this command.
    
    func addHandler(_ handler: @escaping (NowPlayableCommand, MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus) {
        
        switch self {
        case .changePlaybackRate:
            MPRemoteCommandCenter.shared().changePlaybackRateCommand.supportedPlaybackRates = [2,1.5,1,0.75,0.5]
            
        case .skipBackward:
            MPRemoteCommandCenter.shared().skipBackwardCommand.preferredIntervals = [10.0]
            
        case .skipForward:
            MPRemoteCommandCenter.shared().skipForwardCommand.preferredIntervals = [10.0]
            
        default:
            break
        }

        remoteCommand.addTarget { handler(self, $0) }
    }
    
    // Disable this command.
    
    func setDisabled(_ isDisabled: Bool) {
        remoteCommand.isEnabled = !isDisabled
    }
    
}

struct ConfigCommand {
    
    // The command described by this configuration.
    
    let command: NowPlayableCommand
    
    // A displayable name for this configuration's command.
    
    let commandName: String
    
    // 'true' to register a handler for the corresponding MPRemoteCommandCenter command.
    
    var shouldRegister: Bool
    
    // 'true' to disable the corresponding MPRemoteCommandCenter command.
    
    var shouldDisable: Bool
    
    // Initialize a command configuration.
    
    init(_ command: NowPlayableCommand, _ commandName: String) {
        self.command = command
        self.commandName = commandName
        self.shouldDisable = false
        self.shouldRegister = false
    }
}


