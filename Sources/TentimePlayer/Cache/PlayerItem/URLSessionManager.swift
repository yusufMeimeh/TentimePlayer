//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 11/07/2024.
//

import Foundation


struct URLSessionManager {
    //Use Singletone pattern
    static let shared = URLSessionManager()
    
    private init() {}
    
    func createSession(delegate: URLSessionDelegate) -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
}
