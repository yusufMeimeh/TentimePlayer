//
//  DRMManager.swift
//
//
//  Created by Qamar Al Amassi on 12/08/2024.
//

import Foundation

class DRMManager {
    func configureDRM(licenseURL: String, certificate: String) {
        AssetManagerConstants.drmProxy = licenseURL
        AssetManagerConstants.license = certificate
    }
}
