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

// MARK: - clist.by API repository (TEST ONLY)

/// ⚠️ TEST-ONLY hardcoded credentials for the clist.by API.
///
/// `clist.by` now serves its HTML behind a Cloudflare bot-challenge, so the
/// HTML-scraping `KontestNewRepository` above returns a 403 / empty list. This
/// repository instead calls clist's official JSON API (`/api/v4/contest/`),
/// which is NOT behind the challenge.
///
/// Do NOT ship these credentials in a public release — the key is embedded in
/// the app binary and can be extracted. For production, move this behind your
/// own backend or fetch the key from a secure store.
enum ClistAPIConfig {
    static let username = "ayush.singhal@grofers.com"
    static let apiKey = "5ec2a3dd0b5ce13f36a01401ab57573e359d7d22"
    static let baseURL = "https://clist.by/api/v4/contest/"
    static let fetchLimit = 200
}

/// Top-level clist API response envelope.
private struct ClistContestResponse: Decodable {
    let objects: [ClistContest]
}

/// A single contest object from clist's `/api/v4/contest/` endpoint.
private struct ClistContest: Decodable {
    let event: String     // contest name
    let href: String      // contest url
    let start: String     // naive-UTC ISO, e.g. "2026-11-13T00:00:00"
    let end: String       // naive-UTC ISO
    let duration: Double  // seconds
    let resource: String  // host, e.g. "codeforces.com" (matches KontestDTO.site)
}

final class ClistAPIRepository: Fetcher, KontestFetcher {
    typealias DataType = KontestDTO

    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "ClistAPIRepository")

    func getData() async throws -> [KontestDTO] {
        try await getAllKontests()
    }

    func getAllKontests() async throws -> [KontestDTO] {
        guard var components = URLComponents(string: ClistAPIConfig.baseURL) else {
            logger.error("Error in making clist url")
            throw URLError(.badURL)
        }

        components.queryItems = [
            URLQueryItem(name: "upcoming", value: "true"),
            URLQueryItem(name: "order_by", value: "start"),
            URLQueryItem(name: "limit", value: String(ClistAPIConfig.fetchLimit)),
        ]

        guard let url = components.url else {
            logger.error("Error in making clist url")
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue(
            "ApiKey \(ClistAPIConfig.username):\(ClistAPIConfig.apiKey)",
            forHTTPHeaderField: "Authorization"
        )

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200 ..< 300).contains(httpResponse.statusCode)
            else {
                logger.error("clist API returned a non-success response")
                throw URLError(.badServerResponse)
            }

            let decoded = try JSONDecoder().decode(ClistContestResponse.self, from: data)

            let kontests: [KontestDTO] = decoded.objects.map { contest in
                KontestDTO(
                    name: contest.event,
                    url: contest.href,
                    startTime: Self.toAppDateString(contest.start),
                    endTime: Self.toAppDateString(contest.end),
                    duration: String(Int(contest.duration)),
                    site: contest.resource,
                    in_24_hours: "NO",
                    status: "CODING"
                )
            }

            return kontests
        } catch {
            logger.error("Error in fetching clist Kontests: \(error.localizedDescription)")
            throw error
        }
    }

    /// clist returns naive-UTC ISO strings like `"2026-11-13T00:00:00"`.
    /// `CalendarUtility.getDate` parses the `"yyyy-MM-dd HH:mm:ss zzz"` format
    /// (e.g. `"2022-10-10 06:30:00 UTC"`), so convert into that shape.
    private static func toAppDateString(_ clistTime: String) -> String {
        let withoutFraction = clistTime.split(separator: ".").first.map(String.init) ?? clistTime
        let spaced = withoutFraction.replacingOccurrences(of: "T", with: " ")
        return "\(spaced) UTC"
    }
}
