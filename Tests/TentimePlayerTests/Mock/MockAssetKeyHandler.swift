//
//  MockAssetKeyHandler.swift
//  
//
//  Created by Qamar Al Amassi on 02/08/2024.
//

import AVKit
@testable import TentimePlayer

class MockAssetKeyHandler: AssetKeyHandler {
    var addAssetCalled = false
    var lastAsset: AVURLAsset?
    
    func addAsset(name: String, isOfflinePlayback: Bool, asset: AVURLAsset) {
        addAssetCalled = true
        lastAsset = asset
    }
}
