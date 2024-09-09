//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 18/08/2024.
//

import GoogleInteractiveMediaAds
import AVFoundation

class PipModeManager: NSObject, PipModeManaging {
    
    var isPipModeEnabled: Bool = false
    
    var isPipModeStarted: Bool = false

    @Published var pipModeStatus: PipModeStatus?

    var pipCompletionHandler: ((Bool) -> Void)?

    @objc dynamic var pictureInPictureController: AVPictureInPictureController?

    var pictureInPictureProxy: IMAPictureInPictureProxy?

    var playerViewControllerKVOContext = 0

    internal func setupPipMode(playerLayer: AVPlayerLayer) {
        if  AVPictureInPictureController.isPictureInPictureSupported() {
            pictureInPictureController = AVPictureInPictureController(playerLayer: playerLayer)
            pictureInPictureController?.addObserver(self, forKeyPath: #keyPath(AVPictureInPictureController.isPictureInPicturePossible), options: [.new, .initial], context: &playerViewControllerKVOContext)
            pictureInPictureController?.delegate = self

            if #available(iOS 14.0, *) {
                pictureInPictureController?.requiresLinearPlayback = true
            }
        } else {
           isPipModeEnabled = false
        }
    }

    func startPipMode() {
        isPipModeStarted = true
        pictureInPictureController?.startPictureInPicture()
    }
    
    func configurePipMode(for player: AVPlayer, withProxy proxy: IMAPictureInPictureProxy?) {

    }
    
    open override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPictureInPictureController.isPictureInPicturePossible) {
            guard let newValue = change?[NSKeyValueChangeKey.newKey] as? NSNumber else {return}
            let isPictureInPicturePossible: Bool = newValue.boolValue
            //update enable status of pip mode
            print("isPictureInPicturePossible ", isPictureInPicturePossible)
            isPipModeEnabled = isPictureInPicturePossible
        }
    }

    func cleanUpObserver() {
        pictureInPictureController?.removeObserver(self,
                                                   forKeyPath: #keyPath(AVPictureInPictureController.isPictureInPicturePossible),
                                                   context: &playerViewControllerKVOContext)
    }

    deinit {
        cleanUpObserver()
    }

}

extension PipModeManager: AVPictureInPictureControllerDelegate {
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pictureInPictureControllerDidStart: ")
        isPipModeStarted = true
        pipModeStatus = .start
    }

    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pictureInPictureControllerDidStop: ")
        isPipModeStarted = false
        if pipModeStatus != .restoreUserInterface {
            pipModeStatus = .end
        } else {
            pipModeStatus = .stop
        }
    }

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("failedToStartPictureInPicture: ", error.localizedDescription)
        isPipModeStarted = false
    }

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        print("restoreUserInterfaceForPictureInPicture: ")
//        isCurrentlyPlaying = player.rate != 0
//        if isCurrentlyPlaying {
//            playbackManager.play()
//        } else {
//            playbackManager.pause()
//        }
        pipCompletionHandler = completionHandler
        pipModeStatus = .restoreUserInterface
//        //check how we can change it
//        guard let activeCustomPlayerViewControllers = activeCustomPlayerViewControllers else {return}
//        UIApplication.shared.topmostViewController()?.present(activeCustomPlayerViewControllers, animated: false) {
//            completionHandler(true)
//        }
    }
}
