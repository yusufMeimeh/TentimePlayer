//
//  TimeObservationManager.swift
//
//
//  Created by Qamar Al Amassi on 25/09/2024.
//

import AVFoundation

class TimeObservationManager: TimeObserverManaging {
    private var player: AVPlayer
    private var timeObserverToken: Any?
    private var isSeeking: Bool = false

    // Closure for updates
    var onTimeUpdate: ((TimeObservation) -> Void)?

    init(player: AVPlayer) {
        self.player = player
    }

    func startObserving(interval: CMTime = CMTimeMake(value: 1, timescale: 2)) {
        guard timeObserverToken == nil, !isSeeking else { return }

        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.onTimeUpdate?(calculateTimeObservation(for: time))
        }
    }

    func stopObserving() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }

    // Method to calculate and return a TimeObservation
    func calculateTimeObservation(for time: CMTime) -> TimeObservation {
        guard let playerItem = player.currentItem else {
            return TimeObservation()
        }

        let currentSeconds = time.seconds
        let durationSeconds = playerItem.duration.seconds
        let remainingSeconds = durationSeconds - currentSeconds

        return TimeObservation(
            progressValue: Double(currentSeconds / durationSeconds),
            durationTimeFormatted: playerItem.duration.toDisplayString(),
            currentTimeFormatted: time.toDisplayString(),
            currentTimeSeconds: currentSeconds,
            remainingTimeSeconds: remainingSeconds
        )
    }

    deinit {
        stopObserving()
    }
}

