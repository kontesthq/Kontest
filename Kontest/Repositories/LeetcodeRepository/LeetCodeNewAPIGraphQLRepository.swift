//
//  LeetCodeNewAPIGraphQLRepository.swift
//  Kontest
//
//  Created by Ayush Singhal on 04/09/23.
//

import Foundation
import KontestGraphQLSchema
import OSLog

final class LeetCodeNewAPIGraphQLRepository: LeetCodeGraphQLAPIFetcher {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "LeetCodeNewAPIGraphQLRepository")
    
    func getUserData(username: String) async throws -> LeetCodeUserProfileGraphQLAPIDTO {
        // Define the query
        let query = LeetcodeMatchedUserQuery(username: username)
        
        // Create an ApolloClient instance
        let apolloClient = await ApolloFactory.getInstance(url: URL(string: Constants.Endpoints.graphqlURL)!).apollo
        
        // Use `withCheckedThrowingContinuation` to bridge completion handler-based APIs with async/await
        let result: LeetCodeUserProfileGraphQLAPIDTO = try await withCheckedThrowingContinuation { continuation in
            apolloClient.fetch(query: query) { result in
                switch result {
                case .success(let value):
                    if let p = value.data?.leetcodeQuery?.matchedUser {
                        let leetCodeGraphQLAPIDTO = LeetCodeUserProfileGraphQLAPIDTO(
                            languageProblemCount: p.languageProblemCount?.compactMap { count in
                                guard let count = count else { return nil }
                                return LanguageProblemCountDTO(
                                    languageName: count.languageName,
                                    problemsSolved: count.problemsSolved
                                )
                            },
                            contestBadge: ContestBadgeDTO(
                                name: p.contestBadge?.name,
                                expired: p.contestBadge?.expired,
                                hoverText: p.contestBadge?.hoverText,
                                icon: p.contestBadge?.icon
                            ),
                            username: p.username,
                            githubUrl: p.githubUrl,
                            twitterUrl: p.twitterUrl,
                            linkedinUrl: p.linkedinUrl,
                            profile: UserProfileDTO(
                                ranking: p.profile?.ranking,
                                userAvatar: p.profile?.userAvatar,
                                realName: p.profile?.realName,
                                aboutMe: p.profile?.aboutMe,
                                school: p.profile?.school,
                                websites: p.profile?.websites ?? [], // Use empty array if nil
                                countryName: p.profile?.countryName,
                                company: p.profile?.company,
                                jobTitle: p.profile?.jobTitle,
                                skillTags: p.profile?.skillTags ?? [], // Use empty array if nil
                                postViewCount: p.profile?.postViewCount,
                                postViewCountDiff: p.profile?.postViewCountDiff,
                                reputation: p.profile?.reputation,
                                reputationDiff: p.profile?.reputationDiff,
                                solutionCount: p.profile?.solutionCount,
                                solutionCountDiff: p.profile?.solutionCountDiff,
                                categoryDiscussCount: p.profile?.categoryDiscussCount,
                                categoryDiscussCountDiff: p.profile?.categoryDiscussCountDiff
                            ),
                            problemsSolvedBeatsStats: p.problemsSolvedBeatsStats?.compactMap { stat in
                                guard let stat = stat else { return nil }
                                return ProblemSolvedBeatsStatsDTO(
                                    difficulty: stat.difficulty,
                                    percentage: stat.percentage
                                )
                            },
                            submitStatsGlobal: SubmitStatsGlobalDTO(
                                acSubmissionDTOs: p.submitStatsGlobal?.acSubmissionNum?.compactMap { submission in
                                    guard let submission = submission else { return nil }
                                    return ACSubmissionNumDTO(
                                        difficulty: submission.difficulty,
                                        count: submission.count
                                    )
                                }
                            )
                        )
                        
                        continuation.resume(returning: leetCodeGraphQLAPIDTO)
                    } else {
                        continuation.resume(throwing: AppError(title: "Data not found", description: "Data not found in LeetCodeNewAPIGraphQLRepository - getUserData"))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        
        return result
    }
    
    func getUserRankingInfo(username: String) async throws -> LeetCodeUserRankingsGraphQLAPIDTO {
        let query = LeetcodeUserContestRankingInfoQuery(username: username)
        
        // Create an ApolloClient instance
        let apolloClient = await ApolloFactory.getInstance(url: URL(string: Constants.Endpoints.graphqlURL)!).apollo
        
        let result: LeetCodeUserRankingsGraphQLAPIDTO = try await withCheckedThrowingContinuation { continuation in
            apolloClient.fetch(query: query) { [weak self] result in
                switch result {
                case .success(let value):
                    let userContestRanking = value.data?.leetcodeQuery?.userContestRanking
                    let userContestRankingHistory = value.data?.leetcodeQuery?.userContestRankingHistory
                    
                    let leetCodeUserRankingsGraphQLAPIDTO = LeetCodeUserRankingsGraphQLAPIDTO(
                        leetCodeUserRankingGraphQLAPIDTO: LeetCodeUserRankingGraphQLAPIDTO(
                            attendedContestsCount: userContestRanking?.attendedContestsCount,
                            rating: userContestRanking?.rating,
                            globalRanking: userContestRanking?.globalRanking,
                            totalParticipants: userContestRanking?.totalParticipants,
                            topPercentage: userContestRanking?.topPercentage,
                            badge: BadgeDTO(name: userContestRanking?.badge?.name)
                        ),
                        leetCodeUserRankingHistoryGraphQLAPIDTO: userContestRankingHistory?.compactMap { histortPoint in
                            LeetCodeUserRankingHistoryGraphQLAPIDTO(
                                attended: histortPoint?.attended,
                                trendDirection: histortPoint?.trendDirection,
                                problemsSolved: histortPoint?.problemsSolved,
                                totalProblems: histortPoint?.totalProblems,
                                finishTimeInSeconds: histortPoint?.finishTimeInSeconds,
                                rating: histortPoint?.rating,
                                ranking: histortPoint?.ranking,
                                contest: ContestDTO(title: histortPoint?.contest?.title, startTime: histortPoint?.contest?.startTime)
                            )
                        }
                    )
                    
                    continuation.resume(returning: leetCodeUserRankingsGraphQLAPIDTO)
                    
                case .failure(let error):
                    self?.logger.error("Error in LeetCodeNewAPIGraphQLRepository - getUserRankingInfo: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
        
        return result
    }
}
