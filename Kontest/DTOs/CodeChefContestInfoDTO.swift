//
//  CodeChefContestInfoDTO.swift
//  Kontest
//
//  Created by Ayush Singhal on 1/13/24.
//

import Foundation

struct CodeChefContestInfoDTO: Codable {
    let code: String
    let getyear: Int
    let getmonth: Int
    let getday: Int
    let reason: String?
    let penalised_in: Bool
    let rating: Int
    let rank: Int
    let name: String
    let endDate: String
    let color: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case getyear
        case getmonth
        case getday
        case reason
        case penalised_in
        case rating
        case rank
        case name
        case endDate = "end_date" // Mapping "end_date" to "endDate"
        case color
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decode(String.self, forKey: .code)
        
        // Convert year, month, and day from String to Int
        let yearString = try container.decode(String.self, forKey: .getyear)
        let monthString = try container.decode(String.self, forKey: .getmonth)
        let dayString = try container.decode(String.self, forKey: .getday)
        
        self.getyear = Int(yearString) ?? 0
        self.getmonth = Int(monthString) ?? 0
        self.getday = Int(dayString) ?? 0
        
        self.reason = try container.decodeIfPresent(String.self, forKey: .reason)
        self.penalised_in = try container.decodeIfPresent(Bool.self, forKey: .penalised_in) ?? false
        
        let ratingString = try container.decode(String.self, forKey: .rating)
        let rankString = try container.decode(String.self, forKey: .rank)
        
        self.rating = Int(ratingString) ?? 0
        self.rank = Int(rankString) ?? 0
        
        self.name = try container.decode(String.self, forKey: .name)
        self.endDate = try container.decode(String.self, forKey: .endDate)
        self.color = try container.decode(String.self, forKey: .color)
    }
    
    init(code: String, getyear: Int, getmonth: Int, getday: Int, reason: String?, penalised_in: Bool, rating: Int, rank: Int, name: String, endDate: String, color: String) {
        self.code = code
        self.getyear = getyear
        self.getmonth = getmonth
        self.getday = getday
        self.reason = reason
        self.penalised_in = penalised_in
        self.rating = rating
        self.rank = rank
        self.name = name
        self.endDate = endDate
        self.color = color
    }
}
