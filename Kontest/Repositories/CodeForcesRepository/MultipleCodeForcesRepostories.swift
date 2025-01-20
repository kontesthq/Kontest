//
//  MultipleCodeForcesRepostories.swift
//  Kontest
//
//  Created by Ayush Singhal on 9/13/24.
//

import Foundation
import OSLog

final public class MultipleCodeForcesRepostories: CodeForcesFetcher {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "MultipleCodeForcesRepostories")
    
    let repositories: [any CodeForcesFetcher]
    
    init(repositories: [any CodeForcesFetcher]) {
        self.repositories = repositories
    }
    
    func getUserRating(username: String) async throws -> CodeForcesUserRatingAPIDTO {
        var lastError: (any Error)?
        
        for repository in repositories {
            do {
                let data = try await repository.getUserRating(username: username)
                logger.info("Got CodeForces user rating from \("\(type(of: repository))")")
                
                return data
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
            throw NSError(domain: "MultipleCodeForcesRepostories", code: -1, userInfo: [NSLocalizedDescriptionKey: "No repositories available to fetch data."])
        }
    }
    
    func getUserInfo(username: String) async throws -> CodeForcesUserInfoAPIDTO {
        var lastError: (any Error)?
        
        for repository in repositories {
            do {
                let data = try await repository.getUserInfo(username: username)
                logger.info("Got CodeForces user info from \("\(type(of: repository))")")
                
                return data
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
            throw NSError(domain: "MultipleCodeForcesRepostories", code: -1, userInfo: [NSLocalizedDescriptionKey: "No repositories available to fetch data."])
        }
    }
}
