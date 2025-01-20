//
//  CodeChefViewModel.swift
//  Kontest
//
//  Created by Ayush Singhal on 27/08/23.
//

import Foundation
import OSLog

@Observable
final class CodeChefViewModel: Sendable {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "CodeChefViewModel")

    let codeChefAPIRepository: any CodeChefFetcher

    let username: String
    var codeChefProfile: CodeChefAPIModel?

    var attendedKontests: [CodeChefScrapingContestModel] = []

    var isLoading = false

    var error: (any Error)?

    init(username: String, codeChefAPIRepository: any CodeChefFetcher) {
        self.isLoading = true
        self.username = username
        self.codeChefAPIRepository = codeChefAPIRepository

        self.sortedDates = []

        self.chartXScrollPosition = .now

        if !username.isEmpty {
            Task {
                await self.getCodeChefProfile(username: username)
                await self.getCodeChefRatings(username: username)

                self.sortedDates = attendedKontests.map { attendedKontest in
                    let timestamp = CalendarUtility.getFormattedDateForCodeChefKontestRatings(date: attendedKontest.endDate)
                    return timestamp ?? .now
                }

                self.chartXScrollPosition = sortedDates.first?.addingTimeInterval(-86400 * 3) ?? .now

                self.isLoading = false
            }
        } else {
            self.isLoading = false
        }
    }

    private func getCodeChefProfile(username: String) async {
        do {
            let fetchedCodeChefProfile = try await codeChefAPIRepository.getUserData(username: username)

            codeChefProfile = CodeChefAPIModel.from(codeChefAPIDTO: fetchedCodeChefProfile)
        } catch {
            self.error = error
            logger.error("error in fetching CodeChef Profile: \(error)")
        }
    }

    private func getCodeChefRatings(username: String) async {
        do {
            let fetchedCodeChefRatings = try await codeChefAPIRepository.getUserKontests(username: username)

            attendedKontests.append(contentsOf:
                fetchedCodeChefRatings.map {
                    codeChefScrapingContestDTO in
                    CodeChefScrapingContestModel.from(dto: codeChefScrapingContestDTO)
                })
        } catch {
            self.error = error
            logger.error("error in fetching CodeChef Ratings: \(error)")
        }
    }

    var sortedDates: [Date]

    @ObservationIgnored
    var rawSelectedDate: Date? {
        didSet(newValue) {
            if let newValue {
                print("rawSelectedDate changed")

                let selectedDay = Calendar.current.startOfDay(for: newValue)

                let foundDate = sortedDates.first { date in
                    Calendar.current.startOfDay(for: date) == selectedDay
                }

                if let foundDate {
                    selectedDate = foundDate
                } else {
                    if selectedDate != nil {
                        selectedDate = nil
                    }
                }
            }
        }
    }

    var selectedDate: Date? {
        didSet {
            print("selectedDate changed")
        }
    }

    @ObservationIgnored
    var chartXScrollPosition: Date {
        willSet {
            print("chartScrollPosition willSet")
        }

        didSet {
            print("chartScrollPosition didSet")
        }
    }
}
