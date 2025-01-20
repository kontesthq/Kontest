//
//  KontestNewAPIRepository.swift
//  Kontest
//
//  Created by Ayush Singhal on 9/7/24.
//

import Foundation
import OSLog

private struct APIType: Codable {
    let htmlPath: String
    let jsonPath: String
    let url: String
}

final class KontestNewAPIRepository: Fetcher, KontestFetcher {
    func getData() async throws -> [KontestDTO] {
        return try await getAllKontests()
    }
    
    typealias DataType = KontestDTO
    
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "KontestNewAPIRepository")
    
    func getAllKontests() async throws -> [KontestDTO] {
        
        do {
            let mainUrl = URL(string: Constants.Endpoints.kontestsURL)!
            
            let page = 1
            let perPage = 10000
            
            let endpointURL = mainUrl
                .appendingPathComponent("kontests")
                .appending(queryItems: [
                    .init(name: "page", value: String(page)),
                    .init(name: "per_page", value: String(perPage))
                ])
            
            // Download data from the URL
            let data = try await downloadDataWithAsyncAwait(url: endpointURL)
            
            // Decode the data
            let kontests = try decodeKontests(from: data)
            
            return kontests
            
        } catch {
            logger.error("Error fetching document or data: \(error)")
            throw error
        }
    }
    
    private func decodeKontests(from data: Data) throws -> [KontestDTO] {
        // Create a JSONDecoder instance
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Decode the raw JSON data into an array of dictionaries
        let rawKontests = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
        
        // Map "location" to "site" and convert the dictionary to Data
        let modifiedKontests = rawKontests.map { dict -> [String: Any] in
            var mutableDict = dict
            if let location = mutableDict["location"] {
                mutableDict["site"] = location
                mutableDict.removeValue(forKey: "location")
            }
            return mutableDict
        }
        
        // Convert the modified dictionaries to Data
        let modifiedData = try JSONSerialization.data(withJSONObject: modifiedKontests, options: [])
        
        // Decode the modified Data into an array of KontestDTO
        let kontests = try decoder.decode([KontestDTO].self, from: modifiedData)
        
        return kontests
    }
}

