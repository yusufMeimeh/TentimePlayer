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
        guard !isCanceledUpNextContent else {return}
        let value = showUpNextBefore
         remainingTime = duration - value//duration * 0.98
        if duration.isNaN || duration.isInfinite ||  duration == 0.0 || isLoading || !isAdPlayback {
            return
        }
//        let displayDescription = "UP_NEXT_TIMER".localizedFormat(Int(remainingTime.rounded(.up)))
        if currentTime >= remainingTime,
           !(playerData?.relatedWorks.isEmpty ?? false) {
//            currentIndex = currentIndex + 1
           shouldShowUpNextContent = true
        } else {
            shouldHideUpNextContent = true
//            view?.hideUpNextContent(fromPIP: playerWrapperHandler?.isPipMode() == true)
        }
    }
    
    func getNextItem() -> PlayerData? {
        playerData?.relatedWorks[1]
    }
   
}
 
