//
//  DRMManager.swift
//
//
//  Created by Qamar Al Amassi on 12/08/2024.
//

import Foundation

class DRMManager {
    func configureDRM(drmProxy: String, licenseURL: String) {
        AssetManagerConstants.drmProxy = drmProxy
        AssetManagerConstants.license = licenseURL
    }
}
