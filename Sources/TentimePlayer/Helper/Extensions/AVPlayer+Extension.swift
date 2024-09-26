//
//  AVPlayer+Extension.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 18/09/2023.
//

import AVFoundation

extension AVPlayer {
    public func seek(to percent: Float64) {
        guard let duration = currentItem?.duration else { return }
        //compute second from percent value
        let durationInSeconds = percent * CMTimeGetSeconds(duration)
        let seekTime = CMTimeMakeWithSeconds(durationInSeconds, preferredTimescale: Int32(NSEC_PER_SEC))
        seek(to: seekTime)
    }
    
    /// seek player to specific time
    /// - Parameter delta: number of second should player seek to
   public func seek(by delta: Int64, currentTime: CMTime) {
        let seconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(currentTime, seconds)
        seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
        //move player time to seekTime
//        seek(to: seekTime)
        print("#####Curent Time ####", currentTime)
    }
    
    /// seek player to specific time
    /// - Parameter delta: number of second should player seek to
    public func seek(second: Float64) {
        let seekTime = CMTimeMakeWithSeconds(second, preferredTimescale:Int32(NSEC_PER_SEC))
        seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
}
