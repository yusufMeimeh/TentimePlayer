//
//  Player+Ads.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 29/09/2023.
//

import Foundation
import GoogleInteractiveMediaAds

extension TenTimePlayer {
    open func setUpAdsLoader() {
        guard let pipModeManager = pipModeManager else { return }
        pipModeManager.pictureInPictureProxy = IMAPictureInPictureProxy(avPictureInPictureControllerDelegate: pipModeManager)

        if pipModeManager.pictureInPictureController != nil {
            pipModeManager.pictureInPictureController!.delegate = pipModeManager.pictureInPictureProxy
        }
        
        let settings = IMASettings()
        settings.sameAppKeyEnabled = false
        settings.enableBackgroundPlayback = true

        adsLoader = IMAAdsLoader(settings: settings)

        adsLoader.delegate = self
      }

    open  func requestAds(view: UIView, viewController: UIViewController?) {
        guard let pipModeManager = pipModeManager else { return }
       // Create ad display container for ad rendering.
        guard let pictureInPictureProxy = pipModeManager.pictureInPictureProxy else {return}
       let adDisplayContainer = IMAAdDisplayContainer(adContainer: view, viewController: viewController)
       // Create an ad request with our ad tag, display container, and optional user context.
       let request = IMAAdsRequest(
            adTagUrl: adTagURLString,
            adDisplayContainer: adDisplayContainer,
            avPlayerVideoDisplay: IMAAVPlayerVideoDisplay(avPlayer: player),
            pictureInPictureProxy: pictureInPictureProxy,
           userContext: nil)
       adsLoader.requestAds(with: request)
     }
}



extension TenTimePlayer: IMAAdsLoaderDelegate {
    open  func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        adsManager = adsLoadedData.adsManager
        adsManager.delegate = self
        // Initialize the ads manager.
        adsManager.initialize(with: nil)
    }
    
    open func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        print("Error loading ads: " + (adErrorData.adError.message ?? ""))
//          showContentPlayer()
        playbackManager.play()
        isAdPlayback = false
    }
}

// MARK: - IMAAdsManagerDelegate
extension TenTimePlayer: IMAAdsManagerDelegate {
    open   func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        guard let pipModeManager = pipModeManager else { return }

        switch event.type {
        case .LOADED:
            if pipModeManager.pictureInPictureController == nil
                || !pipModeManager.pictureInPictureController!.isPictureInPictureActive
            {
                adsManager.start()
            }
            break
        case IMAAdEventType.PAUSE:
            //          setPlayButtonType(PlayButtonType.playButton)
            break
        case IMAAdEventType.RESUME:
            //          setPlayButtonType(PlayButtonType.pauseButton)
            break
        case IMAAdEventType.TAPPED:
            //          showFullscreenControls(nil)
            break
            
        default:
          break
        }
       
    }
    open  func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        print("AdsManager error: " + (error.message ?? ""))
        //          showContentPlayer()
        isAdPlayback = false
        playbackManager.play()
    }
    
    open func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        isAdPlayback = true

        playbackManager.pause()
//        hideContentPlayer()
    }
    
    open func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        //          showContentPlayer()
        isAdPlayback = false
        playbackManager.play()
    }
    
  
}
