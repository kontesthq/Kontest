//
//  LeetCodeGraphQLAPIFetcher.swift
//  Kontest
//
//  Created by Ayush Singhal on 04/09/23.
//

import Foundation

protocol LeetCodeGraphQLAPIFetcher: Sendable {
    func getUserData(username: String) async throws -> LeetCodeUserProfileGraphQLAPIDTO

    func getUserRankingInfo(username: String) async throws -> LeetCodeUserRankingsGraphQLAPIDTO
}
