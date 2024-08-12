//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 08/08/2024.
//

import Foundation
@testable import TentimePlayer
class MockKeyManager: KeyManager {

    var persistableContentKeys: [String: Data] = [:]
    var shouldThrowErrorOnWrite = false

    func writePersistableContentKey(contentKey: Data, withAssetName assetName: String, withContentKeyIV keyIV: String) throws {
        if shouldThrowErrorOnWrite {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        let key = "\(assetName)-\(keyIV)"
        persistableContentKeys[key] = contentKey
    }

    func deletePersistableContentKey(withAssetName assetName: String, withContentKeyId keyId: String) {
        let contentIdentifier = keyId.replacingOccurrences(of: "skd://", with: "")
        let key = "\(assetName)-\(contentIdentifier)"
        persistableContentKeys.removeValue(forKey: key)
    }

    func persistableContentKeyExistsOnDisk(withAssetName assetName: String, withContentKeyIV keyIV: String) -> Bool {
        let key = "\(assetName)-\(keyIV)"
        return persistableContentKeys[key] != nil
    }

    func getPersistableContentKey(withAssetName assetName: String, withContentKeyIV keyIV: String) -> Data? {
        let key = "\(assetName)-\(keyIV)"
        return persistableContentKeys[key]
    }

}
