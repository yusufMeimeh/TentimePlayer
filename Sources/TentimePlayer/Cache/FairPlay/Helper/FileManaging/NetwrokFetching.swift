//
//  File.swift
//  
//
//  Created by Qamar Al Amassi on 02/08/2024.
//

import Foundation

protocol NetwrokFetching {
    func fetchData(from url: URL) -> Data?
}


struct NetwrokFetcher: NetwrokFetching {
    func fetchData(from url: URL) -> Data? {
        return try? Data(contentsOf: url)
    }
}
