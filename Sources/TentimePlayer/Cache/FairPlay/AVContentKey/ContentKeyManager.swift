//
//  AVContentKeyManager.swift
//  TenTime
//
//  Created by Qamar Al Amassi on 07/01/2022.
//  Copyright © 2022 TenTime. All rights reserved.
//

import AVKit

internal struct AssetManagerConstants {
    static var drmProxy = "https://example.com/drm"
    static var license =  "https://example.com/license"
}


class ContentKeyManager: NSObject,  AVContentKeySessionDelegate {
    
    static let shared  = ContentKeyManager()
    
    private var contentKeySession: AVContentKeySession!
    private var fpsCertificate: Data?
    private var downloadRequestByUser = false
    private var isOfflinePlayback = false
    var keyManager = DrmPersistableKeyManager()
    private var assetName: String!
    private let userDefaults: UserDefaultsManaging = DefaultUserDefaults()
    var keyRetrivalStrategy: KeyRetrivalStrategy!
    var certificateManager = CertificateManager()

    private override init() {
        super.init()
        self.createContentKeySession()
    }
    
    func createContentKeySession() {
        print("Creating new AVContentKeySession")
        contentKeySession = AVContentKeySession(keySystem: .fairPlayStreaming)
        contentKeySession.setDelegate(self, queue: DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).ContentKeyDelegateQueue"))
    }
    
    func addAsset(asset: AVURLAsset, assetName: String, isOfflinePlayback: Bool) {
        self.isOfflinePlayback = isOfflinePlayback
        self.assetName = assetName
        contentKeySession.addContentKeyRecipient(asset)
    }
    
    func handleOnlineContentKeyRequest(keyRequest: AVContentKeyRequest) {
        keyRetrivalStrategy = KeyRetrivalStrategyFactory.createKeyRetrivalStartegy(assetName: assetName, isOfflinePlayback: false, keyRequest: keyRequest, certifcateManager: certificateManager)

        keyRetrivalStrategy.retriveKey { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let keyResponse):
                guard let keyResponse = keyResponse else {return}
                keyRequest.processContentKeyResponse(keyResponse)
            case .failure(let failure):
                keyRequest.processContentKeyResponseError(failure)
            }
        }
    }
    
    func handleOfflineContentKeyRequest(keyRequest: AVPersistableContentKeyRequest) {
        
        keyRetrivalStrategy = KeyRetrivalStrategyFactory.createKeyRetrivalStartegy(assetName: assetName, isOfflinePlayback: isOfflinePlayback, keyRequest: keyRequest, certifcateManager: certificateManager)

        keyRetrivalStrategy.retriveKey { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let keyResponse):
                guard let keyResponse = keyResponse else {return}
                keyRequest.processContentKeyResponse(keyResponse)
            case .failure(let failure):
                keyRequest.processContentKeyResponseError(failure)
                
            }
        }
    }
    
    
}
// MARK: AVContentKeySessionDelegate methods
extension ContentKeyManager {
    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVContentKeyRequest) {
        handleOnlineContentKeyRequest(keyRequest: keyRequest)
    }
    
    func contentKeySession(_ session: AVContentKeySession, didProvideRenewingContentKeyRequest keyRequest: AVContentKeyRequest) {
        handleOnlineContentKeyRequest(keyRequest: keyRequest)
    }
    
    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVPersistableContentKeyRequest) {
        handleOfflineContentKeyRequest(keyRequest: keyRequest)
    }
    
    func requestContentKeyFromKeySecurityModule(spcData: Data, contentId: String, completion: @escaping (Data?) -> Void){
        let command = ContentKeyRequestFromKSM()
        command.execute(spcData: spcData, contentId: contentId, completion: completion)
    }
    
    func contentKeySession(_ session: AVContentKeySession, didUpdatePersistableContentKey persistableContentKey: Data, forContentKeyIdentifier keyIdentifier: Any) {
        guard let keyRetrivalStrategy = keyRetrivalStrategy as? OfflineKeyRetrivalStrategy else {return}
        keyRetrivalStrategy.handlePersistableContentKeyUpdate(persistableContentKey: persistableContentKey, keyIdentifier: keyIdentifier, assetName: assetName, keyManager: keyManager)
    
    }
    
}

// MARK: DrmError
enum DrmError: Error {
    case missingApplicationCertificate
    case missingApplicationCertificateUrl
    case missingAssetUrl
    case applicationCertificateRequestFailed
    case missingLicensingServiceUrl
    case noCKCReturnedByKSM
    case unableToGeneratePersistentKey
    case cannotEncodeCKCData
}



