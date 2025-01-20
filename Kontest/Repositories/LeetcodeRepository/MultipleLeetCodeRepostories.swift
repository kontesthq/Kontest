//
//  MultipleLeetCodeRepostories.swift
//  Kontest
//
//  Created by Ayush Singhal on 9/13/24.
//

import Foundation
import OSLog

final class MultipleLeetCodeRepostories: LeetCodeGraphQLAPIFetcher {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "MultipleLeetCodeRepostories")
    
    let repositories: [any LeetCodeGraphQLAPIFetcher]
    
    init(repositories: [any LeetCodeGraphQLAPIFetcher]) {
        self.repositories = repositories
    }
    
    func getUserData(username: String) async throws -> LeetCodeUserProfileGraphQLAPIDTO {
        var lastError: (any Error)?
        
        for repository in repositories {
            do {
                let userData = try await repository.getUserData(username: username)
                logger.info("Got leetcode user data from \("\(type(of: repository))")")
                
                return userData
            } catch {
                lastError = error
                logger.error("Repository \(type(of: repository)) failed with error: \(error.localizedDescription). Trying next repository...")
            }
        }
        
        // If all repositories fail, throw the last error encountered
        if let lastError {
            throw lastError
        } else {
            // This case should ideally never happen
            throw NSError(domain: "MultipleLeetCodeRepostories", code: -1, userInfo: [NSLocalizedDescriptionKey: "No repositories available to fetch data."])
        }
    }
    
    func getUserRankingInfo(username: String) async throws -> LeetCodeUserRankingsGraphQLAPIDTO {
        var lastError: (any Error)?
        
        for repository in repositories {
            do {
                let userRankingData = try await repository.getUserRankingInfo(username: username)
                logger.info("Got leetcode user ranking data from \("\(type(of: repository))")")
                
                return userRankingData
            } catch {
                lastError = error
                logger.error("Repository \(type(of: repository)) failed with error: \(error.localizedDescription). Trying next repository...")
            }
        }
        
        // If all repositories fail, throw the last error encountered
        if let lastError {
            throw lastError
        } else {
            // This case should ideally never happen
            throw NSError(domain: "MultipleLeetCodeRepostories", code: -1, userInfo: [NSLocalizedDescriptionKey: "No repositories available to fetch data."])
        }
    }
}
