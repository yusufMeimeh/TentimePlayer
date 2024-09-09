//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 14/07/2024.
//

import AVKit

struct OnlineAVAssetResourceLoadingRequestStrategy: KeyRetrivalStrategy {

    var loadingRequest: AVAssetResourceLoadingRequestProtocol
    var url: URL
    var certifcateManager: CertificateManaging
    var keyManager: KeyManager
    var assetName: String
    let contentKeyRequest: ContentKeyRequestCommand

    func retriveKey(completion: @escaping (Result<AVContentKeyResponse?, any Error>) -> Void) {
        let contentId = url.host
        //handle missing certificate
        guard let fpsCertificate = certifcateManager.loadCachedCertificate() else {
            completion(.failure(DrmError.missingApplicationCertificate))
            loadingRequest.finishLoading(with: DrmError.missingApplicationCertificate)
            return
        }
        guard
         let contentId = contentId,
          let contentIdData = contentId.data(using: String.Encoding.utf8)
        else {
              completion(.failure(DrmError.missingAssetUrl))
              loadingRequest.finishLoading(with: DrmError.missingAssetUrl)
              return
          }
        guard let  spcData = try? loadingRequest.streamingContentKeyRequestData(forApp: fpsCertificate, contentIdentifier: contentIdData, options: nil) else {
            completion(.failure(DrmError.noCKCReturnedByKSM))
            loadingRequest.finishLoading(with: DrmError.noCKCReturnedByKSM)

            return
        }

        contentKeyRequest.execute(spcData: spcData, contentId: contentId) { data in
            guard let ckcData = data else {
                completion(.failure(DrmError.noCKCReturnedByKSM))
                loadingRequest.finishLoading(with: DrmError.cannotEncodeCKCData)

                return
            }
             var persistentKeyData: Data?
             let dataRequest = loadingRequest.dataRequest!

             do {
                  persistentKeyData = try loadingRequest.persistentContentKey(fromKeyVendorResponse: ckcData)
             } catch {
                 print("Failed to get persistent key with error: \(error)")
                  loadingRequest.finishLoading(with: DrmError.unableToGeneratePersistentKey)
                 completion(.failure(DrmError.unableToGeneratePersistentKey))
             }
             
             guard let persistentKeyData = persistentKeyData else {return}
             // set type of the key
             loadingRequest.contentInformationRequest?.contentType = AVStreamingKeyDeliveryPersistentContentKeyType
             dataRequest.respond(with: persistentKeyData)
             guard let contentIdentifier = contentId.replacingOccurrences(of: "skd://", with: "") as String?
             else {
                 print("Failed to retrieve the assetID from the keyRequest!")
                 return
             }
             do {
                try self.keyManager.writePersistableContentKey(contentKey: persistentKeyData, withAssetName: self.assetName, withContentKeyIV: contentIdentifier)
             } catch {
                 print("Cannot save content key", error)
             }
             loadingRequest.finishLoading()
             completion(.success(nil))
        }
    }
}
