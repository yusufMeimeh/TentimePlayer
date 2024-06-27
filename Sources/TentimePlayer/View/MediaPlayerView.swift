//
//  MediaPlayerView.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 11/09/2023.
//

import UIKit
import AVFoundation
import Combine
import AVKit
import AppTrackingTransparency
import AdSupport

protocol MediaPlayerViewDelegate: AnyObject {
    func didStartPipMode()
    func didEndPipMode()
    func didRestorePipMode(completionHandler: @escaping (Bool) -> Void)
    func didClosePlayer()
}

extension MediaPlayerViewDelegate {
    func didStartPipMode() {}
    func didEndPipMode() {}
    func didRestorePipMode(completionHandler: @escaping (Bool) -> Void) {}
    func didClosePlayer() {}
}

class MediaPlayerView: UIView {
    // player outlets and features
    @IBOutlet var playPauseButton: UIButton?
    @IBOutlet var progressBar: UISlider?
    
    @IBOutlet var playerContainerView: UIView?
    @IBOutlet var currentTimeLabel: UILabel?
    @IBOutlet var durationTimeLabel: UILabel?
    
    var player = TenTimePlayer.shared
    private var playerLayer: AVPlayerLayer!
    
    weak var delegate: MediaPlayerViewDelegate?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    var enablePipMode: Bool = false
    
    @IBOutlet weak var pipModeButton: UIButton?
    
    //catption/audio
    var audioTraks: [AVMediaSelectionOption] = []
    var subtitleTraks: [AVMediaSelectionOption] = []
    
    let upNextView = UpNextContentView()
    
    @IBOutlet weak var routerPickerView: AVRoutePickerView! {
        didSet {
            createAirPlayView()
        }
    }
    @IBOutlet weak var controllerContainerVIew: UIView!
    var isSequenceContent = false {
        didSet {
            isSequenceContent ? player.showUpNextContent(before: showNextItemBefore) : ()
        }
    }
    
    var showNextItemBefore: Double = 30
    
    var nextContent: PlayerData?
    
    var shouldAddAds = false
    
    private var cancellables = Set<AnyCancellable>()
    
    class func initFromNib() -> MediaPlayerView {
        let bundle = Bundle(for: self)
        if bundle.path(forResource: "TenTimeMediaPlayerView", ofType: "nib") != nil {
            return UINib(nibName: "TenTimeMediaPlayerView", bundle: bundle).instantiate(withOwner: nil, options: nil).first as! UIView as! MediaPlayerView
        } else {
            preconditionFailure("This method must be overridden")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBinding()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        commonInit()
    }
    
    private func commonInit() {
        //Create AVPlayerLayer and configure it
        if player.isPipModeStarted {return}
        playerLayer?.removeFromSuperlayer()
        playerLayer = AVPlayerLayer(player: player.getPlayer())
        playerLayer.frame = bounds
        playerLayer.videoGravity = .resizeAspectFill
        playerContainerView?.layer.addSublayer(playerLayer)
        if enablePipMode {
            player.setupPipMode(playerLayer: playerLayer!)
        }
        Task {
            audioTraks =  await player.getAvailableAudioTracks()
            subtitleTraks = await player.getAvailableSubtitleTracks()
            
        }
        
        addSubview(upNextView)
        upNextView.anchor(bottom:   bottomAnchor,
                          trailing: trailingAnchor,
                          padding:  .init(top: 0,
                                          left: 100,
                                          bottom: 64,
                                          right: 100))
        upNextView.constrainWidth(250)
        upNextView.constrainHeight(200)
        upNextView.isHidden = true
        
        upNextView.cancelTapped = { [weak self] in
            self?.upNextView.isHidden = true
            self?.player.isCanceledUpNextContent = true
            self?.controllerContainerVIew.isHidden = false
        }
        
        upNextView.nextTapped = { [weak self]  in
            self?.playNextItem()
        }
        if shouldAddAds {
            requestIDFA()
            
        }
    }
    
    
    func requestIDFA() {
      ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
        // Tracking authorization completed. Start loading ads here.
        // loadAd()
          self.player.requestAds(view: self, viewController: self.findViewController())
      })
    }
    

    
    func createAirPlayView() {
        routerPickerView.delegate = self
        routerPickerView.backgroundColor = .clear
        routerPickerView.activeTintColor = .systemBlue
        routerPickerView.tintColor = .white
        routerPickerView.prioritizesVideoDevices = true
//        presenter?.playerWrapperHandler?.playerHandler?.playerManager.player?.allowsExternalPlayback = true
        
    }
    
    private func playNextItem() {
        guard let nextContent = nextContent else {return}
        upNextView.isHidden = true
        player.loadMedia(from: nextContent)
        controllerContainerVIew?.isHidden = false
    }
    // Common functionality (e.g., play, pause, progress update)
    func play() {
        // Implement play logic
    }
    
    func pause() {
        // Implement pause logic
    }
    
    @IBAction func togglePlayPauseAction(_ sender: UIButton) {
        player.togglePlayerPause()
    }
    
    /// - Parameter sender:
    @IBAction func handleCurrentTimePlayerViewSlider(_ sender: UISlider) {
        Task {
            await player.seek(percent: Double(sender.value))
        }
        //        presenter?.didTriggerOnSeekedEvent(currentTime: Double(sender.value))
        //        keepControls = true
    }
    @IBAction func close(_ sender: Any) {
        player.endPlayer()
        delegate?.didClosePlayer()
    }
    
    @IBAction func showAudioTracks(_ sender: Any) {
        // Create an alert controller
        let alertController = UIAlertController(title: "Audio Options", message: nil, preferredStyle: .actionSheet)
        
        // Add audio track options
        for (_, audioTrack) in audioTraks.enumerated() {
            let action = UIAlertAction(title: audioTrack.displayName, style: .default) { [weak self] _ in
                // Handle audio track selection here
                // You can use audioTrack to access the selected track
                // Add your logic to select the audio track
                // For example, you can set a variable to store the selected audio track.
                Task {
                    await self?.player.selectAudioOption(for: audioTrack)
                }
                // After selection, dismiss the modal sheet
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {  _ in
            // Dismiss the modal sheet without selecting any option
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        
        findViewController()?.present(alertController, animated: true)
        
    }
    
    @IBAction func showSubtitleTracks(_ sender: Any) {
        let alertController = UIAlertController(title: "Subtitle Options", message: nil, preferredStyle: .actionSheet)

        // Add subtitle track options
          for (_, subtitleTrack) in subtitleTraks.enumerated() {
              let action = UIAlertAction(title: subtitleTrack.displayName, style: .default) { [weak self] _ in
                  // Handle subtitle track selection here
                  // You can use subtitleTrack to access the selected track
                  // Add your logic to select the subtitle track
                  // For example, you can set a variable to store the selected subtitle track.
                  Task {
                      await self?.player.selectSubtitleOption(for:subtitleTrack)
                  }
                  // After selection, dismiss the modal sheet
                  alertController.dismiss(animated: true, completion: nil)
              }
              
              alertController.addAction(action)
          }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {  _ in
            // Dismiss the modal sheet without selecting any option
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        findViewController()?.present(alertController, animated: true)

    }
//
//        func showContentPlayer() {
//          self.addChild(playerViewController)
//          playerViewController.view.frame = self.view.bounds
//          self.view.insertSubview(playerViewController.view, at: 0)
//          playerViewController.didMove(toParent:self)
//        }
//    //
    //    func hideContentPlayer() {
    //      // The whole controller needs to be detached so that it doesn't capture
    //      // events from the remote.
    //      playerViewController.willMove(toParent:nil)
    //      playerViewController.view.removeFromSuperview()
    //      playerViewController.removeFromParent()
    //    }

    
}

extension MediaPlayerView {

    /// - Parameter sender:
    @IBAction func pipMode(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.player.startPipMode()
        }
    }
    
    /// fast forward video to specific range time
    /// - Parameter sender:
    @IBAction func rewindForwardButton(_ sender: Any) {
        player.seekToCurrentTime(delta: 10)
        //        keepControls = true
    }
    
    /// rewind video to specific range time
    /// - Parameter sender:
    @IBAction func rewindBackwardButton(_ sender: Any) {
        player.seekToCurrentTime(delta: -10)
        //keepControls = true
    }
    
    func didStartPipMode() {
        delegate?.didStartPipMode()
    }
    
    func didEndPipMode() {
        delegate?.didEndPipMode()
    }
    
    func player(restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        delegate?.didRestorePipMode(completionHandler: completionHandler)
    }
    
   
    
    private func setupBinding() {
        player.$isPipModeEnabled
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self]  isPipModeEnabled in
                self?.pipModeButton?.isEnabled = isPipModeEnabled
            })
            .store(in: &cancellables)
        
        player.$isLoading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self]  isLoading in
                if isLoading {
                    self?.activityIndicator?.startAnimating()
                }else {
                    self?.activityIndicator?.stopAnimating()
                }
            })
            .store(in: &cancellables)
        
        player.$didFinishPlaying
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self]  isLoading in
                if !(self?.upNextView.isHidden ?? false) {
                    self?.playNextItem()
                    self?.player.play()
                }
            })
            .store(in: &cancellables)
        
        player.$shouldShowUpNextContent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self]  shouldShowUpNextContent in
                if !shouldShowUpNextContent {return}
                guard let data = self?.player.getNextItem(),
                      let remainingTime = self?.player.remainingTime else {return}
                self?.nextContent = data
                self?.upNextView.isHidden = false
                self?.upNextView.configure(with: data.thumbImage, data.movieName, data.description)
                self?.upNextView.runTimer(with: remainingTime)
                self?.controllerContainerVIew?.isHidden = true
            })
            .store(in: &cancellables)
        
        player.$shouldHideUpNextContent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self]  shouldHideUpNextContent in
                if shouldHideUpNextContent {
                    self?.upNextView.isHidden = true
                }
            })
            .store(in: &cancellables)
        
        player.$isPlay
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self]  isPlay in
                self?.playPauseButton?.setImage(UIImage(named: isPlay ? "PlayerPause" : "PlayerPlay"), for: .normal)
            })
            .store(in: &cancellables)
        
        player.$didUpdateTime
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] updatedTimeInfo in
                DispatchQueue.main.async {
                    guard let updatedTimeInfo = updatedTimeInfo else {return}
                    let currentTimeSeconds = updatedTimeInfo.2
                    let durationTimeSeconds =  updatedTimeInfo.3
                    let currentTime = updatedTimeInfo.0
                    let duration = updatedTimeInfo.1
                    self?.progressBar?.value = Float(currentTimeSeconds / durationTimeSeconds)
                    self?.currentTimeLabel?.text = currentTime
                    self?.durationTimeLabel?.text = duration
                }
            })
            .store(in: &cancellables)
        
        
        
        player.$pipModeStatus
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] status in
                switch status {
                    case .start:
                        self?.didStartPipMode()
                    case .end:
                        self?.didEndPipMode()
                    case .restoreUserInterface:
                            ()
//                        self?.delegate?.didRestorePipMode(completionHandler: completionHandler)
                    default: ()
                }
            })
            .store(in: &cancellables)
    }
}

//PIP mode fix
//subtitle & audio
//loading error
//notification center control audio/video
//play drm/
//play offline

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}


extension MediaPlayerView: AVRoutePickerViewDelegate {
    func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        print("routePickerViewWillBeginPresentingRoutes")
    }
    
    func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        print("routePickerViewDidEndPresentingRoutes")
    }
}

