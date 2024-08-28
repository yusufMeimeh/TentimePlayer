//
//  OnlineAVAsseResourceLoaderTests.swift
//
//
//  Created by Qamar Al Amassi on 25/08/2024.
//

import XCTest
@testable import TentimePlayer

class OnlineAVAsseResourceLoaderTests: XCTestCase {

      func testSuccessfulKeyRetrieval() {
          // Setup mock objects
          let loadingRequest = MockAVAssetResourceLoadingRequest()
          let certificateManager = MockCertificateManager()
          let keyManager = MockKeyManager()
          let url = URL(string: "https://example.com/video")!

          // Mock the required data
          certificateManager.storedCertificate = Data()
          loadingRequest.dataResult = Data(base64Encoded: "mockedSPCData")

          let strategy = OnlineAVAssetResourceLoadingRequestStrategy(
              loadingRequest: loadingRequest,
              url: url,
              certifcateManager: certificateManager,
              keyManager: keyManager,
              assetName: "TestAsset"
          )

          let expectation = XCTestExpectation(description: "Completion called")

          strategy.retriveKey { result in
              switch result {
              case .success(let response):
                  XCTAssertNil(response)
                  XCTAssertTrue(loadingRequest.finishCalled)
              case .failure:
                  XCTFail("Expected success, but got failure")
              }
              expectation.fulfill()
          }
          wait(for: [expectation], timeout: 0.5)
      }
}
