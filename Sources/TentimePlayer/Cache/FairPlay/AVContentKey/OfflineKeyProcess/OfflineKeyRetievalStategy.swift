//
//  File.swift
//
//
//  Created by Qamar Al Amassi on 11/07/2024.
//

import Foundation
import AVKit

struct OfflineKeyRetrivalStrategy: KeyRetrivalStrategy, PersistableContentKeyUpdateStrategy {
    var keyRequest: AVPersistableContentKeyRequest
    var assetName: String
    var certifcateManager: CertificateManaging

    func retriveKey(completion: @escaping (Result<AVContentKeyResponse?, any Error>) -> Void) {
        
        //Handle url error
        guard let contentKeyIdentifierString = keyRequest.identifier as? String,
              let contentIdentifier = contentKeyIdentifierString.replacingOccurrences(of: "skd://", with: "").data(using: .utf8) else {
            completion(.failure(DrmError.missingAssetUrl))
            return
        }
        
        //handle missing certificate
        guard let fpsCertificate = certifcateManager.loadCachedCertificate() else {
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
            
            ContentKeyManager.shared.requestContentKeyFromKeySecurityModule(spcData: spcData, contentId: contentKeyIdentifierString, completion: { data in
                guard let ckcData = data else {
                    completion(.failure(DrmError.noCKCReturnedByKSM))
                    return
                }
                do {
                    let persistentKey = try keyRequest.persistableContentKey(fromKeyVendorResponse: ckcData)
                    try ContentKeyManager.shared.keyManager.writePersistableContentKey(contentKey: persistentKey, withAssetName: assetName, withContentKeyIV: contentKeyIdentifierString)
                    
                    let keyResponse = AVContentKeyResponse(fairPlayStreamingKeyResponseData: persistentKey)
                    completion(.success(keyResponse))
                } catch {
                    completion(.failure(error))
                    
                }
            })
            
            
        }
        
    }
    
    func handlePersistableContentKeyUpdate(persistableContentKey: Data, keyIdentifier: Any, assetName: String, keyManager: KeyManager) {
        do {
            guard let contentKeyIdentifierString = keyIdentifier as? String,
                  let contentIdentifier = contentKeyIdentifierString.replacingOccurrences(of: "skd://", with: "") as String? else {
                print("ERROR: Failed to retrieve the contentIdentifier")
                return
            }
            
            keyManager.deletePersistableContentKey(withAssetName: assetName, withContentKeyId: contentIdentifier)
            print("Deleted existing persistable content key for \(assetName) - \(contentIdentifier)")
            
            try keyManager.writePersistableContentKey(contentKey: persistableContentKey, withAssetName: assetName, withContentKeyIV: contentIdentifier)
            print("Wrote updated persistable content key to disk for \(assetName) - \(contentIdentifier)")
        } catch {
            print("ERROR: Failed to write updated persistable content key to disk: \(error.localizedDescription)")
        }
    }
}


