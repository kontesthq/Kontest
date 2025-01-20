//
//  CodeChefNewAPIRepository.swift
//  Kontest
//
//  Created by Ayush Singhal on 9/13/24.
//

import Foundation
import KontestGraphQLSchema
import OSLog

public final class CodeChefNewAPIRepository: CodeChefFetcher {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "LeetCodeNewAPIGraphQLRepository")
    
    func getUserData(username: String) async throws -> CodeChefAPIDTO {
        // Define the query
        let query = CodeChefUserInfoQuery(username: username)
        
        // Create an ApolloClient instance
        let apolloClient = await ApolloFactory.getInstance(url: URL(string: Constants.Endpoints.graphqlURL)!).apollo
        
        let result: CodeChefAPIDTO = try await withCheckedThrowingContinuation { continuation in
            apolloClient.fetch(query: query) { result in
                switch result {
                case .success(let value):
                    let p = value.data?.codeChefQuery?.getCodeChefUser
                    
                    if let p {
                        let codeChefAPIDTO = CodeChefAPIDTO(
                            success: p.success,
                            profile: p.profile,
                            name: p.name,
                            currentRating: p.currentRating,
                            highestRating: p.highestRating,
                            countryFlag: p.countryFlag,
                            countryName: p.countryName,
                            globalRank: p.globalRank,
                            countryRank: p.countryRank,
                            stars: p.stars
                        )
                        
                        continuation.resume(returning: codeChefAPIDTO)
                    } else {
                        continuation.resume(throwing: AppError(title: "Codechef Username not found", description: "Codechef Username not found"))
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
        return result
    }
    
    func getUserKontests(username: String) async throws -> [CodeChefContestInfoDTO] {
        // Define the query
        let query = CodeChefUserKontestHistoryQuery(username: username)
        
        // Create an ApolloClient instance
        let apolloClient = await ApolloFactory.getInstance(url: URL(string: Constants.Endpoints.graphqlURL)!).apollo
        
        let result: [CodeChefContestInfoDTO] = try await withCheckedThrowingContinuation { continuation in
            apolloClient.fetch(query: query) { result in
                switch result {
                case .success(let value):
                    if let p = value.data?.codeChefQuery?.getUserKontestHistory {
                        let ans = p.compactMap { history -> CodeChefContestInfoDTO? in
                            if let history = history {
                                return CodeChefContestInfoDTO(
                                    code: history.code,
                                    getyear: history.year,
                                    getmonth: history.month,
                                    getday: history.day,
                                    reason: history.reason,
                                    penalised_in: history.penalisedIn,
                                    rating: history.rating,
                                    rank: history.rank,
                                    name: history.name,
                                    endDate: history.endDate,
                                    color: history.color // Assuming you meant `history.color` here
                                )
                            } else {
                                return nil
                            }
                        }
                        
                        continuation.resume(returning: ans)
                    } else {
                        continuation.resume(throwing: AppError(title: "Error in codechef getUserKontests", description: ""))
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
        return result
    }
}
