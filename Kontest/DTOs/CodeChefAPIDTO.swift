//
//  CodeChefAPIDTO.swift
//  Kontest
//
//  Created by Ayush Singhal on 27/08/23.
//

import Foundation

// MARK: - CodeChefAPIDTO

struct CodeChefAPIDTO: Codable {
    let success: Bool
    let profile: String
    let name: String
    let currentRating, highestRating: Int
    let countryFlag: String
    let countryName: String
    let globalRank, countryRank: Int
    let stars: String
    
    enum CodingKeys: CodingKey {
        case success
        case profile
        case name
        case currentRating
        case highestRating
        case countryFlag
        case countryName
        case globalRank
        case countryRank
        case stars
    }
}
