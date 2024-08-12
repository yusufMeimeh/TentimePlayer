//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 13/07/2024.
//

import Foundation

protocol CertificateManaging {
    func loadCachedCertificate() -> Data?
    func persistCertificate(_ data: Data)
    func fetchCertificate() -> Data?
}

struct CertificateManager: CertificateManaging {
    private let userDefaults: UserDefaultsManaging
    private let networkFetcher: NetwrokFetching

    init(userDefaults: UserDefaultsManaging = DefaultUserDefaults()
         , networkFetcher: NetwrokFetching = NetwrokFetcher()) {
         self.userDefaults = userDefaults
         self.networkFetcher = networkFetcher
     }
     
     func loadCachedCertificate() -> Data? {
         return userDefaults.data(forKey: "fps_certificate_\(AssetManagerConstants.license)")
     }
     
     func persistCertificate(_ data: Data) {
         userDefaults.set(data, forKey: "fps_certificate_\(AssetManagerConstants.license)")
     }
     
     func fetchCertificate() -> Data? {
         if let certificate = loadCachedCertificate() {
             return certificate
         }
         
         guard let url = URL(string: AssetManagerConstants.license),
               let certificateData = networkFetcher.fetchData(from: url)  else {
             return nil
         }
         
        
         persistCertificate(certificateData)
         return certificateData
     }
}
