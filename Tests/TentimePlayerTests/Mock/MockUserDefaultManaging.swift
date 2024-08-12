//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 02/08/2024.
//

import Foundation
@testable import TentimePlayer


class MockUserDefaultManaging: UserDefaultsManaging {
    private var store: [String: Data] = [:]
    
    func removeObject(forKey defaultName: String) {
        store.removeValue(forKey: defaultName)
    }
    
    func data(forKey defaultName: String) -> Data? {
        store[defaultName]
    }
    
    func set(_ value: Data?, forKey defaultName: String) {
        store[defaultName] = value
    }
    
}
