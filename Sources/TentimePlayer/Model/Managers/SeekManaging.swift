//
//  File.swift
//
//
//  Created by Qamar Al Amassi on 12/08/2024.
//

import AVFoundation

class SeekManager: SeekManaging {
    var isSeeking: Bool = false
    var supposedCurrentTime: CMTime?
    let player: AVPlayer
    init(supposedCurrentTime: CMTime? = nil, player: AVPlayer) {
        self.supposedCurrentTime = supposedCurrentTime
        self.player = player
    }

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
        if let duration = player.currentItem?.duration, duration.seconds - currentTime.seconds <= 10 {
            seekToEnd()
        } else {
            seekToNewTime(delta: delta, newTime)
        }

        // Delay resetting isSeeking flag to avoid immediate changes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isSeeking = false
        }

    }

    internal func seekToBeginning() {
        player.seek(second: 0)
    }

    internal func seekToEnd() {
        if let duration = player.currentItem?.duration {
            let newCurrent = duration.seconds
            player.seek(second: newCurrent)
        }
    }

    private func seekToNewTime(delta: Int64, _ newTime: CMTime) {
        player.seek(by: delta, currentTime:  player.currentTime())
        //        didUpdateTime = (currentTime.toDisplayString(),
        //                         player.currentItem?.duration.toDisplayString() ?? "00:00",
        //                         currentTime.seconds,
        //                         self.player.currentItem?.duration.seconds ?? 0.0)
        //        self.currentTimeFormatted = currentTime.toDisplayString()
        //        self.durationTimeFormatted =   player.currentItem?.duration.toDisplayString() ?? "00:00"
        //        let duration = Float(  self.player.currentItem?.duration.seconds ?? 0.0)
        //
        //        self.progressValue =  Double((currentTime.seconds) /  Double(duration))
    }

    public func seek(to percent: Float64,
                     completion: @escaping ((Bool) -> Void)) {
        self.isSeeking = true

        //       isPlay ? player.pause() : ()
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))

        let value = percent * durationSeconds
        let time = CMTime(seconds: value, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] finished in
            guard let self = self else { return }
            if finished {
                self.supposedCurrentTime = time
                DispatchQueue.main.async {
                    completion(finished)
                }
                self.isSeeking = false
            }
        }

    }

    func getCurrentSeekingSecond() -> TimeInterval? {
        let time = player.currentTime
        return CMTimeGetSeconds(time())
    }
}
