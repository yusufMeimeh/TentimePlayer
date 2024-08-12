//
//  AVAssetResourceLoadingRequestWrapper.swift
//
//
//  Created by Qamar Al Amassi on 08/08/2024.
//

import AVKit

class AVAssetResourceLoadingRequestWrapper: AVAssetResourceLoadingRequestProtocol {

    private let loadingRequest: AVAssetResourceLoadingRequest

    init(loadingRequest: AVAssetResourceLoadingRequest) {
        self.loadingRequest = loadingRequest
    }

    var contentInformationRequest: AVAssetResourceLoadingContentInformationRequest? {
        return loadingRequest.contentInformationRequest
    }

    var dataRequest: AVAssetResourceLoadingDataRequest? {
        return loadingRequest.dataRequest
    }

    func finishLoading(with error: Error?) {
        loadingRequest.finishLoading(with: error)
    }

    func finishLoading() {
        loadingRequest.finishLoading()
    }

    func streamingContentKeyRequestData(forApp appCertificate: Data, contentIdentifier: Data, options: [String: Any]?) throws -> Data {
        return try loadingRequest.streamingContentKeyRequestData(forApp: appCertificate, contentIdentifier: contentIdentifier, options: options)
    }

    func persistentContentKey(fromKeyVendorResponse: Data) throws -> Data {
      return  try loadingRequest.persistentContentKey(fromKeyVendorResponse: fromKeyVendorResponse)
    }
}
