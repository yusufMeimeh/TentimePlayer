//
//  Player+AudioCaption.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 22/09/2023.
//

import AVFoundation


extension TenTimePlayer {
    func getAvailableAudioTracks() async -> [AVMediaSelectionOption] {
        guard let playerItem = playerItem else {return [] }
        guard let audioTracks = try? await playerItem.asset.loadMediaSelectionGroup(for: .audible)?.options else {return []}
        return audioTracks
    }
    
    func getAvailableSubtitleTracks() async -> [AVMediaSelectionOption] {
        guard let playerItem = playerItem else {return [] }
        guard let subtitleOptions = try? await playerItem.asset.loadMediaSelectionGroup(for: .legible )?.options else {return []}
        return subtitleOptions
    }
    
    func selectAudioOption(for track: AVMediaSelectionOption) async {
        guard let audioTracks = try? await playerItem?.asset.loadMediaSelectionGroup(for: .audible) else {return}
        playerItem?.select(track, in: audioTracks)
    }
    
    func selectSubtitleOption(for track: AVMediaSelectionOption) async {
        guard let subtitleTracks = try? await playerItem?.asset.loadMediaSelectionGroup(for: .legible) else {return}
        playerItem?.select(track, in: subtitleTracks)
    }

    
//    func selectOption(for videoSetting: VideoSetting, index: Int, isOffline: Bool) {
//        switch videoSetting {
//        case .audio:
//            if let audioOptions = audioOptions {
//                playerItem?.ad_select(mediaSelectionOption: audioOptions[index], for: .audible, isOffline: isOffline)
//            }
//        case .subtitle:
//            if let subtitleOptions = subtitleOptions {
//                if let option = subtitleOptions[safe:index] {
//                    playerItem?.ad_select(mediaSelectionOption: option, for: .legible, isOffline: isOffline)
//                }else{
//                    playerItem?.ad_select(mediaSelectionOption: nil, for: .legible, isOffline: isOffline)
//                }
//            }
//        default:
//            ()
//        }
//    }

}
