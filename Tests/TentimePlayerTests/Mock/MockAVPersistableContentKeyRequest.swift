//
//  MockAVPersistableContentKeyRequest.swift
//
//
//  Created by Qamar Al Amassi on 02/08/2024.
//

import AVKit

enum MockKeyRequestError: Error {
    case invalidAppCertificate
    case invalidContentIdentifier
    case spcDataGenerationFailed
}

class MockAVPersistableContentKeyRequest: AVPersistableContentKeyRequest {
    var spcData: Data?
    var spcDataError: Error?
    var shouldFailDueToAppCertificate = false
    var shouldFailDueToContentIdentifier = false
    
    var testIdntifier: String = "asset_id"
    override var identifier: Any? {
        return testIdntifier
    }
    
    override func makeStreamingContentKeyRequestData(forApp appCertificate: Data, contentIdentifier: Data?, options: [String : Any]? = nil, completionHandler handler: @escaping (Data?, Error?) -> Void) {
        if shouldFailDueToAppCertificate {
            handler(nil, MockKeyRequestError.invalidAppCertificate)
            return
        }
        
        if shouldFailDueToContentIdentifier {
            handler(nil, MockKeyRequestError.invalidContentIdentifier)
            return
        }
        
        handler(spcData, spcDataError)
    }
}
