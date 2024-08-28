//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 12/08/2024.
//

import Foundation

class ManagerFactory {
    static func createAssetLoadManager() -> PlayerAssetManager {
         let keyHandler: AssetKeyHandler
         #if targetEnvironment(simulator)
         keyHandler = SimulatorAssetKeyHandler()
         #else
         keyHandler = DeviceAssetKeyHandler()
         #endif
         return PlayerAssetManager(keyHandler: keyHandler)
     }
}
