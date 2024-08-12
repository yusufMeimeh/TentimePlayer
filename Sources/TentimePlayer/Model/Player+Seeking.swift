//
//  Player+Seeking.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 18/09/2023.
//

import AVFoundation


extension TenTimePlayer {
    public func seekToCurrentTime(delta: Int64) {
        self.isSeeking = true
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
        self.progressValue = 0.0

        self.currentTimeFormatted = "00:00"
        self.durationTimeFormatted =   self.player?.currentItem?.duration.toDisplayString() ?? "00:00"
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

            self.currentTimeFormatted = currentTime?.toDisplayString() ?? ""
            self.durationTimeFormatted =  duration.toDisplayString()
            let duration = Float(  self.player?.currentItem?.duration.seconds ?? 0.0)

            self.progressValue =  Double((currentTime?.seconds ?? 0) /  Double(duration))

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
        self.currentTimeFormatted = currentTime.toDisplayString()
        self.durationTimeFormatted =   player?.currentItem?.duration.toDisplayString() ?? "00:00"
        let duration = Float(  self.player?.currentItem?.duration.seconds ?? 0.0)

        self.progressValue =  Double((currentTime.seconds) /  Double(duration))

    }
    
    
  
    public func seek(percent: Float64) {
        self.isSeeking = true
        guard let player = player else {
            return
        }
       isPlay ? player.pause() : ()
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        
        let value = percent * durationSeconds
        let time = CMTime(seconds: value, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] finished in
            guard let self = self else { return }
            
            if finished {
                self.supposedCurrentTime = time
                
                DispatchQueue.main.async {
                    if let supposedCurrentTime = self.supposedCurrentTime {
                        self.didUpdateTime = (supposedCurrentTime.toDisplayString(),
                                              self.player?.currentItem?.duration.toDisplayString() ?? "00:00",
                                              supposedCurrentTime.seconds,
                                              self.player?.currentItem?.duration.seconds ?? 0.0)
                        
                        let duration = Float(self.player?.currentItem?.duration.seconds ?? 0.0)
                        self.progressValue = Double((self.supposedCurrentTime?.seconds ?? 0) / Double(duration))
                        
                        self.currentTimeFormatted = supposedCurrentTime.toDisplayString()
                        self.durationTimeFormatted = self.player?.currentItem?.duration.toDisplayString() ?? "00:00"
                    }
                    self.isSeeking = false
                    self.isPlay ? player.play() : ()
                }
             
//                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//                }
            }
        }
    }
    
    func getCurrentSeekingSecond() -> TimeInterval? {
        guard let time = currentTime else {return nil}
        return CMTimeGetSeconds(time)
    }
}
