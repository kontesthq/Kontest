//
//  KontestNewRepository.swift
//  Kontest
//
//  Created by Ayush Singhal on 1/11/24.
//

import Foundation
import OSLog
import SwiftSoup

final class KontestNewRepository: Fetcher, KontestFetcher {
    func getData() async throws -> [KontestDTO] {
        return try await getAllKontests()
    }

    typealias DataType = KontestDTO

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

            // Updated selector to target contest rows
            let contestElements = try parsedHTML.select("tr.contest")

            var myAllContests: [KontestDTO] = []

            for element in contestElements {
                // Find the anchor tag with class "data-ace" within the contest row
                guard let dataAceElement = try element.select("a.data-ace").first(),
                      let cleanedString = try? dataAceElement.attr("data-ace")
                else {
                    continue
                }

                if let data = cleanedString.data(using: .utf8),
                   let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                {
                    let timeDictionary = dictionary["time"] as? [String: String] ?? [:]

                    let konName = dictionary["title"] as? String ?? ""
                    let startTime = timeDictionary["start"]
                    let endTime = timeDictionary["end"]
                    let desc = dictionary["desc"] as? String

                    var url: String? = ""

                    if desc?.hasPrefix("url: ") ?? false {
                        url = desc?.replacingOccurrences(of: "url: ", with: "")
                    }

                    let location = dictionary["location"] as? String

                    let konDTO = KontestDTO(
                        name: konName,
                        url: url ?? "",
                        startTime: startTime ?? "",
                        endTime: endTime ?? "",
                        duration: "",
                        site: location ?? "",
                        in_24_hours: "NO",
                        status: "CODING"
                    )

                    myAllContests.append(konDTO)
                } else {
                    logger.error("Error parsing JSON for contest")
                }
            }

            return myAllContests
        } catch {
            logger.error("Error in downloading all Kontests async await: \(error.localizedDescription)")
            throw error
        }
    }
}
