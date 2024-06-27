//
//  Player+PipMode.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 20/09/2023.
//

import AVFoundation
import AVKit

extension TenTimePlayer {
    internal func setupPipMode(playerLayer: AVPlayerLayer) {
        if  AVPictureInPictureController.isPictureInPictureSupported() {
            pictureInPictureController = AVPictureInPictureController(playerLayer: playerLayer)
            pictureInPictureController?.addObserver(self, forKeyPath: #keyPath(AVPictureInPictureController.isPictureInPicturePossible), options: [.new, .initial], context: &playerViewControllerKVOContext)
            pictureInPictureController?.delegate = self
            
            if #available(iOS 14.0, *) {
                pictureInPictureController?.requiresLinearPlayback = true
            }
        }else {
           isPipModeEnabled = false
        }
    }
    
    func startPipMode() {
        isPipModeStarted = true
        pictureInPictureController?.startPictureInPicture()
    }
    
}

//MARK: AVPictureInPictureControllerDelegate
extension TenTimePlayer: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pictureInPictureControllerDidStart: ")
        isPipModeStarted = true
        pipModeStatus = .start
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pictureInPictureControllerDidStop: ")
        isPipModeStarted = false
        if pipModeStatus != .restoreUserInterface {
            endPlayer()
            pipModeStatus = .end
        }else {
            pipModeStatus = .stop
        }
        
        //        player?.replaceCurrentItem(with: nil)
        //        delegate?.didEndPipMode?()
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("failedToStartPictureInPicture: ", error.localizedDescription)
        isPipModeStarted = false
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        print("restoreUserInterfaceForPictureInPicture: ")
        isCurrentlyPlaying = player?.rate != 0
        if isCurrentlyPlaying {
            play()
        }else {
            pause()
        }
        pipModeStatus = .restoreUserInterface
        //check how we can change it
        guard let activeCustomPlayerViewControllers = activeCustomPlayerViewControllers else {return}
        UIApplication.shared.topmostViewController()?.present(activeCustomPlayerViewControllers, animated: false) {
            completionHandler(true)
        }
    }
    
 }
