//
//  CodeChefFetcher.swift
//  Kontest
//
//  Created by Ayush Singhal on 27/08/23.
//

import Foundation

protocol CodeChefFetcher: Sendable {
    func getUserData(username: String) async throws -> CodeChefAPIDTO
    func getUserKontests(username: String) async throws -> [CodeChefContestInfoDTO]
}
