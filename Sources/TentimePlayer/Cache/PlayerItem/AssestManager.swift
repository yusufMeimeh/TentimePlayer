//
//  File.swift
//
//
//  Created by Qamar Al Amassi on 13/07/2024.
//

import UIKit
import AVFoundation
protocol AssetManager {
    func loadAsset(name: String, url: URL, isOfflinePlayback: Bool, with keys: inout [String], completion: @escaping (Result<AVURLAsset, Error>) -> Void)
}



class PlayerAssetManager: AssetManager {
    private var keyHandler: AssetKeyHandler
    
    init(keyHandler: AssetKeyHandler) {
        self.keyHandler = keyHandler
    }
    
    func loadAsset(name: String, url: URL,isOfflinePlayback: Bool, with keys: inout [String], completion: @escaping (Result<AVURLAsset, Error>) -> Void) {
        let asset = AVURLAsset(url: url)
        if !keys.contains(#keyPath(AVAsset.isPlayable)) {
            keys.append(#keyPath(AVAsset.isPlayable))
        }
        asset.loadValuesAsynchronously(forKeys: keys) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: #keyPath(AVAsset.isPlayable), error: &error)
            switch status {
            case .loaded:
                self.keyHandler.addAsset(name: name, isOfflinePlayback: isOfflinePlayback, asset: asset)
                
                completion(.success(asset))
                
            case .failed:
                completion(.failure(AssetError.failed))
            case .cancelled:
                completion(.failure(AssetError.cancelled))
            default: ()
            }
        }
    }
    enum AssetError: Error {
        case failed, cancelled
    }
}
