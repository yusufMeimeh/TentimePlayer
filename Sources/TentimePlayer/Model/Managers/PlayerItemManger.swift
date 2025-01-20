//
//  PlayerItem.swift
//  AVPLayerExample
//
//  Created by Apple on 15/09/2021.
//

import AVKit

enum PlayerItemStatus {
    case loading, play, pause
}

protocol PlayerItemManaging {
    func setupPlayerItem(with asset: AVURLAsset?) -> AVPlayerItem?
    var observableAttributes: Set<PlayerItemObservableAttributes> { get set }
    func checkPlayerBufferingStatus() -> Bool
}

// 1. 240p = 700000
// 2. 360p = 1500000
// 3. 480p = 2000000
// 4. 720p = 4000000
// 5. 1080p = 6000000
// 6. 2k = 16000000
// 7. 4k = 45000000
extension PlayerItemManaging {
    func initPlayerItem(with asset: AVURLAsset?) -> AVPlayerItem? {
        guard  let asset = asset else {
            return nil
        }
        let playerItem = AVPlayerItem(asset: asset)
        //        playerItem.preferredPeakBitRate = 700000
        playerItem.preferredForwardBufferDuration = 15
        return playerItem
    }
}

class PlayerItemManager: NSObject, PlayerItemManaging {
    var freezing = false

    private var isBuffering = true

    var observableAttributes: Set<PlayerItemObservableAttributes> = [] {
        didSet {
            registerNotification()
        }
    }

    weak var delegate: PlayerItemDelegate?

    var playerItem: AVPlayerItem?
    //audio, subtitles  option
    var audioOptions: [AVMediaSelectionOption]?

    var subtitleOptions: [AVMediaSelectionOption]?

    func setupPlayerItem(with asset: AVURLAsset?) -> AVPlayerItem? {
        playerItem = initPlayerItem(with: asset)
        return playerItem
    }

    func setupPlayerItem(with url: URL?) -> AVPlayerItem? {
        guard let url = url else {
            return nil
        }

        playerItem = AVPlayerItem(url: url)
        return playerItem
    }

    private func registerNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(itemPlaybackStalled(_:)),
                                               name: NSNotification.Name.AVPlayerItemPlaybackStalled,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(FailedToPlayAtEndTime(_:)),
                                               name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime,
                                               object: nil)
        observableAttributes.forEach { item in
            playerItem?.addObserver(self, forKeyPath: item.observableAttribute, options: [.new, .old], context: nil)
        }

    }

    @objc private func FailedToPlayAtEndTime(_ notification: Notification) {
        freezing = true
        isBuffering = true
        delegate?.playerItemManager(self, didUpdate: true)
    }

    @objc private func itemPlaybackStalled(_ notification: Notification) {
        freezing = true
        isBuffering = true
        delegate?.playerItemManager(self, didUpdate: true)
    }

    var isAudioSessionUsingAirplayOutputRoute: Bool {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        for outputPort in currentRoute.outputs {
            if outputPort.portType == AVAudioSession.Port.airPlay {
                return true
            }
        }
        return false
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let currentItem = playerItem else {
            return
        }
        if keyPath == #keyPath(AVPlayerItem.status),
           let change = change,
           let newValue = change[NSKeyValueChangeKey.newKey] as? Int {
            let status: AVPlayerItem.Status
            status = AVPlayerItem.Status(rawValue: newValue)!
            // Switch over status value
            switch status {
            case .unknown:
                delegate?.playerItemManager(self, didUpdate: true)
                isBuffering = true
            case .failed:
                delegate?.playerItemManager(self, didUpdate: true)
                isBuffering = true
                // Access the error and print it
                if let error = currentItem.error {
                    print("Player item failed with error: \(error.localizedDescription)")
                } else {
                    print("Player item failed with an unknown error.")
                }
            case .readyToPlay:
                // Fix https://tentime.atlassian.net/browse/TTAB-22159
                isBuffering = false
                if isAudioSessionUsingAirplayOutputRoute {
                    delegate?.playerItemManager(self, didUpdate: false)
                }
            default:
                ()
                break
            }
        }
        if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferEmpty) {
            if currentItem.isPlaybackBufferEmpty {
                isBuffering = true
                delegate?.playerItemManager(self, didUpdate: true)
            }
        } else if  keyPath == #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp) || keyPath == #keyPath(AVPlayerItem.isPlaybackBufferFull) || keyPath == #keyPath(AVPlayerItem.tracks)  {
            if  (currentItem.isPlaybackBufferFull || currentItem.isPlaybackLikelyToKeepUp) && !freezing {
                if isVideoAvailable(item: currentItem) {
                    isBuffering = false
                    if isAudioSessionUsingAirplayOutputRoute {
                        delegate?.playerItemManager(self, didUpdate: false)
                        return
                    }
                    delegate?.playerItemManager(self, didUpdate: false)
                } else {
                    isBuffering = true
                    delegate?.playerItemManager(self, didUpdate: true)
                }
            } else {
                freezing = false
                isBuffering = true
                delegate?.playerItemManager(self, didUpdate: true)
            }
        }
    }

    func isVideoAvailable(item: AVPlayerItem) -> Bool {
        for video in item.tracks {
            if video.assetTrack?.mediaType == .video {
                return true
            }
        }
        return false
    }

    func checkPlayerBufferingStatus() -> Bool {
        return isBuffering
    }

    func removeObservers() {
        //remove all observers
        NotificationCenter.default.removeObserver(self,
                                                  name: nil,
                                                  object: playerItem)

        observableAttributes.forEach { item in
            playerItem?.removeObserver(self, forKeyPath: item.observableAttribute)
        }
    }

    deinit {
        removeObservers()
    }
}

protocol PlayerItemDelegate: NSObject {
    func playerItemManager(_ playerItemManager: PlayerItemManaging, didUpdate isLoad: Bool)
}
