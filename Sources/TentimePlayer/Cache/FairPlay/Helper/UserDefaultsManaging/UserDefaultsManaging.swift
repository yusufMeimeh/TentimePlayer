//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 13/07/2024.
//

import Foundation

protocol UserDefaultsManaging {
    func removeObject(forKey defaultName: String)
    func data(forKey defaultName: String) -> Data?
    func set(_ value: Data?, forKey defaultName: String)
}

class DefaultUserDefaults: UserDefaultsManaging {
    private let userDefaults = UserDefaults.standard
    
    func removeObject(forKey defaultName: String) {
        userDefaults.removeObject(forKey: defaultName)
    }
    
    func data(forKey defaultName: String) -> Data? {
        return userDefaults.data(forKey: defaultName)
    }
    
    func set(_ value: Data?, forKey defaultName: String) {
        userDefaults.set(value, forKey: defaultName)
    }
}
