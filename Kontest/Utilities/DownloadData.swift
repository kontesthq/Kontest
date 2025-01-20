//
//  DownloadData.swift
//  Kontest
//
//  Created by Ayush Singhal on 12/08/23.
//

@preconcurrency import Apollo
import Combine
import Foundation

final class DownloadDataWithApollo: Sendable {
    static let shared = DownloadDataWithApollo()

    let apollo = ApolloClient(url: URL(string: "https://leetcode.com/graphql?query=")!)

    private init() {}
}

final class DownloadDataWithApollo2: Sendable {
    let apollo: ApolloClient
    
    // Initialize with the ApolloClient
    init(apollo: ApolloClient) {
        self.apollo = apollo
    }
}

// Define an actor to manage concurrency for cache
actor DownloadDataWithApollo2Cache {
    private var instanceCache: [URL: DownloadDataWithApollo2] = [:]
    
    func getInstance(for url: URL) -> DownloadDataWithApollo2? {
        return instanceCache[url]
    }
    
    func createInstance(for url: URL) -> DownloadDataWithApollo2 {
        let newInstance = DownloadDataWithApollo2(apollo: ApolloClient(url: url))
        instanceCache[url] = newInstance
        return newInstance
    }
}

final class ApolloFactory {
    // Define a static actor instance to manage cache
    private static let cache = DownloadDataWithApollo2Cache()
    
    // Static method to get or create an instance asynchronously
    static func getInstance(url: URL) async -> DownloadDataWithApollo2 {
        if let cachedInstance = await cache.getInstance(for: url) {
            return cachedInstance
        } else {
            return await cache.createInstance(for: url)
        }
    }
    
}

func downloadDataWithAsyncAwait(url: URL) async throws -> Data {
    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          (200 ..< 300).contains(httpResponse.statusCode)
    else {
        throw URLError(.badServerResponse)
    }

    return data
}
