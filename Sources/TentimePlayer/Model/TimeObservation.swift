//
//  TimeObservation.swift
//
//
//  Created by Qamar Al Amassi on 25/09/2024.
//

import Foundation

public struct TimeObservation: Equatable {
    public var progressValue: Double = 0.0
    public var durationTimeFormatted: String = "00:00"
    public var currentTimeFormatted: String = "00:00"
    public var currentTimeSeconds: Double = 0.0
    public var remainingTimeSeconds: Double = 0.0
}
