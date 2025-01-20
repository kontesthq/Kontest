//
//  MultipleRepositories.swift
//  Kontest
//
//  Created by Ayush Singhal on 9/11/24.
//

import Foundation
import OSLog

class MultipleRepositories<U> {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "MultipleRepositories")
    
    // Repositories must all have the same type `U`
    let repositories: [AnyFetcher<U>]
    
    init(repos: [AnyFetcher<U>]) {
        self.repositories = repos
    }
    
    // Function to fetch data from all repositories
    func fetchAllData() async throws -> [U] {
        var lastError: (any Error)?
        
        for repository in repositories {
            do {
                let data = try await repository.getData()
                logger.info("Successfully fetched data from repository: \(repository.repositoryType)")
                return data
            } catch {
                lastError = error
                logger.error("Repository \(repository.repositoryType) failed with error: \(error.localizedDescription). Trying next repository...")
            }
        }
        
        // If all repositories fail, throw the last error encountered
        if let lastError {
            throw lastError
        } else {
            // This case should ideally never happen, but it's a safeguard
            throw NSError(domain: "MultipleRepositories", code: -1, userInfo: [NSLocalizedDescriptionKey: "No repositories available to fetch data."])
        }
    }
}
