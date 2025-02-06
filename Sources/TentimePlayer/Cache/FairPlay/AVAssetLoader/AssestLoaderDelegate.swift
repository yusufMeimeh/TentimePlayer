//
//  AssetLoaderDeleagte.swift
//  PlayerSample
//
//  Created by Qamar Al Amassi on 15/09/2023.
//

import AVFoundation

class AssetLoaderDeleagte: NSObject, AVAssetResourceLoaderDelegate {
    static let shared = AssetLoaderDeleagte()
    private var downloadRequestByUser = false
    private var isOfflinePlayback = false
    private var assetName: String!
    private var fpsCertificate: Data?
    private var keyManager = DrmPersistableKeyManager()
    private let userDefaults: UserDefaultsManaging = DefaultUserDefaults()
    var keyRetrivalStrategy: KeyRetrivalStrategy!
    var certificateManager = CertificateManager()
    private let queue = DispatchQueue(label: "DRM_QUEUE", attributes: .concurrent)

    private override init() {
        super.init()

    }
    
    func addAsset(assetName: String,
                  isOfflinePlayback: Bool,
                  downloadRequestByUser: Bool,
                  asset: AVURLAsset) {
        asset.resourceLoader.setDelegate(self, queue:  DispatchQueue(label: "DRM_QUEUE"))
        self.assetName = assetName
        self.isOfflinePlayback = isOfflinePlayback
        self.downloadRequestByUser = downloadRequestByUser
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
       print("Resource loader called for request: \(loadingRequest)")

       guard let url = loadingRequest.request.url else {
           print("failed...", #function, "Unable to read the url/host data.")
           loadingRequest.finishLoading(with: NSError(domain: "com.domain.error", code: -1, userInfo: nil))
           return false
       }
       let loadingRequest = AVAssetResourceLoadingRequestWrapper(loadingRequest: loadingRequest)
       let keyRetirvalSrategy =  AVAssetLoaderRetrivalStrategyFactory.createKeyRetrivalStartegy(assetName: assetName, url: url, isOfflinePlayback: isOfflinePlayback, loadingRequest: loadingRequest, certifcateManager: certificateManager)
       keyRetirvalSrategy.retriveAVResourceLoaderKey { [weak self] result in
           guard let self = self else { return }
           switch result {
           case .success(let contentKey):
               print("Content key retrived Successfullyx")
               print("Now we can start playing our content")
           case .failure(let failure):
               print("Fail ", failure)

           }
       }
       return true
       
    }
    
    
    
  
}


