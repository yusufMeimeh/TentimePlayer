//
//  PlayerAssetManagerTests.swift
//
//
//  Created by Qamar Al Amassi on 02/08/2024.
//

import XCTest
import AVKit
@testable import TentimePlayer


class PlayerAssetManagerTests: XCTestCase {
    
    func testIsPlayableKeyIsAddedToKeysArray() {
        let mockKeyHandler = MockAssetKeyHandler()
        let assetManager = PlayerAssetManager(keyHandler: mockKeyHandler)
        
        guard let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else {
            XCTFail("Invalid URL")
            return
        }
        
        var keys = ["someKey"]
        
        // Use XCTestExpectation to test asynchronous behavior
        let expectation = self.expectation(description: "Check isPlayable Key Added")
        
        assetManager.loadAsset(name: "Test Movie", url: url, isOfflinePlayback: false, with: &keys) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Loading asset failed")
            }
        }
        
        waitForExpectations(timeout: 5) { _ in
            // Check that 'isPlayable' key was added to keys array
            XCTAssertTrue(keys.contains(#keyPath(AVAsset.isPlayable)), "'isPlayable' key must be included in the keys array")
        }
    }
    
    func testLoadAssetWithValidURL() {
        let mockKeyHandler = MockAssetKeyHandler()
        let assetManager = PlayerAssetManager(keyHandler: mockKeyHandler)
        
        let expectation = self.expectation(description: "Asset Loaded")
        
        let validURL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        var keys: [String] = ["someKey"]
        
        assetManager.loadAsset(name: "Valid Movie", url: validURL, isOfflinePlayback: false, with: &keys) { result in
            switch result {
            case .success(let asset):
                XCTAssertTrue(mockKeyHandler.addAssetCalled)
                XCTAssertEqual(mockKeyHandler.lastAsset, asset)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Loading asset failed with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        // Check that 'isPlayable' key was added to keys array
        XCTAssertTrue(keys.contains(#keyPath(AVAsset.isPlayable)), "'isPlayable' key must be included in the keys array")
    }
    
    func testLoadAssetWithInValidURL() {
        let mockKeyHandler = MockAssetKeyHandler()
        let assetManager = PlayerAssetManager(keyHandler: mockKeyHandler)
        
        let expectation = self.expectation(description: "Asset Load Failed")
        
        let inValidURL = URL(string: "https://www.example.com/invalid_video.mp4")!
        var keys: [String] = ["someKey"]
        
        assetManager.loadAsset(name: "Valid Movie", url: inValidURL, isOfflinePlayback: false, with: &keys) { result in
            switch result {
            case .success(_):
                XCTFail("Loading asset succeeded unexpectedly")
                expectation.fulfill()
            case .failure(let error):
                XCTAssertEqual(error as? PlayerAssetManager.AssetError
                               ,PlayerAssetManager.AssetError.failed)
                             expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        // Check that 'isPlayable' key was added to keys array
        XCTAssertTrue(keys.contains(#keyPath(AVAsset.isPlayable)), "'isPlayable' key must be included in the keys array")
    }
    
}
