//
//  KeyAssetRetrivalStrategy.swift
//  
//
//  Created by Qamar Al Amassi on 02/08/2024.
//

import AVFoundation

protocol AssetKeyHandler {
    func addAsset(name: String, isOfflinePlayback: Bool, asset: AVURLAsset)
}


class SimulatorAssetKeyHandler: AssetKeyHandler {
    func addAsset(name: String, isOfflinePlayback: Bool, asset: AVURLAsset) {
        AssetLoaderDeleagte.shared.addAsset(assetName: name,
                                            isOfflinePlayback: isOfflinePlayback,
                                            downloadRequestByUser: isOfflinePlayback,
                                            asset: asset)
    }
}

class DeviceAssetKeyHandler: AssetKeyHandler {
    func addAsset(name: String, isOfflinePlayback: Bool, asset: AVURLAsset) {
        ContentKeyManager.shared.addAsset(asset: asset, assetName: name, isOfflinePlayback: isOfflinePlayback)
    }
}
