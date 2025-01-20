//
//  MultipleCodeChefRepostories.swift
//  Kontest
//
//  Created by Ayush Singhal on 9/13/24.
//

import Foundation
import OSLog

final public class MultipleCodeChefRepostories: CodeChefFetcher {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "MultipleCodeChefRepostories")
    
    let repositories: [any CodeChefFetcher]
    
    init(repositories: [any CodeChefFetcher]) {
        self.repositories = repositories
    }
    
    func getUserData(username: String) async throws -> CodeChefAPIDTO {
        var lastError: (any Error)?
        
        for repository in repositories {
            do {
                let data = try await repository.getUserData(username: username)
                logger.info("Got CodeChef user data from \("\(type(of: repository))")")
                
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
            throw NSError(domain: "MultipleCodeChefRepostories", code: -1, userInfo: [NSLocalizedDescriptionKey: "No repositories available to fetch data."])
        }
    }
    
    func getUserKontests(username: String) async throws -> [CodeChefContestInfoDTO] {
        var lastError: (any Error)?
        
        for repository in repositories {
            do {
                let data = try await repository.getUserKontests(username: username)
                logger.info("Got CodeChef user kontests from \("\(type(of: repository))")")
                
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
            throw NSError(domain: "MultipleCodeChefRepostories", code: -1, userInfo: [NSLocalizedDescriptionKey: "No repositories available to fetch data."])
        }
    }
    
    
}
