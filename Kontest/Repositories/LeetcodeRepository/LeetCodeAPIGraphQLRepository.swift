//
//  LeetCodeAPIGraphQLRepository.swift
//  Kontest
//
//  Created by Ayush Singhal on 9/11/24.
//

import Foundation
import KontestGraphQLSchema
import OSLog

final class LeetCodeAPIGraphQLRepository: LeetCodeGraphQLAPIFetcher {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "LeetCodeAPIGraphQLRepository")
    
    func getUserData(username: String, completion: @escaping (LeetCodeUserProfileGraphQLAPIDTO?, (any Error)?) -> Void) {
        let query = UserPublicProfileQuery(username: username)
        
        DownloadDataWithApollo.shared.apollo.fetch(query: query) { [weak self] result in
            switch result {
            case .success(let value):
                let p = value.data?.matchedUser
                
                if let p {
                    let leetCodeGraphQLAPIDTO = LeetCodeUserProfileGraphQLAPIDTO(
                        languageProblemCount: p.languageProblemCount?.compactMap { count in
                            guard let count else { return nil }
                            
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
                                // Ensure `submission` is not nil and then map
                                guard let submission else { return nil }
                                return ACSubmissionNumDTO(
                                    difficulty: submission.difficulty,
                                    count: submission.count
                                )
                            }
                        )
                    )
                    
                    completion(leetCodeGraphQLAPIDTO, nil)
                } else {
                    completion(nil, AppError(title: "Data not found", description: "Data not found in  LeetCodeAPIGraphQLRepository - getUserData"))
                }
            case .failure(let error):
                self?.logger.error("Error in LeetCodeAPIGraphQLRepository - getUserData: \(error)")
                completion(nil, error)
            }
        }
    }
    
    func getUserRankingInfo(username: String, completion: @escaping (LeetCodeUserRankingsGraphQLAPIDTO?, (any Error)?) -> Void) {
        let query = UserContestRankingInfoQuery(username: username)
        
        DownloadDataWithApollo.shared.apollo.fetch(query: query) { [weak self] result in
            switch result {
            case .success(let value):
                let userContestRanking = value.data?.userContestRanking
                let userContestRankingHistory = value.data?.userContestRankingHistory
                
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
                
                completion(leetCodeUserRankingsGraphQLAPIDTO, nil)
                
            case .failure(let error):
                self?.logger.error("Error in LeetCodeAPIGraphQLRepository - getUserRankingInfo: \(error)")
                completion(nil, error)
            }
        }
    }
    
    func getUserData(username: String) async throws -> LeetCodeUserProfileGraphQLAPIDTO {
        return try await withCheckedThrowingContinuation { continuation in
            getUserData(username: username) { leetCodeUserProfileGraphQLAPIDTO, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let leetCodeUserProfileGraphQLAPIDTO {
                    continuation.resume(returning: leetCodeUserProfileGraphQLAPIDTO)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
        }
    }
    
    func getUserRankingInfo(username: String) async throws -> LeetCodeUserRankingsGraphQLAPIDTO {
        return try await withCheckedThrowingContinuation { continuation in
            getUserRankingInfo(username: username) { leetCodeUserRankingsGraphQLAPIDTO, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let leetCodeUserRankingsGraphQLAPIDTO {
                    continuation.resume(returning: leetCodeUserRankingsGraphQLAPIDTO)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
        }
    }
}
