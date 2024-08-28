//
//  Player+UpNextContent.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 25/09/2023.
//

import Foundation


extension TenTimePlayer {
    
    func showUpNextContent(before duration: Double) {
        showUpNextContent = true
        showUpNextBefore = duration
    }
    
    
    func handleUpNext(currentTime: Double, duration: Double) {
        guard isCanceledUpNextContent == nil else {return}
        let value = showUpNextBefore
         remainingTime = duration - value//duration * 0.98
        if duration.isNaN || duration.isInfinite ||  duration == 0.0 || isLoading || isAdPlayback {
            return
        }
//        let displayDescription = "UP_NEXT_TIMER".localizedFormat(Int(remainingTime.rounded(.up)))
        if currentTime >= remainingTime,
           !(queueItem.isEmpty ?? false) {
//            currentIndex = currentIndex + 1
            if !shouldShowUpNextContent {
                shouldShowUpNextContent = true
            }
        } else {
//            shouldHideUpNextContent = true
//            view?.hideUpNextContent(fromPIP: playerWrapperHandler?.isPipMode() == true)
        }
    }
    
    func getNextItem() -> PlayerData? {
        guard currentQueueIndex >= 0 && currentQueueIndex < queueItem.count - 1 else {return nil}
        return queueItem[currentQueueIndex + 1]

    }
    
    func getPrevItem() -> PlayerData? {
        guard currentQueueIndex >= 0 && currentQueueIndex < queueItem.count - 1 else {return nil}
        return queueItem[currentQueueIndex - 1]

    }
    
    public func playNextItem() {
        guard let nextContent = getNextItem() else {return}
        loadMediContent(nextContent)
        currentQueueIndex += 1
    }
    
    
    public func playPrevItem() {
        guard let nextContent = getPrevItem() else {return}
        loadMediContent(nextContent)
        currentQueueIndex -= 1
    }
    
    public func isFirstItem() -> Bool {
        currentQueueIndex == 0
    }
    
    public func isLastItem() -> Bool {
        currentQueueIndex == queueItem.count - 1
    }
    // Common
   
}
 
