//
//  File.swift
//
//
//  Created by Qamar Al Amassi on 08/08/2024.
//

import XCTest
import AVKit
@testable import TentimePlayer

class OfflineAVAsseResourceLoaderTests: XCTestCase {
    var nameTest = "Asset Test Name"
    var contentIdentifier = "assetId"
    func testRetrieveKeyFailsDueToMissingCertificate() {
        let mockReuqest = MockAVAssetResourceLoadingRequest()
        let mockCertificateManager = MockCertificateManager()
        let mockKeyManager = MockKeyManager()
        mockCertificateManager.containCertifcate = false
        let offlineStrategy = OfflineAVAssetResourceLoadingRequestStrategy(
            loadingRequest: mockReuqest,
            url: URL(string: "skd://assetId")!,
            certifcateManager: mockCertificateManager,
            keyManager: mockKeyManager,
            assetName: nameTest)

        let expectation = self.expectation(description: "Retrieve key should fail due to missing certificate")

        offlineStrategy.retriveAVResourceLoaderKey { result in
            switch result {
            case .success(_) :
                XCTFail("Retrieve key should have failed due to missing certificate")
            case .failure(let error):
                XCTAssertEqual(error as? DrmError, DrmError.missingApplicationCertificate)
                XCTAssertTrue(mockCertificateManager.loadCachedCertificateCalled)
                XCTAssertNil(mockCertificateManager.storedCertificate)
                XCTAssertFalse(mockReuqest.finishCalled)
                XCTAssertTrue(mockReuqest.finishWithErrorCalled)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.5)
    }

    func testRetrieveKeyFailsDueToMissingAssetUrl() {
        let mockLoadingRequest = MockAVAssetResourceLoadingRequest()
        let mockCertificateManager = MockCertificateManager()
        let mockKeyManager = MockKeyManager()

        let strategy = OfflineAVAssetResourceLoadingRequestStrategy(
            loadingRequest: mockLoadingRequest,
            url: URL(string: "invalidURL")!,
            certifcateManager: mockCertificateManager,
            keyManager: mockKeyManager,
            assetName: "TestAsset"
        )

        let expectation = self.expectation(description: "Retrieve key should fail due to missing asset URL")

        strategy.retriveAVResourceLoaderKey { result in
            switch result {
            case .success:
                XCTFail("Retrieve key should have failed due to missing asset URL")
            case .failure(let error):
                XCTAssertEqual(error as? DrmError, DrmError.missingAssetUrl)
                XCTAssertFalse(mockLoadingRequest.finishCalled)
                XCTAssertTrue(mockLoadingRequest.finishWithErrorCalled)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testStreamingContentKeyRequestDataError() {
        let mockReuqest = MockAVAssetResourceLoadingRequest()
        mockReuqest.shouldThrowError = true
        mockReuqest.errorToThrow = DrmError.cannotEncodeCKCData
        let mockCertificateManager = MockCertificateManager()
        let mockKeyManager = MockKeyManager()

        let expectation = self.expectation(description: "Retrieve key should fail due to Data error")

        let offlineStrategy = OfflineAVAssetResourceLoadingRequestStrategy(
            loadingRequest: mockReuqest,
            url: URL(string: "skd://assetId")!,
            certifcateManager: mockCertificateManager,
            keyManager: mockKeyManager,
            assetName: nameTest)

        offlineStrategy.retriveAVResourceLoaderKey { result in
            switch result {
            case .success(_) :
                XCTFail("Retrieve key should have failed due to missing certificate")
            case .failure(let error):
                XCTAssertEqual(error as? DrmError,  DrmError.unableToGeneratePersistentKey)
                XCTAssertFalse(mockReuqest.finishCalled)
                XCTAssertTrue(mockReuqest.finishWithErrorCalled)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.5)
    }

    func testStreamingContentKeyRequestSuccess() {
        let mockReuqest = MockAVAssetResourceLoadingRequest()
        let mockCertificateManager = MockCertificateManager()
        let mockKeyManager = MockKeyManager()
        // Initialize the mock data request and content information request
        let expectation = self.expectation(description: "Retrieve key should success")

        let offlineStrategy = OfflineAVAssetResourceLoadingRequestStrategy(
            loadingRequest: mockReuqest,
            url: URL(string: "skd://\(contentIdentifier)")!,
            certifcateManager: mockCertificateManager,
            keyManager: mockKeyManager,
            assetName: nameTest)
        
        simulateWritingNewPersistableKey(
            keyManager: mockKeyManager,
            loadingRequest: mockReuqest)

        offlineStrategy.retriveAVResourceLoaderKey { result in
            switch result {
            case .success(let data) :
                XCTAssertFalse(mockReuqest.finishWithErrorCalled)
                XCTAssertTrue(mockReuqest.finishCalled)
            case .failure(let error):
                print("Error is ",  error)
                XCTFail("Retrieve key shouldnot fail")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.5)
    }

    private func simulateWritingNewPersistableKey(
        keyManager: MockKeyManager,
        loadingRequest: MockAVAssetResourceLoadingRequest) {
            let newContentKey = Data("newContentKeyData".utf8)
            do {
                try keyManager.writePersistableContentKey(contentKey: newContentKey, withAssetName: nameTest, withContentKeyIV: contentIdentifier)
            } catch {
                XCTFail("Simulating writing new persistable key failed")
            }
        }

}
