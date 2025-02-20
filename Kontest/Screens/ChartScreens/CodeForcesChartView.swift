//
//  CodeForcesChartView.swift
//  Kontest
//
//  Created by Ayush Singhal on 30/09/23.
//

import Charts
import SwiftUI

struct CodeForcesChartView: View {
    let codeForcesViewModel: CodeForcesViewModel = Dependencies.instance.codeForcesViewModel

    @State private var showAnnotations: Bool = true
    @State private var hasAnimated: Bool = false

    #if os(iOS)
        let accentColor = Color(uiColor: UIColor.systemBlue)
    #elseif os(macOS)
        let accentColor = Color(nsColor: NSColor.systemBlue)
    #endif

    var body: some View {
        VStack {
            if codeForcesViewModel.username.isEmpty {
                Text("Please update your username in the settings")
            } else if codeForcesViewModel.isLoading {
                ProgressView()
            } else if codeForcesViewModel.error is AppError {
                let appError = codeForcesViewModel.error as! AppError

                Text(appError.title)
                    .bold()

                Text(appError.description)
            } else {
                if let error = codeForcesViewModel.error {
                    Text("Error: \(error.localizedDescription)")
                } else {
                    Text(codeForcesViewModel.username)
                        .onAppear {
                            animateChart()
                        }

                    Text("Total kontests attended: \(codeForcesViewModel.attendedKontests.count)")

                    Toggle("Show Annotations?", isOn: $showAnnotations)
                        .toggleStyle(.switch)
                        .padding(.horizontal)
                        .tint(accentColor)

                    CodeForcesChart(showAnnotations: $showAnnotations)
                }
            }
        }
        .navigationTitle("CodeForces Rankings")
        .sensoryFeedback(getDeviceType() == .macOS ? .alignment : .impact, trigger: codeForcesViewModel.selectedDate) { _, selectedDate in
            selectedDate != nil
        }
    }

    private func animateChart() {
        guard !hasAnimated else { return }
        hasAnimated = true

        for (index, _) in codeForcesViewModel.attendedKontests.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                withAnimation(.smooth) {
                    codeForcesViewModel.attendedKontests[index].hasAnimated = true
                }
            }
        }
    }
}

struct CodeForcesChart: View {
    @Binding var showAnnotations: Bool

    let codeForcesViewModel: CodeForcesViewModel = Dependencies.instance.codeForcesViewModel

    let curGradient = LinearGradient(
        gradient: Gradient(
            colors: [
                Color(.systemBlue).opacity(0.8),
                Color(.systemBlue).opacity(0.5),
                Color(.systemBlue).opacity(0.35),
                Color(.systemBlue).opacity(0.3),
                Color(.systemBlue).opacity(0.2),
                Color(.systemBlue).opacity(0.15),
                Color(.systemBlue).opacity(0.1),
                Color(.systemBlue).opacity(0.05),
                Color(.systemBlue).opacity(0.03),
                Color(.systemBlue).opacity(0.01),
                Color(.systemBlue).opacity(0)
            ]
        ),
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        Chart {
            ForEach(codeForcesViewModel.attendedKontests, id: \.contestId) { attendedContest in
                let updateTime = attendedContest.ratingUpdateTimeSeconds
                let updateDate = Date(timeIntervalSince1970: Double(updateTime))

                let newRating = attendedContest.newRating

                PointMark(x: .value("Time", updateDate, unit: .day), y: .value("Ratings", attendedContest.hasAnimated ? newRating : 0))
                    .opacity(0)
                    .annotation(position: .top) {
                        if showAnnotations {
                            Text("\(newRating)")
                        }
                    }
                    .annotation(position: .bottom) {
                        if showAnnotations {
                            VStack {
                                Text("\(updateDate.formatted(date: .numeric, time: .shortened))")

                                #if os(macOS)
                                    Text(attendedContest.contestName)
                                #endif
                            }
                        }
                    }

                LineMark(x: .value("Time", updateDate, unit: .day), y: .value("Ratings", attendedContest.hasAnimated ? newRating : 0))
                    .interpolationMethod(.catmullRom)
                    .symbol(Circle().strokeBorder(lineWidth: 2))

                AreaMark(x: .value("Time", updateDate, unit: .day), y: .value("Ratings", attendedContest.hasAnimated ? newRating : 0))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(curGradient)
            }

            if let selectedDate = codeForcesViewModel.selectedDate, let kontest = getKontestFromDate(date: selectedDate) {
                RuleMark(x: .value("selectedDate", selectedDate, unit: .day))
                    .zIndex(-1)
                    .annotation(position: .leading, spacing: 0, overflowResolution: .init(
                        x: .fit(to: .chart),
                        y: .disabled
                    )) {
                        VStack(spacing: 10) {
                            if showAnnotations {
                                Text("Old Rating: \(kontest.oldRating)")
                                    .bold()

                                Text("New Rating: \(kontest.newRating)")
                                    .bold()
                            } else {
                                Text(kontest.contestName)
                                    .bold()

                                Text("\(selectedDate.formatted(date: Date.FormatStyle.DateStyle.abbreviated, time: .shortened))")
                                    .bold()

                                Text("Old Rating: \(kontest.oldRating)")

                                Text("New Rating: \(kontest.newRating)")
                            }
                        }
                        .padding()
                    }
                PointMark(x: .value("selectedDate", selectedDate, unit: .day), y: .value("", kontest.newRating))
            }
        }
        .chartYScale(domain: 0 ... 2000)
        #if os(iOS)
            .foregroundStyle(Color(uiColor: UIColor.systemBlue))
        #elseif os(macOS)
            .foregroundStyle(Color(nsColor: NSColor.systemBlue))
        #endif
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 3600 * 24 * 30 * 2) // 30 * 2 days
            .padding(.horizontal)
            .chartXSelection(value: Bindable(codeForcesViewModel).rawSelectedDate)
            .animation(.default, value: showAnnotations)
    }
}

extension CodeForcesChart {
    private func getKontestFromDate(date: Date) -> CodeForcesuserRatingAPIResultModel? {
        codeForcesViewModel.codeForcesRatings?.result.first(where: { codeForcesuserRatingAPIResultModel in
            let updateTime = codeForcesuserRatingAPIResultModel.ratingUpdateTimeSeconds
            let updateDate = Date(timeIntervalSince1970: Double(updateTime))

            return updateDate == date
        })
    }
}

#Preview {
    CodeForcesChartView()
        .frame(width: 500, height: 500)
}
