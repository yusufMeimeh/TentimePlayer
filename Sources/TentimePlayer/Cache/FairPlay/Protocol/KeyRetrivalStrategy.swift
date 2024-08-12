//
//  KeyRetrivalStrategy.swift
//  TenTime
//
//  Created by Qamar Al Amassi on 11/07/2024.
//  Copyright © 2024 TenTime. All rights reserved.
//
// Strategy Pattern for key retrieval
import AVFoundation


protocol KeyRetrivalStrategy {
    func retriveKey(completion: @escaping (Result<AVContentKeyResponse?, Error>) -> Void)
    func retriveAVResourceLoaderKey(completion: @escaping (Result<Data?, Error>) -> Void)
}

extension KeyRetrivalStrategy {
    func retriveKey(completion: @escaping (Result<AVContentKeyResponse?, Error>) -> Void) {}
    func retriveAVResourceLoaderKey(completion: @escaping (Result<Data?, Error>) -> Void) {}
}


protocol PersistableContentKeyUpdateStrategy {
    func handlePersistableContentKeyUpdate(persistableContentKey: Data, keyIdentifier: Any, assetName: String, keyManager: KeyManager)
}
