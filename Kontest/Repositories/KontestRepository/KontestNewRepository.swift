//
//  KontestNewRepository.swift
//  Kontest
//
//  Created by Ayush Singhal on 1/11/24.
//

import Foundation
import OSLog
import SwiftSoup

func getSiteFromLocation(location:String) -> String{
    
    switch location.lowercased() {
    case "codingninjas.com/codestudio":
        "Coding Ninjas"
    
    case "codingninjas.com":
        "Coding Ninjas"
        
    case "yukicoder.me":
        "Yuki Coder"
        
    case "hackerearth.com":
        "HackerEarth"
        
    case "hackerrank.com":
        "HackerRank"
        
    case "atcoder.jp":
        "AtCoder"
        
    case "codeforces.com":
        "CodeForces"
        
    case "leetcode.com":
        "LeetCode"
        
    case "codechef.com":
        "CodeChef"
        
    case "toph.com":
        "Toph"
        
    case "csacademy.com":
        "CS Academy"
        
    default:
        location
    }
}

class KontestNewRepository: KontestFetcher {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "KontestNewRepository")

    func getAllKontests() async throws -> [KontestDTO] {
        guard let url = URL(string: "https://clist.by") else {
            logger.error("Error in making url")
            throw URLError(.badURL)
        }

        do {
            let data = try await downloadDataWithAsyncAwait(url: url)

            let rawHTML = String(decoding: data, as: UTF8.self)
            let parsedHTML = try SwiftSoup.parse(rawHTML)
            let contestElements = try parsedHTML.select(".contest.row:not(.subcontest) > div + div > i + a")

            var myAllContests: [KontestDTO] = []

            for element in contestElements {
                let cleanedString = try element.attr("data-ace")

                if let data = cleanedString.data(using: .utf8),
                   let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                {
                    // Access the data in the dictionary

                    print(dictionary)

                    let timeDictionary = dictionary["time"] as? [String: String] ?? [:]

                    let konName = dictionary["title"] as? String ?? ""
                    let startTime = timeDictionary["start"]
                    let endTime = timeDictionary["end"]
                    let desc = (dictionary["desc"] as? String)

                    var url: String? = ""

                    if desc?.hasPrefix("url: ") ?? false {
                        url = desc?.replacingOccurrences(of: "url: ", with: "")
                    }

                    let location = dictionary["location"] as? String

                    let dateFormat = "MMMM dd, yyyy HH:mm:ss"
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = dateFormat
                    
                    let site = getSiteFromLocation(location: location ?? "")
                    
                    let konDTo = KontestDTO(name: konName, url: url ?? "" , start_time: startTime ?? "", end_time: endTime ?? "", duration: "", site: site, in_24_hours: "NO", status: "CODING")

                    print("HI")
                    myAllContests.append(konDTo)
                } else {
                    print("Error parsing JSON")
                }
            }

//            let allFetchedKontests = try JSONDecoder().decode([KontestDTO].self, from: data)

            return myAllContests
        } catch {
            logger.error("error in downloading all Kontests async await: \(error)")
            throw error
        }
    }
}
