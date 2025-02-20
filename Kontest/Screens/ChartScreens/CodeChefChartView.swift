//
//  CodeChefChartView.swift
//  Kontest
//
//  Created by Ayush Singhal on 1/13/24.
//

import Charts
import Foundation
import SwiftUI

struct CodeChefChartView: View {
    let codeChefViewModel: CodeChefViewModel = Dependencies.instance.codeChefViewModel

    @State private var showAnnotations: Bool = true
    @State private var hasAnimated: Bool = false

    #if os(iOS)
        let accentColor = Color(uiColor: UIColor.systemBrown)
    #elseif os(macOS)
        let accentColor = Color(nsColor: NSColor.systemBrown)
    #endif

    var body: some View {
        VStack {
            if codeChefViewModel.username.isEmpty {
                Text("Please update your username in the settings")
            }
            else if codeChefViewModel.isLoading {
                ProgressView()
            }
            else {
                if let error = codeChefViewModel.error {
                    Text("Error: \(error.localizedDescription)")
                }
                else {
                    Text(codeChefViewModel.username)
                        .onAppear {
                            animateChart()
                        }
//                        .onDisappear {
//                            hasAnimated = false
//
//                            for (index, _) in codeChefViewModel.attendedKontests.enumerated() {
//                                codeChefViewModel.attendedKontests[index].hasAnimated = false
//                            }
//                        }

                    Text("Total Kontests attended: \(codeChefViewModel.attendedKontests.count)")

                    Toggle("Show Annotations?", isOn: $showAnnotations)
                        .toggleStyle(.switch)
                        .padding(.horizontal)
                        .tint(accentColor)

                    CodeChefChart(showAnnotations: $showAnnotations)
                }
            }
        }
        .navigationTitle("Codechef Rankings")
        .sensoryFeedback(getDeviceType() == .macOS ? .alignment : .impact, trigger: codeChefViewModel.selectedDate) { _, selectedDate in
            selectedDate != nil
        }
    }

    private func animateChart() {
        guard !hasAnimated else { return }
        hasAnimated = true

        for (index, _) in codeChefViewModel.attendedKontests.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                withAnimation(.smooth) {
                    codeChefViewModel.attendedKontests[index].hasAnimated = true
                }
            }
        }
    }
}

struct CodeChefChart: View {
    @Binding var showAnnotations: Bool

    let curGradient = LinearGradient(
        gradient: Gradient(
            colors: [
                Color(.systemBrown).opacity(0.8),
                Color(.systemBrown).opacity(0.5),
                Color(.systemBrown).opacity(0.35),
                Color(.systemBrown).opacity(0.3),
                Color(.systemBrown).opacity(0.2),
                Color(.systemBrown).opacity(0.15),
                Color(.systemBrown).opacity(0.1),
                Color(.systemBrown).opacity(0.05),
                Color(.systemBrown).opacity(0.03),
                Color(.systemBrown).opacity(0.01),
                Color(.systemBrown).opacity(0)
            ]
        ),
        startPoint: .top,
        endPoint: .bottom
    )

    let codeChefViewModel: CodeChefViewModel = Dependencies.instance.codeChefViewModel

    var body: some View {
        Chart {
            ForEach(codeChefViewModel.attendedKontests) { attendedKontest in
                let date = CalendarUtility.getFormattedDateForCodeChefKontestRatings(date: attendedKontest.endDate)

                let rating = Int(attendedKontest.rating)

                if let date {
                    PointMark(x: .value("Time", date, unit: .day), y: .value("Ratings", attendedKontest.hasAnimated ? rating : 0))
                        .opacity(0)
                        .annotation(position: .top) {
                            if showAnnotations {
                                Text("\(rating)")
                            }
                        }
                        .annotation(position: .bottom) {
                            if showAnnotations {
                                VStack {
                                    Text("\(date.formatted(date: .numeric, time: .shortened))")
                                }
                            }
                        }

                    LineMark(x: .value("Time", date, unit: .day), y: .value("Ratings", attendedKontest.hasAnimated ? rating : 0))
                        .interpolationMethod(.catmullRom)
                        .symbol(Circle().strokeBorder(lineWidth: 2))

                    AreaMark(x: .value("Time", date, unit: .day), y: .value("Ratings", attendedKontest.hasAnimated ? rating : 0))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(curGradient)
                }
            }

            if let selectedDate = codeChefViewModel.selectedDate, let kontest = getKontestFromDate(date: selectedDate) {
                RuleMark(x: .value("selectedDate", selectedDate, unit: .day))
                    .zIndex(-1)
                    .annotation(position: .leading, spacing: 0, overflowResolution: .init(
                        x: .fit(to: .chart),
                        y: .disabled
                    )) {
                        VStack(spacing: 10) {
                            Text(kontest.name)
                                .bold()

                            Text("Ended: \(selectedDate.formatted(date: Date.FormatStyle.DateStyle.abbreviated, time: .shortened))")

                            if showAnnotations {}
                            else {
                                Text("Rating: \(kontest.rating)")
                            }
                        }
                        .padding()
                    }

                PointMark(x: .value("selectedDate", selectedDate, unit: .day), y: .value("", kontest.rating))
            }
        }
        .chartYScale(domain: 0 ... 2000)
        #if os(iOS)
            .foregroundStyle(Color(uiColor: UIColor.systemBrown))
        #elseif os(macOS)
            .foregroundStyle(Color(nsColor: NSColor.systemBrown))
        #endif
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 3600 * 24 * 30 * 2) // 30 * 2 days
            .padding(.horizontal)
            .chartXSelection(value: Bindable(codeChefViewModel).rawSelectedDate)
            .animation(.default, value: showAnnotations)
    }
}

extension CodeChefChart {
    private func getKontestFromDate(date: Date) -> CodeChefScrapingContestModel? {
        return codeChefViewModel.attendedKontests.first { codeChefScrapingContestModel in
            let endDate = CalendarUtility.getFormattedDateForCodeChefKontestRatings(date: codeChefScrapingContestModel.endDate) ?? .now

            return date == endDate
        }
    }
}

#Preview {
    CodeChefChartView()
        .frame(width: 500, height: 500)
}
