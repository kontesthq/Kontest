//
//  CodeForcesNewAPIRepository.swift
//  Kontest
//
//  Created by Ayush Singhal on 9/13/24.
//

import Foundation
import KontestGraphQLSchema
import OSLog

final public class CodeForcesNewAPIRepository: CodeForcesFetcher {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "CodeForcesNewAPIRepository")
    
    func getUserRating(username: String) async throws -> CodeForcesUserRatingAPIDTO {
        let query = CodeForcesRatingsInfoQuery(username: username)
        
        let apolloClient = await ApolloFactory.getInstance(url: URL(string: Constants.Endpoints.graphqlURL)!).apollo
        
        let result: CodeForcesUserRatingAPIDTO = try await withCheckedThrowingContinuation { continuation in
            apolloClient.fetch(query: query) { result in
                switch result {
                case .success(let value):
                    if let p = value.data?.getCodeForcesUser {
                        let codeForcesUserRatingAPIDTO: CodeForcesUserRatingAPIDTO = CodeForcesUserRatingAPIDTO(
                            status: "OK",
                            result: p.result?.ratings?.compactMap(
                                { rating in
                                    CodeForcesUserRatingAPIResultDTO(
                                        contestId: rating.contestId,
                                        contestName: rating.contestName,
                                        handle: rating.handle,
                                        rank: rating.rank,
                                        ratingUpdateTimeSeconds: rating.ratingUpdateTimeSeconds,
                                        oldRating: rating.oldRating,
                                        newRating: rating.newRating
                                    )
                                }) ?? []
                        )
                        
                        continuation.resume(returning: codeForcesUserRatingAPIDTO)
                    } else {
                        continuation.resume(throwing: AppError(title: "Data not found", description: "Data not found in CodeForcesNewAPIRepository - getUserRating"))
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
        return result
    }
    
    func getUserInfo(username: String) async throws -> CodeForcesUserInfoAPIDTO {
        let query = CodeForcesBasicInfoQuery(username: username)
        
        // Create an ApolloClient instance
        let apolloClient = await ApolloFactory.getInstance(url: URL(string: Constants.Endpoints.graphqlURL)!).apollo
        
        // Use `withCheckedThrowingContinuation` to bridge completion handler-based APIs with async/await
        let result: CodeForcesUserInfoAPIDTO = try await withCheckedThrowingContinuation { continuation in
            apolloClient.fetch(query: query) { result in
                switch result {
                case .success(let value):
                    if let p = value.data?.getCodeForcesUser?.result?.basicInfo {
                        let codeForcesUserInfoAPIDTO = CodeForcesUserInfoAPIDTO(
                            status: "OK",
                            result: [
                                CodeForcesUserInfoAPIResultDTO(
                                    contribution: p.contribution,
                                    lastOnlineTimeSeconds: p.lastOnlineTimeSeconds,
                                    friendOfCount: p.friendOfCount,
                                    titlePhoto: p.titlePhoto,
                                    handle: p.handle,
                                    avatar: p.avatar,
                                    registrationTimeSeconds: p.registrationTimeSeconds,
                                    rating: p.rating,
                                    maxRating: p.maxRating,
                                    rank: p.rank,
                                    maxRank: p.maxRank
                                )
                            ]
                        )
                        
                        continuation.resume(returning: codeForcesUserInfoAPIDTO)
                    }
                    else {
                        continuation.resume(throwing: AppError(title: "Data not found", description: "Data not found in CodeForcesNewAPIRepository - getUserInfo"))
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
        return result
    }
}
