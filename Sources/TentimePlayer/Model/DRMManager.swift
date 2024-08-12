//
//  DRMManager.swift
//
//
//  Created by Qamar Al Amassi on 12/08/2024.
//

import Foundation

class DRMManager {
    private var licenseURL: URL?
    private var certificate: Data?


    func configureDRM(licenseURL: URL, certificate: Data) {
        self.licenseURL = licenseURL
        self.certificate = certificate
    }

}
