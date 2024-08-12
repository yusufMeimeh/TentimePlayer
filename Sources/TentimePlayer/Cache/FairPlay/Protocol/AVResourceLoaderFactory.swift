//
//  AVResourceLoaderFactory.swift
//  
//
//  Created by Qamar Al Amassi on 08/08/2024.
//

import Foundation

struct AVAssetLoaderRetrivalStrategyFactory {
    static func createKeyRetrivalStartegy(assetName: String,
                                          url: URL,
                                          isOfflinePlayback: Bool,
                                          loadingRequest: AVAssetResourceLoadingRequestProtocol,
                                          certifcateManager: CertificateManager,
                                          keyManager: KeyManager = DrmPersistableKeyManager()) -> KeyRetrivalStrategy {
//        if isOfflinePlayback {
            return OfflineAVAssetResourceLoadingRequestStrategy(loadingRequest: loadingRequest, url: url, certifcateManager: certifcateManager,
                                                                keyManager: keyManager, assetName: assetName)
//        }else {
//            return OnlineAVAssetResourceLoadingRequestStrategy(loadingRequest: loadingRequest,
//                                                               url: url, certifcateManager: certifcateManager, keyManager: keyManager, assetName: assetName)
//        }
    }

}
