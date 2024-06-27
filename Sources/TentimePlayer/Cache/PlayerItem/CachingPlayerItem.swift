//
//  CachingPlayerItem.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 15/09/2023.
//
import AVFoundation

fileprivate extension URL {
    
    func withScheme(_ scheme: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        return components?.url
    }
    
}

@objc protocol CachingPlayerItemDelegate {
    
    /// Is called when the media file is fully downloaded.
    @objc optional func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data)
    
    /// Is called every time a new portion of data is received.
    @objc optional func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int)
    
    /// Is called after initial prebuffering is finished, means
    /// we are ready to play.
    @objc optional func playerItemReadyToPlay(_ playerItem: CachingPlayerItem)
    
    /// Is called when the data being downloaded did not arrive in time to
    /// continue playback.
    @objc optional func playerItemPlaybackStalled(_ playerItem: CachingPlayerItem)
    
    /// Is called on downloading error.
    @objc optional func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error)
    
    @objc optional func playerItemIsLoading()

    @objc optional func playerItemStopLoading()

    
}

open class CachingPlayerItem: AVPlayerItem {

    fileprivate var resourceLoader = ResourceLoader() {
        didSet {
            resourceLoader.url = url
        }
    }
    fileprivate let url: URL
    fileprivate let initialScheme: String?
    fileprivate var customFileExtension: String?
    private var isBuffering = true
    var freezing = false
    
    var observableAttributes: [PlayerItemObservableAttributes] = PlayerItemObservableAttributes.allCases

    
    weak var delegate: CachingPlayerItemDelegate?
    
    //can be used for pre-download
    func download() {
        if resourceLoader.session == nil {
            resourceLoader.startDataRequest(with: url)
        }
    }
    
    private let cachingPlayerItemScheme = "cachingPlayerItemScheme"
    
    /// Is used for playing remote files.
    convenience init(url: URL) {
        self.init(url: url, customFileExtension: nil)
    }
    
    /// Override/append custom file extension to URL path.
    /// This is required for the player to work correctly with the intended file type.
    init(url: URL, customFileExtension: String?) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let scheme = components.scheme,
            var urlWithCustomScheme = url.withScheme(cachingPlayerItemScheme) else {
            fatalError("Urls without a scheme are not supported")
        }
        
        self.url = url
        self.initialScheme = scheme
        
        if let ext = customFileExtension {
            urlWithCustomScheme.deletePathExtension()
            urlWithCustomScheme.appendPathExtension(ext)
            self.customFileExtension = ext
        }

        resourceLoader.url = url
        let asset = AVURLAsset(url: url)
        asset.resourceLoader.setDelegate(resourceLoader, queue: DispatchQueue.main)
        super.init(asset: asset, automaticallyLoadedAssetKeys: nil)
        resourceLoader.delegate = self
        registerNotification(with: self)
    
    }
    
    private func registerNotification(with playerItem: AVPlayerItem?) {
        guard let playerItem = playerItem else {
            return
        }
        observableAttributes.forEach { item in
            playerItem.addObserver(self, forKeyPath: item.observableAttribute, options: [.new, .old], context: nil)
        }
                
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalledHandler), name:NSNotification.Name.AVPlayerItemPlaybackStalled, object: self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(FailedToPlayAtEndTime(_:)),
                                               name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime,
                                               object: nil)
    }
    
    // MARK: KVO
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == #keyPath(AVPlayerItem.status),
           let change = change,
           let newValue = change[NSKeyValueChangeKey.newKey] as? Int {
            let status: AVPlayerItem.Status
            status = AVPlayerItem.Status(rawValue: newValue)!
            // Switch over status value
            switch status {
            case .unknown:
                delegate?.playerItemIsLoading?()
                isBuffering = true
             case .failed:
                delegate?.playerItemIsLoading?()
                isBuffering = true
                      
            case .readyToPlay:
                // Fix https://tentime.atlassian.net/browse/TTAB-22159
                isBuffering = false
                delegate?.playerItemStopLoading?()
                delegate?.playerItemReadyToPlay?(self)
            default:
                ()
                break
            }
        }else if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferEmpty) {
            if isPlaybackBufferEmpty {
                isBuffering = true
                delegate?.playerItemIsLoading?()
                
            }
        } else if keyPath == #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp) || keyPath == #keyPath(AVPlayerItem.isPlaybackBufferFull) || keyPath == #keyPath(AVPlayerItem.tracks)   {
            if  (isPlaybackBufferFull || isPlaybackLikelyToKeepUp)  {
                isBuffering = false
                delegate?.playerItemStopLoading?()
            } else {
                isBuffering = true
                delegate?.playerItemIsLoading?()
            }
        }
    }
    
   
    
    // MARK: Notification hanlers
    @objc func playbackStalledHandler() {
        playerItemPlaybackStalled()
    }
    
    @objc private func FailedToPlayAtEndTime(_ notification: Notification) {
        playerItemPlaybackStalled()
    }
    
    // MARK: -
    override init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]?) {
        print("hhhghhgitgitkgjfjgktkg")
        fatalError("not implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        resourceLoader.session?.invalidateAndCancel()
        
        observableAttributes.forEach { item in
           removeObserver(self, forKeyPath: item.observableAttribute)
        }
    }
    
}


extension CachingPlayerItem: ResourceLoaderDelegate {
    func resourceLoader(didFinishDownloadingData data: Data) {
        delegate?.playerItem?(self, didFinishDownloadingData: data)
    }
    
    func resourceLoader(didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        delegate?.playerItem?(self, didDownloadBytesSoFar: bytesDownloaded, outOf: bytesExpected)
    }
    
    func playerItemReadyToPlay() {
        delegate?.playerItemReadyToPlay?(self)
    }
    
    func playerItemPlaybackStalled() {
        isBuffering = true
        freezing = true
        delegate?.playerItemPlaybackStalled?(self)
    }
    
    func resourceLoader(downloadingFailedWith error: Error) {
        delegate?.playerItem?(self, downloadingFailedWith: error)
    }
    
}
