//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 05/07/2024.
//

import Foundation
import UIKit

protocol KeyManager {
    func writePersistableContentKey(contentKey: Data, withAssetName assetName: String, withContentKeyIV keyIV: String) throws
    func deletePersistableContentKey(withAssetName assetName: String, withContentKeyId keyId: String)
    func persistableContentKeyExistsOnDisk(withAssetName assetName: String, withContentKeyIV keyIV: String) -> Bool
    func getPersistableContentKey(withAssetName assetName: String, withContentKeyIV keyIV: String) -> Data?
}

struct DrmPersistableKeyManager: KeyManager {
    
    let fileManager: FileManaging
    let userDefaults: UserDefaultsManaging
    var contentKeyDirectory: URL
    
    init(fileManager: FileManaging = DefaultFileManager(),
         userDefaults: UserDefaultsManaging = DefaultUserDefaults()) {
            self.fileManager = fileManager
            self.userDefaults = userDefaults
            self.contentKeyDirectory = fileManager.setupContentKeyDirectory(name: ".keys")
    }
    
    private func urlForPersistableContentKey(withAssetName assetName: String, withContentKeyIV keyIV: String) -> URL {
        return contentKeyDirectory.appendingPathComponent("\(assetName)-\(keyIV)-Key")
    }
  
    func persistableContentKeyExistsOnDisk(withAssetName assetName: String, withContentKeyIV keyIV: String) -> Bool {
        let contentKeyURL = urlForPersistableContentKey(withAssetName: assetName, withContentKeyIV: keyIV)
        return fileManager.fileExists(atPath: contentKeyURL.path)
    }
    
    func writePersistableContentKey(contentKey: Data, withAssetName assetName: String, withContentKeyIV keyIV: String) throws {
        let contentKeyURL = urlForPersistableContentKey(withAssetName: assetName, withContentKeyIV: keyIV)
        try fileManager.write(contentKey, at: contentKeyURL, options: .atomic)
        print("Wrote persistable content key to disk for \(assetName) to location: \(contentKeyURL)")
    }
    
    func deletePersistableContentKey(withAssetName assetName: String, withContentKeyId keyId: String) {
        let contentIdentifier = keyId.replacingOccurrences(of: "skd://", with: "")
        
        if persistableContentKeyExistsOnDisk(withAssetName: assetName, withContentKeyIV: contentIdentifier) {
            print("Deleting content key for \(assetName) - \(contentIdentifier): Persistable content key exists on disk")
        } else {
            print("Deleting content key for \(assetName) - \(contentIdentifier): No persistable content key exists on disk")
            return
        }
        
        let contentKeyURL = urlForPersistableContentKey(withAssetName: assetName, withContentKeyIV: contentIdentifier)
        
        do {
            try fileManager.removeItem(at: contentKeyURL)
           userDefaults.removeObject(forKey: "\(assetName)-\(contentIdentifier)-Key")
            print("Persistable Key for \(assetName)-\(contentIdentifier) was deleted")
        } catch {
            print("An error occurred removing the persisted content key: \(error)")
        }
    }
    
    func getPersistableContentKey(withAssetName assetName: String, withContentKeyIV keyIV: String) -> Data? {
        let urlToPersistableKey = urlForPersistableContentKey(withAssetName: assetName, withContentKeyIV: keyIV)
        
        guard let contentKey = fileManager.contents(atPath: urlToPersistableKey.path) else {
            return nil
        }
        
        print("Persistable key already exists on disk at location: \(urlToPersistableKey.path)")
        return contentKey
    }
}
