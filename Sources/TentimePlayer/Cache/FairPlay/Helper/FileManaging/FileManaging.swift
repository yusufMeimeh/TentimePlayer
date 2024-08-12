//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 13/07/2024.
//

import Foundation


protocol FileManaging {
    func fileExists(atPath path: String) -> Bool
    func createDirectory(at url: URL, withIntermediateDirectories: Bool, attributes: [FileAttributeKey: Any]?) throws
    func contents(atPath path: String) -> Data?
    func write(_ data: Data, at url: URL, options: Data.WritingOptions) throws
    func removeItem(at url: URL) throws
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func setupContentKeyDirectory(name: String) -> URL

}

class DefaultFileManager: FileManaging {
  
    
    private let fileManager = FileManager.default

    
    func fileExists(atPath path: String) -> Bool {
        fileManager.fileExists(atPath: path)
    }
    
    func createDirectory(at url: URL, withIntermediateDirectories: Bool, attributes: [FileAttributeKey : Any]?) throws {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: withIntermediateDirectories, attributes: attributes)
    }
    
    func contents(atPath path: String) -> Data? {
        fileManager.contents(atPath: path)
    }
    
    func write(_ data: Data, at url: URL, options: Data.WritingOptions) throws {
        try data.write(to: url, options: options)
    }
    
    func removeItem(at url: URL) throws {
      try  fileManager.removeItem(at: url)
    }
    
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        fileManager.urls(for: directory, in: domainMask)
    }
    
    
    func setupContentKeyDirectory(name: String) -> URL {
        guard let documentPath = urls(for: .documentDirectory, in: .userDomainMask).first else {
                 fatalError("Unable to determine document directory URL")
             }
             
             let contentKeyDirectory = documentPath.appendingPathComponent(name, isDirectory: true)
             
             if !fileExists(atPath: contentKeyDirectory.path) {
                 do {
                     try createDirectory(at: contentKeyDirectory, withIntermediateDirectories: false, attributes: nil)
                 } catch {
                     fatalError("Unable to create directory for content keys at path: \(contentKeyDirectory.path)")
                 }
             }
             
             return contentKeyDirectory
    }
}
