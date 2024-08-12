//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 02/08/2024.
//

import Foundation
@testable import TentimePlayer

class MockCertificateManager: CertificateManaging {
    var containCertifcate: Bool = true
    var storedCertificate: Data?

    var loadCachedCertificateCalled = false
    var persistCertificateCalled = false
    var fetchCertificateCalled = false
    
    func loadCachedCertificate() -> Data? {
        loadCachedCertificateCalled = true
        return containCertifcate ? "Mock license certificate".data(using: .utf8) : nil
    }
    
    func persistCertificate(_ data: Data) {
        persistCertificateCalled = true
        storedCertificate = data
    }
    
    func fetchCertificate() -> Data? {
        fetchCertificateCalled = true
        return containCertifcate ? "Mock license certificate".data(using: .utf8) : nil

    }
    
    
}
