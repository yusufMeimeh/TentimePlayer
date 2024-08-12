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
        pictureInPictureProxy = IMAPictureInPictureProxy(avPictureInPictureControllerDelegate: self)
        
        if pictureInPictureController != nil {
          pictureInPictureController!.delegate = pictureInPictureProxy
        }
        
        let settings = IMASettings()
        settings.sameAppKeyEnabled = false
        settings.enableBackgroundPlayback = true

        adsLoader = IMAAdsLoader(settings: settings)

        adsLoader.delegate = self
      }

    open  func requestAds(view: UIView, viewController: UIViewController?) {
       // Create ad display container for ad rendering.
       guard let player = player,
       let pictureInPictureProxy = pictureInPictureProxy else {return}
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
         player?.play()
        isAdPlayback = false


    }
    
    
}

// MARK: - IMAAdsManagerDelegate
extension TenTimePlayer: IMAAdsManagerDelegate {
    open   func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        switch event.type {
        case .LOADED:
            if pictureInPictureController == nil
                || !pictureInPictureController!.isPictureInPictureActive
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

        player?.play()
    }
    
    open func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        isAdPlayback = true

        player?.pause()
//        hideContentPlayer()
    }
    
    open func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        //          showContentPlayer()
        isAdPlayback = false
        player?.play()
    }
    
  
}
