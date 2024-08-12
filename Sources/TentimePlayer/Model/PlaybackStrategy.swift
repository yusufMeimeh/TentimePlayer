//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 08/07/2024.
//

import Foundation

protocol PlaybackStrategy {
    func nextIndex(currentIndex: Int, totalItems: Int) -> Int?
    func prevIndex(currentIndex: Int, totalItems: Int) -> Int?
}

public class SequentialPlayback: PlaybackStrategy {
    func nextIndex(currentIndex: Int, totalItems: Int) -> Int? {
        guard currentIndex < totalItems - 1 else {return nil}
        return currentIndex + 1
    }
    
    func prevIndex(currentIndex: Int, totalItems: Int) -> Int?{
        guard currentIndex > 0 else {return nil}
        return currentIndex - 1
    }
}


public class CircularPlayback: PlaybackStrategy {
    func nextIndex(currentIndex: Int, totalItems: Int) -> Int? {
        return (currentIndex + 1) % totalItems
    }
    
    func prevIndex(currentIndex: Int, totalItems: Int) -> Int?{
        return (currentIndex - 1 + totalItems) % totalItems
    }
}


public class ShufflePlayback: PlaybackStrategy {
    private var lastPlayedIndex: Int?
    
    func prevIndex(currentIndex: Int, totalItems: Int) -> Int? {
        var nextIndex: Int
        repeat {
            nextIndex = Int(arc4random_uniform(UInt32(totalItems)))
        } while totalItems > 1 && nextIndex == lastPlayedIndex
        lastPlayedIndex = nextIndex
        return nextIndex
    }
    
    func nextIndex(currentIndex: Int, totalItems: Int) -> Int? {
        // Shuffle does not naturally support precise 'previous' functionality
        return nil
    }
}
