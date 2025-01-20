//
//  Fetcher.swift
//  Kontest
//
//  Created by Ayush Singhal on 9/11/24.
//

import Foundation

// Define the Fetcher protocol with a generic placeholder and an async function
protocol Fetcher {
    associatedtype DataType
    func getData() async throws -> [DataType]
}

// Type erasure to hold any Fetcher instance
struct AnyFetcher<T>: Fetcher {
    private let _getData: () async throws -> [T]
    let repositoryType: String
    
    // Initialize with any Fetcher
    init<F: Fetcher>(_ fetcher: F) where F.DataType == T {
        self._getData = fetcher.getData
        self.repositoryType = String(describing: type(of: fetcher))
    }
    
    // Call the erased getData, preserving async behavior
    func getData() async throws -> [T] {
        return try await _getData()
    }
}
