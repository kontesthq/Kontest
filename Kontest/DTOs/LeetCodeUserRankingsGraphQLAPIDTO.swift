//
//  LeetCodeUserRankingsGraphQLAPIDTO.swift
//  Kontest
//
//  Created by Ayush Singhal on 04/09/23.
//

import Foundation
import KontestGraphQLSchema

struct LeetCodeUserRankingsGraphQLAPIDTO: Codable {
    let leetCodeUserRankingGraphQLAPIDTO: LeetCodeUserRankingGraphQLAPIDTO?
    let leetCodeUserRankingHistoryGraphQLAPIDTO: [LeetCodeUserRankingHistoryGraphQLAPIDTO?]?
}

struct LeetCodeUserRankingGraphQLAPIDTO: Codable {
    let attendedContestsCount: Int?
    let rating: Double?
    let globalRanking: Int?
    let totalParticipants: Int?
    let topPercentage: Double?
    let badge: BadgeDTO?
}

struct BadgeDTO: Codable {
    let name: String?
}

struct LeetCodeUserRankingHistoryGraphQLAPIDTO: Codable {
    let attended: Bool?
    let trendDirection: String?
    let problemsSolved: Int?
    let totalProblems: Int?
    let finishTimeInSeconds: Int?
    let rating: Double?
    let ranking: Int?
    let contest: ContestDTO?
}

struct ContestDTO: Codable {
    let title: String?
    let startTime: String?
}

extension BadgeDTO {
    static func from(badge: UserContestRankingInfoQuery.Data.UserContestRanking.Badge?) -> BadgeDTO? {
        guard let badge else { return nil }

        return BadgeDTO(name: badge.name)
    }
}

extension LeetCodeUserRankingGraphQLAPIDTO {
    static func from(userContestRanking: UserContestRankingInfoQuery.Data.UserContestRanking?) -> LeetCodeUserRankingGraphQLAPIDTO? {
        guard let userContestRanking else { return nil }

        return LeetCodeUserRankingGraphQLAPIDTO(attendedContestsCount: userContestRanking.attendedContestsCount, rating: userContestRanking.rating, globalRanking: userContestRanking.globalRanking, totalParticipants: userContestRanking.totalParticipants, topPercentage: userContestRanking.topPercentage, badge: BadgeDTO.from(badge: userContestRanking.badge))
    }
}

extension ContestDTO {
    static func from(contest: UserContestRankingInfoQuery.Data.UserContestRankingHistory.Contest?) -> ContestDTO? {
        guard let contest else { return nil }

        return ContestDTO(title: contest.title, startTime: contest.startTime)
    }
}

extension LeetCodeUserRankingHistoryGraphQLAPIDTO {
    static func from(leetCodeUserRankingHistoryGraphQLAPIDTO: UserContestRankingInfoQuery.Data.UserContestRankingHistory?) ->
        LeetCodeUserRankingHistoryGraphQLAPIDTO?
    {
        guard let leetCodeUserRankingHistoryGraphQLAPIDTO else { return nil }

        return LeetCodeUserRankingHistoryGraphQLAPIDTO(attended: leetCodeUserRankingHistoryGraphQLAPIDTO.attended, trendDirection: leetCodeUserRankingHistoryGraphQLAPIDTO.trendDirection, problemsSolved: leetCodeUserRankingHistoryGraphQLAPIDTO.problemsSolved, totalProblems: leetCodeUserRankingHistoryGraphQLAPIDTO.problemsSolved, finishTimeInSeconds: leetCodeUserRankingHistoryGraphQLAPIDTO.finishTimeInSeconds, rating: leetCodeUserRankingHistoryGraphQLAPIDTO.rating, ranking: leetCodeUserRankingHistoryGraphQLAPIDTO.ranking, contest: ContestDTO.from(contest: leetCodeUserRankingHistoryGraphQLAPIDTO.contest))
    }

    static func from(leetCodeUserRankingHistoryGraphQLAPIDTOs: [UserContestRankingInfoQuery.Data.UserContestRankingHistory?]?) -> [LeetCodeUserRankingHistoryGraphQLAPIDTO?]? {
        leetCodeUserRankingHistoryGraphQLAPIDTOs?.map { leetCodeUserRankingHistoryGraphQLAPIDTO in
            from(leetCodeUserRankingHistoryGraphQLAPIDTO: leetCodeUserRankingHistoryGraphQLAPIDTO)
        }
    }
}
