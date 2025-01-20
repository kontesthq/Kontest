//
//  CodeChefAPIRepository.swift
//  Kontest
//
//  Created by Ayush Singhal on 27/08/23.
//

import Foundation
import OSLog
import SwiftSoup

final class CodeChefAPIRepository: CodeChefFetcher {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "CodeChefAPIRepository")
    
    func getUserData(username: String) async throws -> CodeChefAPIDTO {
        guard let url = URL(string: "https://codechef-api.vercel.app/handle/\(username)") else {
            logger.error("Error in making CodeChef url")
            throw URLError(.badURL)
        }
        
        do {
            let data = try await downloadDataWithAsyncAwait(url: url)
            
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            if let dictionary = jsonObject as? [String: Any] {
                print(dictionary)  // Here you have your JSON as a dictionary
            } else {
                print("Failed to cast JSON object as dictionary")
            }
            
            let fetchedCodeChefProfile = try JSONDecoder().decode(CodeChefAPIDTO.self, from: data)

            return fetchedCodeChefProfile
        } catch {
            logger.error("error in downloading CodeChef profile async await: \(error)")
            throw error
        }
    }
    
    private func getUserDataFromParsedHTML(stringHTML: String) throws -> String {
        let startIndex = stringHTML.ranges(of: "var all_rating =")
        let endIndex = stringHTML.ranges(of: "var current_user_rating")
        
        if startIndex.count == 0 || endIndex.count == 0 {
            throw AppError(title: "Username is invalid", description: "")
        }
        
        var prefinalString = stringHTML[startIndex[0].upperBound ..< endIndex[0].lowerBound]
        
        let indOfSemiColon = prefinalString.ranges(of: ";")
        
        prefinalString.removeSubrange(indOfSemiColon[0].lowerBound ..< prefinalString.endIndex)
        
        let indOfFirstBigBracket = prefinalString.ranges(of: "[")
        
        prefinalString.removeSubrange(prefinalString.startIndex ..< indOfFirstBigBracket[0].lowerBound)
        
        return String(prefinalString)
    }
    
    func getUserKontests(username: String) async throws -> [CodeChefContestInfoDTO] {
        guard let url = URL(string: "https://www.codechef.com/users/\(username)") else {
            logger.error("Error in making CodeChef url")
            throw URLError(.badURL)
        }
        
        do {
            let data = try await downloadDataWithAsyncAwait(url: url)
            
            let rawHTML = String(decoding: data, as: UTF8.self)
            let parsedHTML = try SwiftSoup.parse(rawHTML)
            
            let stringHTML = try parsedHTML.outerHtml()
            
            let finalDataString = try getUserDataFromParsedHTML(stringHTML: stringHTML)
            
            let allContests = try JSONDecoder().decode([CodeChefContestInfoDTO].self, from: finalDataString.data(using: .utf8)!)
            
            return allContests
            
        } catch {
            logger.error("error in downloading CodeChef profile async await: \(error)")
            throw error
        }
    }
}
