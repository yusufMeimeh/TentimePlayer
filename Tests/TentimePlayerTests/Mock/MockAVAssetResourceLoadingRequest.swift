//
//  MockAVAssetResourceLoadingRequest.swift
//
//
//  Created by Qamar Al Amassi on 08/08/2024.
//

import AVKit
@testable import TentimePlayer

class MockAVAssetResourceLoadingRequest: AVAssetResourceLoadingRequestProtocol {
    var _contentInformationRequest: AVAssetResourceLoadingContentInformationRequest?
    var _dataRequest: AVAssetResourceLoadingDataRequest?

    var contentInformationRequest: AVAssetResourceLoadingContentInformationRequest? {
        return _contentInformationRequest
    }

    var dataRequest: AVAssetResourceLoadingDataRequest? {
        return _dataRequest
    }

    var errorToThrow: Error?
    var finishWithErrorCalled = false
    var finishCalled = false
    var dataResult: Data?

    var shouldThrowError: Bool = false

    func finishLoading(with error: Error?) {
        self.errorToThrow = error
        finishWithErrorCalled = true
    }

    func finishLoading() {
        finishCalled = true
    }

    func streamingContentKeyRequestData(forApp appCertificate: Data, contentIdentifier: Data, options: [String: Any]?) throws -> Data {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        dataResult =  Data("mockSPCData".utf8)
        return dataResult!
    }

    func persistentContentKey(fromKeyVendorResponse: Data) throws -> Data {
        throw NSError(domain: "MockError", code: 1, userInfo: nil)
    }
}
