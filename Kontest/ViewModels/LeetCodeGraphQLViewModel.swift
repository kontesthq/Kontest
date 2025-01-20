//
//  LeetCodeGraphQLViewModel.swift
//  Kontest
//
//  Created by Ayush Singhal on 04/09/23.
//

import Foundation
import OSLog

@Observable
final class LeetCodeGraphQLViewModel: Sendable {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "FilterWebsitesViewModel")

    let repository: any LeetCodeGraphQLAPIFetcher
    let username: String

    var leetCodeUserProfileGraphQLAPIModel: LeetCodeUserProfileGraphQLAPIModel?
    var userContestRanking: LeetCodeUserRankingGraphQLAPIModel?
    var userContestRankingHistory: [LeetCodeUserRankingHistoryGraphQLAPIModel?]?
    var error: (any Error)?

    var isLoading: Bool = false
    var isFetchingUserData: Bool = false
    var isFetchingUserRankings: Bool = false

    init(username: String, repository: any LeetCodeGraphQLAPIFetcher) {
        self.username = username
        self.isFetchingUserData = true
        self.isFetchingUserRankings = true
        self.isLoading = true
        self.repository = repository

        self.sortedDates = []

        self.chartXScrollPosition = .now

        if !username.isEmpty {
            Task {
                await withTaskGroup(of: Void.self) { taskGroup in
                    // fetching user data
                    taskGroup.addTask {
                        do {
                            self.isLoading = true
                            let leetCodeUserProfileGraphQLAPIDTO = try await self.repository.getUserData(username: username)

                            self.leetCodeUserProfileGraphQLAPIModel = LeetCodeUserProfileGraphQLAPIModel.from(leetCodeUserProfileGraphQLAPIDTO: leetCodeUserProfileGraphQLAPIDTO)
                            self.error = nil

                            self.isFetchingUserData = false
                            self.isLoading = (self.isFetchingUserData) || (self.isFetchingUserRankings)
                        } catch {
                            self.isFetchingUserData = false
                            self.logger.error("Failed to fetchUserData.")
                            self.error = URLError(.badURL)
                        }
                    }

                    // fetching user rankings
                    taskGroup.addTask {
                        do {
                            self.isLoading = true
                            let leetCodeUserRankingsGraphQLAPIDTO = try await self.repository.getUserRankingInfo(username: username)

                            if leetCodeUserRankingsGraphQLAPIDTO.leetCodeUserRankingGraphQLAPIDTO == nil {
                                throw URLError(.badURL)
                            }

                            let userContestRanking = LeetCodeUserRankingGraphQLAPIModel.from(leetCodeUserRankingGraphQLAPIDTO: leetCodeUserRankingsGraphQLAPIDTO.leetCodeUserRankingGraphQLAPIDTO)

                            let userContestRankingHistory = LeetCodeUserRankingHistoryGraphQLAPIModel.from(leetCodeUserRankingHistoryGraphQLAPIDTOs: leetCodeUserRankingsGraphQLAPIDTO.leetCodeUserRankingHistoryGraphQLAPIDTO)

                            self.userContestRanking = userContestRanking
                            self.userContestRankingHistory = userContestRankingHistory

                            if let ratings = userContestRankingHistory {
                                for rating in ratings {
                                    if let rating, rating.attended ?? false == true {
                                        self.attendedKontests.append(rating)
                                    }
                                }
                            }

                            self.error = nil
                            self.isFetchingUserRankings = false
                            self.isLoading = (self.isFetchingUserData) || (self.isFetchingUserRankings)
                        } catch {
                            self.isLoading = false
                            self.isFetchingUserRankings = false
                            self.logger.error("Failed to fetchUserRankings.")
                            self.error = URLError(.badURL)
                        }
                    }
                }

                self.sortedDates = attendedKontests.map { ele in
                    let timestamp = ele.contest?.startTime ?? "-1"
                    return Date(timeIntervalSince1970: TimeInterval(timestamp) ?? -1)
                }

                self.chartXScrollPosition = sortedDates.first?.addingTimeInterval(-86400 * 3) ?? .now
            }
        } else {
            self.isLoading = false
        }
    }

    // Chart properties
    var attendedKontests: [LeetCodeUserRankingHistoryGraphQLAPIModel] = []

    var sortedDates: [Date]
//    var sortedDates: [Date] {
//        attendedKontests.map { ele in
//            let timestamp = ele.contest?.startTime ?? "-1"
//            return Date(timeIntervalSince1970: TimeInterval(timestamp) ?? -1)
//        }
//    }

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
