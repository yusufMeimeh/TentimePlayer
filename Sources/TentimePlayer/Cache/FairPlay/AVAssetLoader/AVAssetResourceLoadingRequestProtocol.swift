//
//  AVAssetResourceLoadingRequestProtocol.swift
//
//
//  Created by Qamar Al Amassi on 08/08/2024.
//

import AVFoundation

protocol AVAssetResourceLoadingRequestProtocol {
    var contentInformationRequest: AVAssetResourceLoadingContentInformationRequest? { get }
      var dataRequest: AVAssetResourceLoadingDataRequest? { get }
      func finishLoading(with error: Error?)
      func finishLoading()
      func streamingContentKeyRequestData(forApp appCertificate: Data, contentIdentifier: Data, options: [String: Any]?) throws -> Data
      func persistentContentKey(fromKeyVendorResponse: Data) throws -> Data
}
