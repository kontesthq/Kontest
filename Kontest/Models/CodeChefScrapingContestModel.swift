//
//  CodeChefScrapingContestModel.swift
//  Kontest
//
//  Created by Ayush Singhal on 1/13/24.
//

import Foundation

struct CodeChefScrapingContestModel: Codable, Identifiable {
    let id: UUID

    let code: String
    let year: Int
    let month: Int
    let day: Int
    let reason: String?
    let penalised_in: Bool
    let rating: Int
    let rank: Int
    let name: String
    let endDate: String
    let color: String
    var hasAnimated: Bool = true

    init(id: UUID = UUID(), code: String, year: Int, month: Int, day: Int, reason: String?, penalised_in: Bool, rating: Int, rank: Int, name: String, endDate: String, color: String) {
        self.id = id
        self.code = code
        self.year = year
        self.month = month
        self.day = day
        self.reason = reason
        self.penalised_in = penalised_in
        self.rating = rating
        self.rank = rank
        self.name = name
        self.endDate = endDate
        self.color = color
    }
}

extension CodeChefScrapingContestModel {
    static func from(dto: CodeChefContestInfoDTO) -> CodeChefScrapingContestModel {
        return CodeChefScrapingContestModel(
            code: dto.code,
            year: dto.getyear,
            month: dto.getmonth,
            day: dto.getday,
            reason: dto.reason,
            penalised_in: dto.penalised_in,
            rating: dto.rating,
            rank: dto.rank,
            name: dto.name,
            endDate: dto.endDate,
            color: dto.color
        )
    }
}
