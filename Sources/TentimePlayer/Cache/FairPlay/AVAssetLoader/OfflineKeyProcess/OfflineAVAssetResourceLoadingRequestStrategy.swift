//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 14/07/2024.
//

import AVKit
struct OfflineAVAssetResourceLoadingRequestStrategy: KeyRetrivalStrategy {
    
    var loadingRequest: AVAssetResourceLoadingRequestProtocol
    var url: URL
    var certifcateManager: CertificateManaging
    var keyManager: KeyManager
    var assetName: String
    
    func retriveAVResourceLoaderKey(completion: @escaping (Result<Data?, any Error>) -> Void) {
        //handle missing certificate
        guard certifcateManager.loadCachedCertificate() != nil else {
            loadingRequest.finishLoading(with: DrmError.missingApplicationCertificate)
            completion(.failure(DrmError.missingApplicationCertificate))
            return
        }
        guard let contentId = url.host,
              let contentIdentifier = contentId.replacingOccurrences(of: "skd://", with: "") as String?
        else {
            loadingRequest.finishLoading(with: DrmError.missingAssetUrl)
            completion(.failure(DrmError.missingAssetUrl))
            return
        }
        if let contentKey = keyManager.getPersistableContentKey(withAssetName: assetName, withContentKeyIV: contentIdentifier) {
            loadingRequest.contentInformationRequest?.contentType = AVStreamingKeyDeliveryPersistentContentKeyType
            let dataRequest = loadingRequest.dataRequest 
            dataRequest?.respond(with: contentKey)
            loadingRequest.finishLoading()
            completion(.success(contentKey))
            return
        }else {
            loadingRequest.finishLoading(with: DrmError.unableToGeneratePersistentKey)
            completion(.failure(DrmError.unableToGeneratePersistentKey))
        }
    }
    
    
}
