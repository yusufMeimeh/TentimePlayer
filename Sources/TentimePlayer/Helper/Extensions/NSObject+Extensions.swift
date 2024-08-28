//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 18/08/2024.
//

import Combine
import Foundation

extension NSObject {
    // For optional types
    func bind<T>(_ publisher: Published<T?>.Publisher?, to handler: @escaping (T?) -> Void, storeIn cancellables: inout Set<AnyCancellable>) {
        publisher?
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: handler)
            .store(in: &cancellables)
    }

    // For non-optional types
    func bind<T>(_ publisher: Published<T>.Publisher?, to handler: @escaping (T) -> Void, storeIn cancellables: inout Set<AnyCancellable>) {
        publisher?
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: handler)
            .store(in: &cancellables)
    }
}
