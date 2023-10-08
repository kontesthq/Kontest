//
//  LeetcodeGraphView.swift
//  Kontest
//
//  Created by Ayush Singhal on 30/09/23.
//

import SwiftUI

import Charts
import SwiftUI

struct LeetcodeGraphView: View {
    let leetcodeGraphQLViewModel: LeetCodeGraphQLViewModel = Dependencies.instance.leetCodeGraphQLViewModel

    @State private var attendedContests: [LeetCodeUserRankingHistoryGraphQLAPIModel]
    @State private var showAnnotations: Bool = true

    @State private var rawSelectedDate: Date?

    @State private var sortedDates: [Date] = []

    var selectedDate: Date? {
        guard let rawSelectedDate = rawSelectedDate else { return nil }

        let selectedDay = Calendar.current.startOfDay(for: rawSelectedDate)

        if let matchingDate = sortedDates.first(where: { Calendar.current.startOfDay(for: $0) == selectedDay }) {
            return matchingDate
        }

        return nil
    }

    init() {
        _attendedContests = State(initialValue: [])
    }

    var body: some View {
        VStack {
            if leetcodeGraphQLViewModel.isLoading {
                ProgressView()
            } else {
                if let error = leetcodeGraphQLViewModel.error {
                    Text("Error: \(error.localizedDescription)")
                } else {
                    Text(leetcodeGraphQLViewModel.username)
                        .onAppear {
                            if let ratings = leetcodeGraphQLViewModel.userContestRankingHistory {
                                attendedContests.removeAll(keepingCapacity: true)

                                for rating in ratings {
                                    if let rating, rating.attended ?? false == true {
                                        attendedContests.append(rating)
                                    }
                                }

                                sortedDates = attendedContests.map { ele in
                                    let timestamp = ele.contest?.startTime ?? "-1"
                                    return Date(timeIntervalSince1970: TimeInterval(timestamp) ?? -1)
                                }
                            }
                        }

                    Text("Total Kontests attended: \(attendedContests.count)")

                    Toggle("Show Annotations?", isOn: $showAnnotations)
                        .toggleStyle(.switch)
                        .padding(.horizontal)

                    Chart {
                        ForEach(attendedContests, id: \.contest?.title) { attendedContest in
                            let timestamp = TimeInterval(Int(attendedContest.contest?.startTime ?? "-1") ?? -1)
                            let date = Date(timeIntervalSince1970: timestamp)

                            PointMark(x: .value("Time", date, unit: .day), y: .value("Ratings", attendedContest.rating ?? -1))
                                .opacity(0)
                                .annotation(position: .top) {
                                    if showAnnotations {
                                        Text("\(Int(attendedContest.rating ?? -1))")
                                    }
                                }
                                .annotation(position: .bottom) {
                                    if showAnnotations {
                                        VStack {
                                            Text("\(date.formatted(date: .numeric, time: .shortened))")

                                            #if os(macOS)
                                                Text(attendedContest.contest?.title ?? "")
                                            #endif
                                        }
                                    }
                                }

                            if let selectedDate {
                                let kontest = getKontestFromDate(date: selectedDate)

                                RuleMark(x: .value("selectedDate", selectedDate, unit: .day))
                                    .zIndex(-1)
                                    .annotation(position: .leading, spacing: 0, overflowResolution: .init(
                                        x: .fit(to: .chart),
                                        y: .disabled
                                    )) {
                                        if let kontest {
                                            VStack(spacing: 10) {
                                                Text(kontest.contest?.title ?? "")

                                                Text("\(selectedDate.formatted())")

                                                if let problemsSolved = kontest.problemsSolved {
                                                    Text("Total problems solved: \(problemsSolved)")
                                                }

                                                if let ranking = kontest.ranking {
                                                    Text("Ranking: \(ranking)")
                                                }

                                                if let rating = kontest.rating {
                                                    Text("rating: \(rating)")
                                                }
                                            }
                                            .padding()
                                        }
                                    }

                                if let rating = kontest?.rating {
                                    PointMark(x: .value("selectedDate", selectedDate, unit: .day), y: .value("", rating))
                                }
                            }

                            LineMark(x: .value("Time", date, unit: .day), y: .value("Ratings", attendedContest.rating ?? -1))
                                .interpolationMethod(.catmullRom)
                                .symbol(Circle().strokeBorder(lineWidth: 2))
                        }
                    }
                    .chartScrollableAxes(.horizontal)
                    .chartXVisibleDomain(length: 3600*24*30) // 30 days
                    .padding(.horizontal)
                    .chartXSelection(value: $rawSelectedDate)
                }
            }
        }
        .navigationTitle("Leetcode Rankings")
    }

    private func getKontestFromDate(date: Date) -> LeetCodeUserRankingHistoryGraphQLAPIModel? {
        return attendedContests.first { leetCodeUserRankingHistoryGraphQLAPIModel in
            let timestamp = TimeInterval(Int(leetCodeUserRankingHistoryGraphQLAPIModel.contest?.startTime ?? "-1") ?? -1)

            return date == Date(timeIntervalSince1970: timestamp)
        }
    }
}

#Preview {
    LeetcodeGraphView()
        .frame(width: 500, height: 300)
}
