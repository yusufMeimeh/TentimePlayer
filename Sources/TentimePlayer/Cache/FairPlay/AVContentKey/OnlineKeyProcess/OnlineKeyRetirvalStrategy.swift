//
//  OnlineKeyRetirveStrategy.swift
//  TenTime
//
//  Created by Qamar Al Amassi on 11/07/2024.
//  Copyright © 2024 TenTime. All rights reserved.
//

import AVKit

struct OnlineAVContentKeyRetrivalStrategy: KeyRetrivalStrategy {
     var keyRequest: AVContentKeyRequest
     var certifcateManager: CertificateManager

    func retriveKey(completion: @escaping (Result<AVContentKeyResponse?,  Error>) -> Void) {
        
        //Handle url error
        guard let contentKeyIdentifierString = keyRequest.identifier as? String,
              let contentIdentifier = contentKeyIdentifierString.replacingOccurrences(of: "skd://", with: "").data(using: .utf8) else {
            completion(.failure(DrmError.missingAssetUrl))
            return
        }
        
        //handle missing certificate
        guard let fpsCertificate = certifcateManager.fetchCertificate() else {
            completion(.failure(DrmError.missingApplicationCertificate))
            return
        }
        
        //prepare request
        keyRequest.makeStreamingContentKeyRequestData(forApp: fpsCertificate, contentIdentifier: contentIdentifier, options: [AVContentKeyRequestProtocolVersionsKey: [1]]) { spcData, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let spcData = spcData else {
                completion(.failure(DrmError.noCKCReturnedByKSM))
                return
            }
            
            ContentKeyManager.shared.requestContentKeyFromKeySecurityModule(spcData: spcData, contentId: contentKeyIdentifierString) { data in
                guard let ckcData = data else {
                    completion(.failure(DrmError.noCKCReturnedByKSM))
                    return
                }
                let keyResponse = AVContentKeyResponse(fairPlayStreamingKeyResponseData: ckcData)
                completion(.success(keyResponse))
            }
            
            
      
        }
              
    }
    
   
}
