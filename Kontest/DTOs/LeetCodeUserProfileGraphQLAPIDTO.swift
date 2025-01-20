//
//  LeetCodeGraphQLAPIDTO.swift
//  Kontest
//
//  Created by Ayush Singhal on 04/09/23.
//

import Foundation
import KontestGraphQLSchema

// MARK: - LeetCodeGraphQLAPIDTO

struct LeetCodeUserProfileGraphQLAPIDTO: Codable {
    let languageProblemCount: [LanguageProblemCountDTO?]?
    let contestBadge: ContestBadgeDTO?
    let username: String?
    let githubUrl: String?
    let twitterUrl: String?
    let linkedinUrl: String?
    let profile: UserProfileDTO?
    let problemsSolvedBeatsStats: [ProblemSolvedBeatsStatsDTO?]?
    let submitStatsGlobal: SubmitStatsGlobalDTO?
}

struct LanguageProblemCountDTO: Codable {
    let languageName: String?
    let problemsSolved: Int?
}

struct ContestBadgeDTO: Codable {
    let name: String?
    let expired: Bool?
    let hoverText: String?
    let icon: String?
}

struct UserProfileDTO: Codable {
    let ranking: Int?
    let userAvatar: String?
    let realName: String?
    let aboutMe: String?
    let school: String?
    let websites: [String?]?
    let countryName: String?
    let company: String?
    let jobTitle: String?
    let skillTags: [String?]?
    let postViewCount: Int?
    let postViewCountDiff: Int?
    let reputation: Int?
    let reputationDiff: Int?
    let solutionCount: Int?
    let solutionCountDiff: Int?
    let categoryDiscussCount: Int?
    let categoryDiscussCountDiff: Int?
}

struct ProblemSolvedBeatsStatsDTO: Codable {
    let difficulty: String?
    let percentage: Double?
}

struct SubmitStatsGlobalDTO: Codable {
    let acSubmissionDTOs: [ACSubmissionNumDTO?]?
}

struct ACSubmissionNumDTO: Codable {
    let difficulty: String?
    let count: Int?
}

extension UserProfileDTO {
    static func from(graphQLUserProfile: UserPublicProfileQuery.Data.MatchedUser.Profile?) -> UserProfileDTO? {
        guard let profileData = graphQLUserProfile else {
            return nil
        }

        return UserProfileDTO(
            ranking: profileData.ranking,
            userAvatar: profileData.userAvatar,
            realName: profileData.realName,
            aboutMe: profileData.aboutMe,
            school: profileData.school,
            websites: profileData.websites ?? [],
            countryName: profileData.countryName,
            company: profileData.company,
            jobTitle: profileData.jobTitle,
            skillTags: profileData.skillTags ?? [],
            postViewCount: profileData.postViewCount,
            postViewCountDiff: profileData.postViewCountDiff,
            reputation: profileData.reputation,
            reputationDiff: profileData.reputationDiff,
            solutionCount: profileData.solutionCount,
            solutionCountDiff: profileData.solutionCountDiff,
            categoryDiscussCount: profileData.categoryDiscussCount,
            categoryDiscussCountDiff: profileData.categoryDiscussCountDiff
        )
    }
}

extension ContestBadgeDTO {
    static func from(contestBadge: UserPublicProfileQuery.Data.MatchedUser.ContestBadge?) -> ContestBadgeDTO? {
        guard let contestBadge = contestBadge else {
            return nil
        }

        return ContestBadgeDTO(name: contestBadge.name, expired: contestBadge.expired, hoverText: contestBadge.hoverText, icon: contestBadge.icon)
    }
}

extension LanguageProblemCountDTO {
    static func from(languageProblemCount: UserPublicProfileQuery.Data.MatchedUser.LanguageProblemCount?) -> LanguageProblemCountDTO? {
        guard let languageProblemCount = languageProblemCount else {
            return nil
        }

        return LanguageProblemCountDTO(languageName: languageProblemCount.languageName, problemsSolved: languageProblemCount.problemsSolved)
    }

    static func from(languageProblemCounts: [UserPublicProfileQuery.Data.MatchedUser.LanguageProblemCount?]?) -> [LanguageProblemCountDTO?]? {
        guard let languageProblemCounts else { return nil }

        return languageProblemCounts.map { languageProblemCount in
            from(languageProblemCount: languageProblemCount)
        }
    }
}

extension ACSubmissionNumDTO {
    static func from(acSubmissionNum: UserPublicProfileQuery.Data.MatchedUser.SubmitStatsGlobal.AcSubmissionNum?) -> ACSubmissionNumDTO? {
        guard let acSubmissionNum else { return nil }
        return ACSubmissionNumDTO(difficulty: acSubmissionNum.difficulty, count: acSubmissionNum.count)
    }
}

extension SubmitStatsGlobalDTO {
    static func from(submitStatsGlobal: UserPublicProfileQuery.Data.MatchedUser.SubmitStatsGlobal?) -> SubmitStatsGlobalDTO? {
        guard let submitStatsGlobal else { return nil }

        let p = submitStatsGlobal.acSubmissionNum?.map { o in
            ACSubmissionNumDTO.from(acSubmissionNum: o)
        }

        return SubmitStatsGlobalDTO(acSubmissionDTOs: p)
    }
}

extension ProblemSolvedBeatsStatsDTO {
    static func from(problemsSolvedBeatsStats: UserPublicProfileQuery.Data.MatchedUser.ProblemsSolvedBeatsStat?) -> ProblemSolvedBeatsStatsDTO? {
        guard let problemsSolvedBeatsStats else { return nil }

        return ProblemSolvedBeatsStatsDTO(difficulty: problemsSolvedBeatsStats.difficulty, percentage: problemsSolvedBeatsStats.percentage)
    }

    static func from(problemsSolvedBeatsStats: [UserPublicProfileQuery.Data.MatchedUser.ProblemsSolvedBeatsStat?]?) -> [ProblemSolvedBeatsStatsDTO?]? {
        guard let problemsSolvedBeatsStats else { return nil }

        return problemsSolvedBeatsStats.map { stats in
            from(problemsSolvedBeatsStats: stats)
        }
    }
}
