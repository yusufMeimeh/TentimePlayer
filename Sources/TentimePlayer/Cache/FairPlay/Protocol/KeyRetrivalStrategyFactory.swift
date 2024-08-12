//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 11/07/2024.
//

import AVKit

struct KeyRetrivalStrategyFactory {
    static func createKeyRetrivalStartegy(assetName: String,
                                          isOfflinePlayback: Bool,
                                          keyRequest: AVContentKeyRequest,
                                          certifcateManager: CertificateManager) -> KeyRetrivalStrategy {
        if isOfflinePlayback {
            return OfflineKeyRetrivalStrategy(keyRequest: keyRequest as! AVPersistableContentKeyRequest, assetName: assetName, certifcateManager: certifcateManager)
        }else {
            return OnlineAVContentKeyRetrivalStrategy(keyRequest: keyRequest, certifcateManager: certifcateManager)
        }
    }
    
 
}
