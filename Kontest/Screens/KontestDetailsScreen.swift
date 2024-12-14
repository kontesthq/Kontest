//
//  KontestDetailsScreen.swift
//  Kontest
//
//  Created by Ayush Singhal on 14/08/23.
//

import SwiftUI
import WidgetKit

#if os(iOS)
struct KontestDetailsScreen: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var isFaded = false

    var kontest: KontestModel

    let kontestDetailViewModel: KontestDetailViewModel

    init(kontest: KontestModel) {
        self.kontest = kontest

        kontestDetailViewModel = KontestDetailViewModel(kontest: kontest)
    }

    var body: some View {
        let kontestStartDate = CalendarUtility.getDate(date: kontest.start_time)
        let kontestEndDate = CalendarUtility.getDate(date: kontest.end_time)

        VStack {
            VStack {
                let timeDifferenceString = CalendarUtility.getTimeDifferenceString(startDate: kontestStartDate ?? Date(), endDate: kontestEndDate ?? Date())

                TopCardView(color: KontestModel.getColorForIdentifier(siteAbbreviation: kontest.siteAbbreviation), kontestStartDate: kontestStartDate ?? Date(), kontestEndDate: kontestEndDate ?? Date(), boxText: timeDifferenceString)
                    .frame(height: 300)

                Spacer()

                VStack {
                    HStack {
                        Text(kontest.siteAbbreviation.uppercased())
                            .foregroundStyle(KontestModel.getColorForIdentifier(siteAbbreviation: kontest.siteAbbreviation))
                            .padding(.horizontal)

                        if kontestDetailViewModel.isKontestRunning {
                            BlinkingDotView(color: .green)
                                .frame(width: 10, height: 10)
                        }
                    }

                    Text(kontest.name)

                    if kontestDetailViewModel.isKontestRunning || kontestDetailViewModel.isKontestOfFutureAndStartingInLessThan24Hours {
                        TimelineView(.periodic(from: .now, by: 1)) { timelineViewDefaultContext in
                            RemainingTimeView(kontestStartDate: kontestStartDate ?? Date(), kontestEndDate: kontestEndDate ?? Date(), isKontestRunning: kontestDetailViewModel.isKontestRunning, isKontestOfFutureAndStartingInLessThan24Hours: kontestDetailViewModel.isKontestOfFutureAndStartingInLessThan24Hours, timelineViewDefaultContext: timelineViewDefaultContext)
                                .padding()
                        }
                    } else if !kontestDetailViewModel.isKontestRunning, kontestDetailViewModel.wasKontestRunning {
                        Text("Kontest has Ended")
                            .font(Font.title2)
                            .padding()
                    }
                }

                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
            .multilineTextAlignment(.center)
            .ignoresSafeArea(edges: .top)

            ButtonsView(kontest: kontest)
        }
        .frame(maxHeight: .infinity)
    }
}

struct ButtonsView: View {
    let kontest: KontestModel
    let kontestStartDate: Date?
    let kontestEndDate: Date?
    @Environment(ErrorState.self) private var errorState

    @State private var isCalendarPopoverVisible: Bool = false

    let notificationsViewModel: NotificationsViewModel

    init(kontest: KontestModel) {
        self.kontest = kontest
        kontestStartDate = CalendarUtility.getDate(date: kontest.start_time)
        kontestEndDate = CalendarUtility.getDate(date: kontest.end_time)
        notificationsViewModel = Dependencies.instance.notificationsViewModel
    }

    var body: some View {
        VStack {
//            if CalendarUtility.isKontestRunning(kontestStartDate: kontestStartDate ?? Date(), kontestEndDate: kontestEndDate ?? Date()) {
            VStack {
                Button((ActivityManager.shared.kontest == nil || ActivityManager.shared.kontest != kontest) ? "Start Live Activity" : "Stop Live Activity") {
                    Task {
                        if ActivityManager.shared.activityID == nil || ActivityManager.shared.kontest != kontest {
                            await ActivityManager.shared.start(kontest: kontest)
                        } else {
                            await ActivityManager.shared.endActivity()
                        }
                    }
                }
                .padding(.vertical)
            }
//            }

            if CalendarUtility.isKontestOfFuture(kontestStartDate: kontestStartDate ?? Date()), notificationsViewModel.getNumberOfNotificationsWhichCanBeSettedForAKontest(kontest: kontest) > 0 {
                SingleNotificationMenu(kontest: kontest)
                    .controlSize(.large)

                if let kontestStartDate {
                    Button {
                        let authorizationStatus = CalendarUtility.getAuthorizationStatus()

                        if authorizationStatus == .fullAccess {
                            isCalendarPopoverVisible = true
                        } else {
                            Task {
                                do {
                                    let isGranted = try await CalendarUtility.requestFullAccessToReminders()

                                    if !isGranted {
                                        throw AppError(title: "Permission not Granted", description: "Calendar Permission is not granted.")
                                    }

                                } catch {
                                    errorState.errorWrapper = ErrorWrapper(error: error, guidance: "Check that you have given Kontest the Calendar Permission (Full Access)")
                                }
                            }
                        }

                    } label: {
                        Text(kontest.isCalendarEventAdded ? "Update in Calendar" : "Add to Calendar")
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .popover(isPresented: $isCalendarPopoverVisible, arrowEdge: .bottom) {
                        CalendarPopoverView(date: kontest.calendarEventDate != nil ? kontest.calendarEventDate! : kontestStartDate.addingTimeInterval(-15 * 60),
                                            kontestStartDate: kontestStartDate,
                                            isAlreadySetted: kontest.isCalendarEventAdded,
                                            calendarName: kontest.selectedCalendarName,
                                            calendarAccount: kontest.selectedCalendarAccount,
                                            onPressDelete: {
                                                print(kontest.isCalendarEventAdded ? "Delete" : "Cancel")

                                                Task {
                                                    do {
                                                        try await CalendarUtility.removeEvent(startDate: kontestStartDate, endDate: kontestEndDate ?? Date(), title: kontest.name, notes: "", url: URL(string: kontest.url))

                                                        kontest.isCalendarEventAdded = false
                                                        kontest.calendarEventDate = nil
                                                    } catch {
                                                        errorState.errorWrapper = ErrorWrapper(error: error, guidance: "Check that you have given Kontest the Calendar Permission (Full Access)")
                                                    }

                                                    isCalendarPopoverVisible = false
                                                    WidgetCenter.shared.reloadAllTimelines()
                                                }
                                            },
                                            onPressSet: { setDate, selectedCalendar in
                                                print("setDate: \(setDate)")

                                                Task {
                                                    do {
                                                        if kontest.isCalendarEventAdded { // If one event was already setted, then remove it and set a new event
                                                            try await CalendarUtility.removeEvent(startDate: kontestStartDate, endDate: kontestEndDate ?? Date(), title: kontest.name, notes: "", url: URL(string: kontest.url))
                                                        }

                                                        if try await CalendarUtility.addEvent(
                                                            startDate: kontestStartDate,
                                                            endDate: kontestEndDate ?? Date(),
                                                            title: kontest.name,
                                                            notes: "",
                                                            url: URL(string: kontest.url),
                                                            alarmAbsoluteDate: setDate,
                                                            calendar: selectedCalendar
                                                        ) {
                                                            kontest.isCalendarEventAdded = true
                                                            kontest.calendarEventDate = setDate
                                                        }
                                                    } catch {
                                                        errorState.errorWrapper = ErrorWrapper(error: error, guidance: "")
                                                    }

                                                    isCalendarPopoverVisible = false
                                                    WidgetCenter.shared.reloadAllTimelines()
                                                }
                                            })
                                            .presentationCompactAdaptation(.popover)
                    }
                }
            }

            Link(destination: URL(string: kontest.url)!, label: {
                Text("Contest Registration Page")
                    .frame(maxWidth: .infinity)
            })
            .controlSize(.large)
        }
        .foregroundStyle(KontestModel.getColorForIdentifier(siteAbbreviation: kontest.siteAbbreviation))
        .buttonStyle(.bordered)
        .padding()
    }
}

struct TopCardView: View {
    @Environment(\.colorScheme) var colorScheme

    let color: Color
    let kontestStartDate: Date
    let kontestEndDate: Date
    let boxText: String

    var startDateComponenets: DateComponents
    var endDateComponenets: DateComponents

    init(color: Color, kontestStartDate: Date, kontestEndDate: Date, boxText: String) {
        self.color = color
        self.kontestStartDate = kontestStartDate
        self.kontestEndDate = kontestEndDate
        self.boxText = boxText

        startDateComponenets = Calendar.current.dateComponents([.weekday], from: kontestStartDate)
        endDateComponenets = Calendar.current.dateComponents([.weekday], from: kontestEndDate)
    }

    var body: some View {
        ZStack {
            TopCard(color: color)

            HStack(alignment: .top) {
                TimeView(day: CalendarUtility.getWeekdayNameFromDate(date: kontestStartDate), time: kontestStartDate.formatted(date: .omitted, time: .shortened), date: CalendarUtility.getKontestDate(date: kontestStartDate), horizontalAlignment: .leading)
                    .padding(.leading)
                Spacer()

                BoxView(blockColor: colorScheme == .light ? .white : .black, textColor: color, text: boxText)
                    .frame(width: 50, height: 50)

                Spacer()

                TimeView(day: CalendarUtility.getWeekdayNameFromDate(date: kontestEndDate), time: kontestEndDate.formatted(date: .omitted, time: .shortened), date: CalendarUtility.getKontestDate(date: kontestEndDate), horizontalAlignment: .trailing)
                    .padding(.trailing)
            }
        }
    }
}

struct TopCard: View {
    let color: Color
    var body: some View {
        UnevenRoundedRectangle(bottomLeadingRadius: 40, bottomTrailingRadius: 40)
            .foregroundStyle(color)
    }
}

struct BoxView: View {
    let blockColor: Color
    let textColor: Color
    let text: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(blockColor)
                .aspectRatio(1, contentMode: .fill)
            Text(text)
                .scaledToFill()
                .padding(.horizontal, 5)
                .foregroundStyle(textColor)
        }
    }
}

struct TimeView: View {
    @Environment(\.colorScheme) var colorScheme
    var day: String
    var time: String
    var date: String
    let horizontalAlignment: HorizontalAlignment

    var body: some View {
        VStack(alignment: horizontalAlignment) {
            Text(day)
                .alignmentGuide(.leading) { _ in 0 }
                .font(.title)
                .bold()
                .frame(alignment: .leading)

            Text(time)
                .alignmentGuide(.leading) { _ in 0 }
                .font(.headline)
                .bold()
                .frame(alignment: .leading)

            Text(date)
                .alignmentGuide(.leading) { _ in 0 }
                .font(.headline)
                .bold()
                .frame(alignment: .leading)
        }
        .foregroundStyle(colorScheme == .light ? .white : .black)
    }
}

struct RemainingTimeView: View {
    let kontestStartDate: Date
    let kontestEndDate: Date
    let isKontestRunning: Bool
    let isKontestOfFutureAndStartingInLessThan24Hours: Bool
    let timelineViewDefaultContext: TimelineViewDefaultContext

    var body: some View {
        if isKontestRunning {
            let date = timelineViewDefaultContext.date
            let timeInterval = kontestEndDate.timeIntervalSince(date)
            let seconds = timeInterval >= 0 ? timeInterval : 0
            let remainingTimeInEndingOfRunningKontest = CalendarUtility.formattedTimeFrom(seconds: Int(seconds))

            Text("Ends in \(remainingTimeInEndingOfRunningKontest)")
                .font(Font.title2.monospacedDigit())
                .contentTransition(.numericText())
                .animation(.easeInOut, value: remainingTimeInEndingOfRunningKontest)
        }

        if isKontestOfFutureAndStartingInLessThan24Hours {
            let date = timelineViewDefaultContext.date
            let seconds = kontestStartDate.timeIntervalSince(date)

            let remainingTimeInStartingOfFutureKontest = CalendarUtility.formattedTimeFrom(seconds: Int(seconds))

            Text("Starting in \(remainingTimeInStartingOfFutureKontest)")
                .font(Font.title2.monospacedDigit())
                .contentTransition(.numericText())
                .animation(.easeInOut, value: remainingTimeInStartingOfFutureKontest)
        }
    }
}

#Preview {
//    KontestDetailsView(kontest: KontestModel.from(dto: KontestDTO(name: "Starters 100 (Date to be decided)", url: "https://www.codechef.com/START100", start_time: "2023-08-30 14:30:00 UTC", end_time: "2023-08-30 16:30:00 UTC", duration: "7200", site: "CodeChef", in_24_hours: "No", status: "BEFORE")))

//    let startTime = "2023-08-14 17:42:00 UTC"
//    let endTime = "2023-08-21 17:43:00 UTC"

    let startTime = "2024-10-30 00:00:00 UTC"
    let endTime = "2024-11-30 23:59:00 UTC"

//    return KontestDetailsScreen(kontest: KontestModel.from(dto: KontestDTO(name: "ProjectEuler+", url: "https://hackerrank.com/contests/projecteuler", start_time: startTime, end_time: endTime, duration: "1020.0", site: "HackerRank", in_24_hours: "No", status: "CODING")))
//        .environment(AllKontestsViewModel())

    return KontestDetailsScreen(kontest: KontestModel.from(dto: KontestDTO(name: "THIRD PROGRAMMING CONTEST 2023 ALGO (AtCoder Beginner Contest 318)", url: "https://hackerrank.com/contests/projecteuler", startTime: startTime, endTime: endTime, duration: "1020.0", site: "AtCoder", in_24_hours: "No", status: "CODING")))
        .environment(Dependencies.instance.allKontestsViewModel)
        .environment(ErrorState())
}

// #Preview("TopCardView") {
//    TopCardView(color: .pink)
// }
//
// #Preview("TopCard") {
//    TopCard(color: .pink)
// }
//
// #Preview("BlockView") {
//    BlockView(blockColor: .black, textColor: .pink, text: "2HR")
// }

// #Preview("TimeView") {
//    TimeView(horizontalAlignment: .leading)
// }
#endif
