//
//  Player+Seeking.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 18/09/2023.
//

import AVFoundation


extension TenTimePlayer {
    func seekToCurrentTime(delta: Int64) {
        
        guard let currentTime = supposedCurrentTime else {
            return
        }
        
        let secondsToSeek = CMTimeMake(value: delta, timescale: 1)
        let newTime = CMTimeAdd(currentTime, secondsToSeek)
        
        // If the new time is negative or zero, seek to the beginning
          guard newTime.seconds > 0 else {
              seekToBeginning()
              return
          }
        
        // Calculate the duration and new current time
            if let duration = player?.currentItem?.duration, duration.seconds - currentTime.seconds <= 10 {
                seekToEnd()
            } else {
                seekToNewTime(delta: delta, newTime)
            }
        
        // Delay resetting isSeeking flag to avoid immediate changes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.isSeeking = false
            }
        
    }

    private func seekToBeginning() {
        didUpdateTime = ("00:00",
                      player?.currentItem?.duration.toDisplayString() ?? "00:00",
                      0,
                      durationTimeSeconds: player?.currentItem?.duration.seconds ?? 0.0)
         player?.seek(second: 0)
    }

    private func seekToEnd() {
        if let duration = player?.currentItem?.duration {
            let newCurrent = duration.seconds
            player?.seek(second: newCurrent)
            didUpdateTime = (currentTime?.toDisplayString() ?? "",
                             duration.toDisplayString(),
                             newCurrent,
                             duration.seconds
               )
            didFinishPlaying = true
        }
    }

    private func seekToNewTime(delta: Int64, _ newTime: CMTime) {
        guard let currentTime = currentTime else {return}
        player?.seek(by: delta, currentTime: currentTime)
        didUpdateTime = (currentTime.toDisplayString(),
                         player?.currentItem?.duration.toDisplayString() ?? "00:00",
                         currentTime.seconds,
                         self.player?.currentItem?.duration.seconds ?? 0.0)
    }
    
    
    func seek(percent: Float64) async {
        guard let player = player else {
            return
        }
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        
        if #available(iOS 15, *) {
            if let playerTimescale = try? await player.currentItem?.asset.load(.duration) {
                let value = percent * durationSeconds
                // Extract the CMTimeScale from playerTimescale
                let timeScale = playerTimescale.timescale
                let time =  CMTime(seconds: value, preferredTimescale: timeScale)
                await player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
                supposedCurrentTime = time
                if let supposedCurrentTime = supposedCurrentTime {
                    didUpdateTime = (supposedCurrentTime.toDisplayString(),
                                     self.player?.currentItem?.duration.toDisplayString() ?? "00:00",
                                     supposedCurrentTime.seconds,
                                     self.player?.currentItem?.duration.seconds ?? 0.0)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.isSeeking = false
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func getCurrentSeekingSecond() -> TimeInterval? {
        guard let time = currentTime else {return nil}
        return CMTimeGetSeconds(time)
    }
}
