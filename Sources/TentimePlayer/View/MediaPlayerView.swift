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

//import GoogleCast

var  pipModeController: UIViewController?

public protocol MediaPlayerViewDelegate: AnyObject {
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


public class MediaPlayerView: UIView {
    // player outlets and features
    @IBOutlet var playPauseButton: UIButton?
    @IBOutlet var progressBar: UISlider?
    
    @IBOutlet weak var chromeCastView: UIView!
    @IBOutlet weak var controlControllerViewApperance: UIView!
    @IBOutlet var playerContainerView: UIView?
    @IBOutlet var currentTimeLabel: UILabel?
    @IBOutlet var durationTimeLabel: UILabel?
    
    var player = TenTimePlayer.shared
    private var playerLayer: AVPlayerLayer!
    
    public weak var delegate: MediaPlayerViewDelegate?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    public var enablePipMode: Bool = false
    
    @IBOutlet weak var pipModeButton: UIButton?
    
    //catption/audio
    var audioTraks: [AVMediaSelectionOption] = []
    var subtitleTraks: [AVMediaSelectionOption] = []
    
    let upNextView = UpNextContentView.initFromNib()
    
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
    
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    var showNextItemBefore: Double = 30
    
    var nextContent: PlayerData?
    
    var shouldAddAds = false
    
    private var cancellables = Set<AnyCancellable>()
    
    class public func initFromNib() -> MediaPlayerView {
        let className = String(describing: "TenTimeMediaPlayerView")
        let bundle = Bundle.module
        if let view = bundle.loadNibNamed(className, owner: nil, options: nil)?.first as? MediaPlayerView  {
            return view
        } else {
            preconditionFailure("This method must be overridden")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBinding()
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBinding()
        commonInit()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        commonInit()
        playerLayer.frame = bounds
        
    }
    
    
    private func commonInit() {
        //Create AVPlayerLayer and configure it
        if player.isPipModeStarted {return}
        playerLayer?.removeFromSuperlayer()
        playerLayer = AVPlayerLayer(player: player.getPlayer())
        playerLayer.frame = bounds
        playerLayer.videoGravity = .resizeAspectFill
        playerContainerView?.layer.addSublayer(playerLayer)
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
        
        // Add tap gesture recognizer to playerContainerView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showControllerContainer))
        controlControllerViewApperance?.addGestureRecognizer(tapGesture)
        
        // Add tap gesture recognizer to playerContainerView
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handlePlayerTap))
        controllerContainerVIew?.addGestureRecognizer(tapGesture2)
    }
    
    
    @objc private func handlePlayerTap() {
        // Action to perform when the player is tapped
        print("Player tapped")
        // Animate the visibility toggle of controllerContainerView
        
        UIView.animate(withDuration: 0.3, animations: {
            self.controllerContainerVIew.alpha =  self.controllerContainerVIew.alpha == 0 ? 1 : 0
        }) { _ in
            self.controlControllerViewApperance.isUserInteractionEnabled = true
        }
    }
    
    
    @objc private func showControllerContainer() {
        // Action to perform when the player is tapped
        print("Player tapped")
        // Add your custom action here
        // Animate the visibility toggle of controllerContainerView
        UIView.animate(withDuration: 0.3, animations: {
            self.controllerContainerVIew.alpha = 1
            self.controlControllerViewApperance.isUserInteractionEnabled = false
        })
        
    }
    
    
    func requestIDFA() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                // Tracking authorization completed. Start loading ads here.
                // loadAd()
                self.player.requestAds(view: self, viewController: self.findViewController())
            })
        } else {
            // Fallback on earlier versions
        }
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
        player.shouldShowUpNextContent = false
        upNextView.isHidden = true
        guard let nextContent = self.player.getNextItem() else {return}
        player.loadMediContent(nextContent)
        player.currentQueueIndex += 1
        controllerContainerVIew?.isHidden = false
    }
    // Common functionality (e.g., play, pause, progress update)
    public func play() {
        // Implement play logic
     player.play()
    }
    
    public func pause() {
        // Implement pause logic
      player.pause()
    }
    
    @IBAction func togglePlayPauseAction(_ sender: UIButton) {
        player.togglePlayPause()
    }
    
    /// - Parameter sender:
    @IBAction func handleCurrentTimePlayerViewSlider(_ sender: UISlider) {
        player.seekByProgress( Double(sender.value))
        //        presenter?.didTriggerOnSeekedEvent(currentTime: Double(sender.value))
        //        keepControls = true
    }
    @IBAction func close(_ sender: Any) {
        player.endPlayer()
        delegate?.didClosePlayer()
        findViewController()?.dismiss(animated: true)
    }
    
    @IBAction func playPreviousContent(_ sender: Any) {
        player.playPrevItem()
    }
    
    @IBAction func playNextContent(_ sender: Any) {
        player.playNextItem()
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
        player.skipForward(10)
        //        keepControls = true
    }
    
    /// rewind video to specific range time
    /// - Parameter sender:
    @IBAction func rewindBackwardButton(_ sender: Any) {
        player.skipBackrward()
        //keepControls = true
    }
    
    func didStartPipMode() {
        guard let viewController = self.findViewController() else { return }
        
        if viewController.parent != nil {
            // Dismiss the view controller from its parent before using it in PiP mode
            viewController.dismiss(animated: true) { [weak self] in
                pipModeController = viewController
                // Present the PiP mode controller here if needed
            }
        } else {
            pipModeController = viewController
            // Present the PiP mode controller here if needed
        }
        delegate?.didStartPipMode()
        
    }
    
    func didEndPipMode() {
        player.endPlayer()
        delegate?.didClosePlayer()
        delegate?.didEndPipMode()
        pipModeController = nil
        
    }
    
    func player(completionHandler: @escaping (Bool) -> Void) {
        guard let viewController = pipModeController else {
            completionHandler(false)
            return
        }
        
        if let parentViewController = viewController.parent {
            // Dismiss the view controller from its parent before presenting it
            parentViewController.dismiss(animated: false) { [weak self] in
                self?.presentViewController(viewController, completionHandler: completionHandler)
            }
        } else {
            presentViewController(viewController, completionHandler: completionHandler)
        }
    }
    
    private func presentViewController(_ viewController: UIViewController, completionHandler: @escaping (Bool) -> Void) {
        delegate?.didRestorePipMode(completionHandler: completionHandler)
        completionHandler(true)
        

//        findViewController()?.topmostViewController().present(viewController, animated: true, completion: {
//            self.delegate?.didRestorePipMode(completionHandler: completionHandler)
//            pipModeController = nil
//        })
    }
    
    
    private func setupBinding() {
        player.$isPipModeEnabled
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self]  isPipModeEnabled in                self?.pipModeButton?.isEnabled = isPipModeEnabled
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
                if self?.player.isCanceledUpNextContent == false {
                    self?.playNextItem()
                    self?.player.play()
                }
            })
            .store(in: &cancellables)
        
        player.$shouldShowUpNextContent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self]  shouldShowUpNextContent in
                if !shouldShowUpNextContent {return}
                guard
                    let remainingTime = self?.player.remainingTime,
                    let data = self?.player.getNextItem()
                else {return}
                self?.nextContent = data
                self?.upNextView.isHidden = false
                self?.upNextView.configure(
                    with: data.thumbImage ?? "",
                    data.movieName ?? "",
                    data.description)
                self?.upNextView.runTimer(with: self?.showNextItemBefore ?? 0)
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
        
        player.$isCurrentlyPlaying
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self]  isPlay in
                guard let bundle = Bundle.module.path(forResource:isPlay ? "pause" : "play", ofType: "png"),
                      let image = UIImage(contentsOfFile: bundle) else {
                    print("Failed to load image.")
                    return
                }
                self?.playPauseButton?.setImage(image, for: .normal)
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
                    guard let complitionHandler =  self?.player.pipCompletionHandler else {return}
                    self?.player(completionHandler: complitionHandler)
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

extension UIViewController {
    func topmostViewController() -> UIViewController {
        if let presentedVC = self.presentedViewController {
            return presentedVC.topmostViewController()
        }
        return self
    }}

extension MediaPlayerView: AVRoutePickerViewDelegate {
    public func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        print("routePickerViewWillBeginPresentingRoutes")
    }
    
    public  func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        print("routePickerViewDidEndPresentingRoutes")
    }
}

