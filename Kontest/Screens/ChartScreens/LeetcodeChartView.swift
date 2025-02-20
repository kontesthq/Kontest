//
//  LeetcodeChartView.swift
//  Kontest
//
//  Created by Ayush Singhal on 30/09/23.
//

import Charts
import OSLog
import SwiftUI

struct LeetcodeChartView: View {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "LeetcodeChartView")

    let leetcodeGraphQLViewModel: LeetCodeGraphQLViewModel = Dependencies.instance.leetCodeGraphQLViewModel

    @State private var showAnnotations: Bool = true
    @State private var hasAnimated: Bool = false

    #if os(iOS)
        let accentColor = Color(uiColor: UIColor.systemYellow)
    #elseif os(macOS)
        let accentColor = Color(nsColor: NSColor.systemYellow)
    #endif

    var body: some View {
        VStack {
            if leetcodeGraphQLViewModel.username.isEmpty {
                Text("Please update your username in the settings")
            } else if leetcodeGraphQLViewModel.isLoading {
                ProgressView()
            } else {
                if let error = leetcodeGraphQLViewModel.error {
                    Text("Error: \(error.localizedDescription)")

                } else {
                    Text(leetcodeGraphQLViewModel.username)
                        .onAppear {
                            animateChart()
                        }

                    Text("Total Kontests attended: \(leetcodeGraphQLViewModel.attendedKontests.count)")

                    Toggle("Show Annotations?", isOn: $showAnnotations)
                        .toggleStyle(.switch)
                        .padding(.horizontal)
                        .tint(accentColor)

                    LeetCodeChart(
                        showAnnotations: $showAnnotations
                    )
                }
            }
        }
        .navigationTitle("Leetcode Rankings")
        .sensoryFeedback(getDeviceType() == .macOS ? .alignment : .impact, trigger: leetcodeGraphQLViewModel.selectedDate) { _, selectedDate in
            selectedDate != nil
        }
    }

    private func animateChart() {
        guard !hasAnimated else { return }
        hasAnimated = true

        for (index, _) in leetcodeGraphQLViewModel.attendedKontests.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                withAnimation(.smooth) {
                    leetcodeGraphQLViewModel.attendedKontests[index].hasAnimated = true
                }
            }
        }
    }
}

struct LeetCodeChart: View {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "MyChart")

    let leetcodeGraphQLViewModel: LeetCodeGraphQLViewModel = Dependencies.instance.leetCodeGraphQLViewModel

    @Binding var showAnnotations: Bool

    @State private var visibleDates: [Date] = [.now, .now]

    let leetCodeGraphQLViewModel = Dependencies.instance.leetCodeGraphQLViewModel

    let curGradient = LinearGradient(
        gradient: Gradient(
            colors: [
                Color(.systemYellow).opacity(0.8),
                Color(.systemYellow).opacity(0.5),
                Color(.systemYellow).opacity(0.35),
                Color(.systemYellow).opacity(0.3),
                Color(.systemYellow).opacity(0.2),
                Color(.systemYellow).opacity(0.15),
                Color(.systemYellow).opacity(0.1),
                Color(.systemYellow).opacity(0.05),
                Color(.systemYellow).opacity(0.03),
                Color(.systemYellow).opacity(0.01),
                Color(.systemYellow).opacity(0)
            ]
        ),
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        let _ = Self._printChanges()

        Chart {
            ForEach(leetCodeGraphQLViewModel.attendedKontests) { attendedContest in
                let timestamp = TimeInterval(Int(attendedContest.contest?.startTime ?? "-1") ?? -1)
                let date = Date(timeIntervalSince1970: timestamp)

                PointMark(x: .value("Time", date, unit: .day), y: .value("Ratings", attendedContest.hasAnimated ? (attendedContest.rating ?? -1) : 0))
                    .opacity(0)
                    .annotation(position: .top) {
                        if showAnnotations {
                            Text("\(Int(attendedContest.rating ?? -1))")
                        }
                    }
                    .annotation(position: .bottom) {
                        if showAnnotations {
                            VStack {
                                Text("\(date.formatted(date: .numeric, time: .omitted))")
                            }
                        }
                    }

                LineMark(x: .value("Time", date, unit: .day), y: .value("Ratings", attendedContest.hasAnimated ? (attendedContest.rating ?? -1) : 0))
                    .interpolationMethod(.catmullRom)
                    .symbol(Circle().strokeBorder(lineWidth: 2))

                AreaMark(x: .value("Time", date, unit: .day), y: .value("Ratings", attendedContest.hasAnimated ? (attendedContest.rating ?? -1) : 0))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(curGradient)

                if let selectedDate = leetCodeGraphQLViewModel.selectedDate, let kontest = getKontestFromDate(date: selectedDate), let contest = kontest.contest {
                    RuleMark(x: .value("selectedDate", selectedDate, unit: .day))
                        .zIndex(-1)
                        .annotation(position: .trailing, spacing: 0, overflowResolution: .init(
                            x: .fit(to: .chart),
                            y: .disabled
                        )) {
                            VStack(spacing: 10) {
                                Text(contest.title ?? "")

                                Text("\(selectedDate.formatted(date: .abbreviated, time: .shortened))")

                                if let problemsSolved = kontest.problemsSolved {
                                    Text("Total problems solved: \(problemsSolved)")
                                }

                                if let ranking = kontest.ranking {
                                    Text("Ranking: \(ranking)")
                                }

                                if !showAnnotations {
                                    if let rating = kontest.rating {
                                        Text("Rating: \(Int(rating))")
                                    }
                                }
                            }
                            .padding()
                        }

                    if let rating = kontest.rating {
                        PointMark(x: .value("selectedDate", selectedDate, unit: .day), y: .value("", rating))
                    }
                }
            }
        }
        .chartYScale(domain: 0 ... 2000)
        #if os(iOS)
            .foregroundStyle(Color(uiColor: UIColor.systemYellow))
        #elseif os(macOS)
            .foregroundStyle(Color(nsColor: NSColor.systemYellow))
        #endif
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 3600 * 24 * 30 * 2) // 30 * 2 days
            .padding(.horizontal)
            .chartXSelection(value: Bindable(leetCodeGraphQLViewModel).rawSelectedDate)
//        .chartScrollPosition(x: Bindable(model).chartXScrollPosition)
            .animation(.default, value: showAnnotations)
    }
}

extension LeetCodeChart {
    private func getKontestFromDate(date: Date) -> LeetCodeUserRankingHistoryGraphQLAPIModel? {
        return leetCodeGraphQLViewModel.attendedKontests.first { leetCodeUserRankingHistoryGraphQLAPIModel in
            let timestamp = TimeInterval(Int(leetCodeUserRankingHistoryGraphQLAPIModel.contest?.startTime ?? "-1") ?? -1)

            return date == Date(timeIntervalSince1970: timestamp)
        }
    }
}

#Preview {
    LeetcodeChartView()
        .frame(width: 500, height: 300)
}
