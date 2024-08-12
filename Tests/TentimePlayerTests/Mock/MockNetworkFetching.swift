//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 02/08/2024.
//

import Foundation

@testable import TentimePlayer

class MockNetworkFetcher: NetwrokFetching {
    var fetchDataCalled: Bool = false
    var isCertficateExist: Bool = true
    
    func fetchData(from url: URL) -> Data? {
        fetchDataCalled = true
        return isCertficateExist ? "Mock certificate data".data(using: .utf8) : nil
    }
}
