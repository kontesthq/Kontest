//
//  MultipleKontestRepositories.swift
//  Kontest
//
//  Created by Ayush Singhal on 8/3/24.
//

import Foundation
import OSLog

/// A repository handler that attempts to fetch contest data from multiple repositories in sequence.
/// If one repository fails, it will automatically try the next one in the list.
///
/// The class is designed to improve the reliability of fetching contest data by providing a fallback
/// mechanism that switches to alternate repositories if the primary one fails. This is useful in
/// scenarios where data sources might be intermittently unavailable or have varying levels of reliability.
final class MultipleKontestRepositories: KontestFetcher {
    /// Logger instance for logging events related to the `MultipleKontestRepositories` class.
    /// Logs are categorized under "MultipleKontestRepositories" within the "com.ayushsinghal.Kontest" subsystem.
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "MultipleKontestRepositories")

    /// An array of repositories that conform to the `KontestFetcher` protocol.
    /// The repositories are tried in the order they appear in the array.
    let repositories: [any KontestFetcher]

    /// Initializes the `MultipleKontestRepositories` class with a list of repositories.
    ///
    /// - Parameter repositories: An array of repositories that implement the `KontestFetcher` protocol.
    ///                           The repositories are tried in sequence until one successfully fetches the data.
    init(repositories: [any KontestFetcher]) {
        self.repositories = repositories
    }

    /// Attempts to fetch contest data from the list of repositories.
    ///
    /// The method tries to retrieve data from each repository in the order they were provided.
    /// If a repository throws an error, the method logs the failure and proceeds to the next repository.
    ///
    /// - Throws: The last encountered error if all repositories fail to fetch the data.
    /// - Returns: An array of `KontestDTO` objects representing the fetched contests.
    func getAllKontests() async throws -> [KontestDTO] {
        var lastError: (any Error)?

        for repository in repositories {
            do {
                let kontests = try await repository.getAllKontests()

                logger.info("Got kontests from \("\(type(of: repository))"), returning kontests count: \(kontests.count)")
                return kontests
            } catch {
                lastError = error
                logger.error("Repository \(type(of: repository)) failed with error: \(error.localizedDescription). Trying next repository...")
            }
        }

        // If all repositories fail, throw the last error encountered
        if let lastError = lastError {
            throw lastError
        } else {
            // This case should ideally never happen
            throw NSError(domain: "MultipleKontestRepositories", code: -1, userInfo: [NSLocalizedDescriptionKey: "No repositories available to fetch contests."])
        }
    }
}
