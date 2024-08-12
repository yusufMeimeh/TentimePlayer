//
//  OfflineKeyRetrivalStrategyTests.swift
//
//
//  Created by Qamar Al Amassi on 02/08/2024.
//

import XCTest
@testable import TentimePlayer

#if !targetEnvironment(simulator)

final class OfflineKeyRetrivalStrategyTests: XCTestCase {
    let nameTest = "Asset Test Name"
    let certificateDataSample =  "Mock Certificate Data"
    let spcDataSample =  "Mock Certificate Data"

    func testRetriveKeySuccess() {
        let mockContentKeyRequest = MockAVPersistableContentKeyRequest()
        
        let mockCertificateManager = MockCertificateManager()
        
        let offlineKeyRetirivalStratege =  OfflineKeyRetrivalStrategy(keyRequest: mockContentKeyRequest, assetName: nameTest, certifcateManager: mockCertificateManager)
        
        let expectedCertificate = certificateDataSample.data(using: .utf8)
    
        mockCertificateManager.persistCertificate(expectedCertificate!)
        
        mockContentKeyRequest.spcData = spcDataSample.data(using: .utf8)
        
        let expectation = self.expectation(description: "Retrieve Key")
        
        offlineKeyRetirivalStratege.retriveKey { result in
            switch result {
            case .success(let keyResponse):
                XCTAssertTrue(mockCertificateManager.loadCachedCertificateCalled)
                XCTAssertNotNil(keyResponse)
                expectation.fulfill()
            case .failure(let failure):
                XCTFail("Retrieve key failed with error: \(failure)")
            }
        }
        waitForExpectations(timeout: 5)

    }
    
    func testRetriveKeyFailedDueToMissingCertificate() {
        let mockKeyRequest = MockAVPersistableContentKeyRequest()
        
        let mockCertificateManager = MockCertificateManager()
        
        mockCertificateManager.containCertifcate = false
        
        let offlineKeyRetrivalStrategy = OfflineKeyRetrivalStrategy(keyRequest: mockKeyRequest, assetName: nameTest, certifcateManager: mockCertificateManager)
        
        let expectation = self.expectation(description: "Fail Retrieve Key")
        
        offlineKeyRetrivalStrategy.retriveKey { result in
            switch result {
            case .success(let keyResponse):
                XCTFail("Retrieve key should have failed due to missing certificate")
             
            case .failure(let error):
                XCTAssertEqual(error as? DrmError, DrmError.missingApplicationCertificate)
                XCTAssertTrue(mockCertificateManager.loadCachedCertificateCalled)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5)
    }
    
    func testRetriveKeyFailedDueToInvlidAsset() {
        let mockKeyRequest = MockAVPersistableContentKeyRequest()
        let mockCertificate = MockCertificateManager()
        // Simulate an invalid asset by setting an invalid URL
        mockKeyRequest.testIdntifier = "invalid://contentId"
        
        let offlineKeyRetrivalStrategy = OfflineKeyRetrivalStrategy(keyRequest: mockKeyRequest, assetName: nameTest, certifcateManager: mockCertificate)
        
        
        let expectation = self.expectation(description: "Fail Retrieve Key")
        
        offlineKeyRetrivalStrategy.retriveKey { result in
            switch result {
            case .success(let keyResponse):
                XCTFail("Retrieve key should have failed due to missing AssetUrl")
            case .failure(let error):
                XCTAssertEqual(error as? DrmError, DrmError.missingAssetUrl)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5)
    }
}
#endif

