//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 02/08/2024.
//

import XCTest
@testable import TentimePlayer

final class CertificateManagerTests: XCTestCase {
    
    func fetchCertificate() {
        let mockUserDefaults = MockUserDefaultManaging()
        let networkFetcher = MockNetworkFetcher()
        let certificateManager = CertificateManager(userDefaults: mockUserDefaults, networkFetcher: networkFetcher)

        let expectedCertificate = "Mock Certificate Data".data(using: .utf8)

        let certificate = certificateManager.fetchCertificate()
        let userDefaultCertificate = mockUserDefaults.data(forKey: "fps_certificate_\(AssetManagerConstants.license)")
            
        XCTAssertEqual(certificate, expectedCertificate)
        XCTAssertEqual(userDefaultCertificate, expectedCertificate)
        
        //Make sure he called network fetch methon
        XCTAssertEqual(networkFetcher.fetchDataCalled, true)

    }
    
    func testLoadCachedCertificate() {
        let mockUserDefaults = MockUserDefaultManaging()
        let certificateManager = CertificateManager(userDefaults: mockUserDefaults)

        let expectedCertificate = "Mock Certificate Data".data(using: .utf8)
        mockUserDefaults.set(expectedCertificate, forKey: "fps_certificate_\(AssetManagerConstants.license)")
           
        let certificate = certificateManager.loadCachedCertificate()
           
        XCTAssertEqual(certificate, expectedCertificate)

    }
    
    func testPersistCertificate() {
        let mockUserDefaults = MockUserDefaultManaging()
        let mockNetworkFetcher = MockNetworkFetcher()
        let certificateManager = CertificateManager(userDefaults: mockUserDefaults, networkFetcher: mockNetworkFetcher)
        
        let expectedCertificate = "Mock Certificate Data".data(using: .utf8)
        certificateManager.persistCertificate(expectedCertificate!)
        
        let storedCertificate = mockUserDefaults.data(forKey: "fps_certificate_\(AssetManagerConstants.license)")
        
        XCTAssertEqual(storedCertificate, expectedCertificate)
    }
}


