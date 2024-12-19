//
//  SingleKontestView.swift
//  Kontest
//
//  Created by Ayush Singhal on 14/08/23.
//

import Combine
import SwiftUI
import WidgetKit

struct SingleKontestView: View {
    let kontest: KontestModel
    let timelineViewDefaultContext: TimelineViewDefaultContext
    @Environment(AllKontestsViewModel.self) private var allKontestsViewModel
    @Environment(ErrorState.self) private var errorState
    @Environment(\.colorScheme) private var colorScheme

    @State private var isCalendarPopoverVisible: Bool = false

    let notificationsViewModel: NotificationsViewModel

    let kontestStartDate: Date?
    let kontestEndDate: Date?

    let isKontestRunning: Bool
    let isKontestOfFutureAndStartingInLessThan24Hours: Bool

    init(kontest: KontestModel, timelineViewDefaultContext: TimelineViewDefaultContext) {
        self.kontest = kontest
        self.timelineViewDefaultContext = timelineViewDefaultContext
        kontestStartDate = CalendarUtility.getDate(date: kontest.start_time)
        kontestEndDate = CalendarUtility.getDate(date: kontest.end_time)
        isKontestRunning = CalendarUtility.isKontestRunning(kontestStartDate: kontestStartDate ?? Date(), kontestEndDate: kontestEndDate ?? Date()) || kontest.status == .OnGoing
        let isKontestOfFuture = CalendarUtility.isKontestOfFuture(kontestStartDate: kontestStartDate ?? Date())
        let isKontestStartingTimeLessThanADay = !(CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, minutes: 0, hours: 0, days: 1))
        isKontestOfFutureAndStartingInLessThan24Hours = isKontestOfFuture && isKontestStartingTimeLessThanADay

        notificationsViewModel = Dependencies.instance.notificationsViewModel
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack {
                #if os(macOS)
                Image(KontestModel.getLogo(siteAbbreviation: kontest.siteAbbreviation, colorScheme: colorScheme))
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: FontUtility.getLogoSize())
                #endif

                #if !os(iOS)
                if isKontestRunning {
                    BlinkingDotView(color: .green)
                        .frame(width: 10, height: 10)
                } else {
                    EmptyView()
                }
                #endif
            }
            .foregroundStyle(colorScheme == .light ? .black : .white)

            VStack(alignment: .leading) {
                HStack {
                    Text(kontest.siteAbbreviation.uppercased())
                        .foregroundStyle(KontestModel.getColorForIdentifier(siteAbbreviation: kontest.siteAbbreviation, colorScheme: colorScheme))
                        .bold()
                        .font(FontUtility.getSiteFontSize())

                    #if os(iOS)
                    if isKontestRunning {
                        BlinkingDotView(color: .green)
                            .frame(width: 10, height: 10)
                    }
                    #endif
                }

                Text(kontest.name)
                    .font(FontUtility.getNameFontSize())
                #if os(iOS)
                    .padding(.top, 1)
                    .lineLimit(1)
                #else
                    .multilineTextAlignment(.leading)
                #endif
            }
            .foregroundStyle(colorScheme == .light ? .black : .white)

            #if !os(iOS)
            Button {
                ClipboardUtility.copyToClipBoard(kontest.url)
            } label: {
                Image(systemName: "link")
            }
            .help("Copy link")

            if !isKontestRunning, let kontestStartDate {
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
                    Image(systemName: kontest.isCalendarEventAdded ? "calendar.badge.minus" : "calendar.badge.plus")
                        .contentTransition(.symbolEffect(.replace.upUp))
                        .frame(width: 20)
                }
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
                                kontest.selectedCalendarName = nil
                                kontest.selectedCalendarAccount = nil
                            } catch {
                                errorState.errorWrapper = ErrorWrapper(error: error, guidance: "Check that you have given Kontest the Calendar Permission (Full Access)")
                            }
                            
                            isCalendarPopoverVisible = false
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    },
                                        onPressSet: {
                        setDate,
                        selectedCalendar in
                        print("setDate: \(setDate.formatted())")
                        
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
                .help(kontest.isCalendarEventAdded ? "Remove from Calendar" : "Add to Calendar")
            }
            #endif

            #if os(macOS)
            if CalendarUtility.isKontestOfFuture(kontestStartDate: kontestStartDate ?? Date()), notificationsViewModel.getNumberOfNotificationsWhichCanBeSettedForAKontest(kontest: kontest) > 0 {
                SingleNotificationMenu(kontest: kontest)
                    .frame(width: 45)
            }
            #endif

            Spacer()

            VStack {
                if kontestStartDate != nil && kontestEndDate != nil {
                    Text("\(kontestStartDate!.formatted(date: .omitted, time: .shortened)) - \(kontestEndDate!.formatted(date: .omitted, time: .shortened))")
                        .foregroundStyle(KontestModel.getColorForIdentifier(siteAbbreviation: kontest.siteAbbreviation, colorScheme: colorScheme))
                        .font(FontUtility.getTimeFontSize())
                        .bold()

                    VStack {
                        if isKontestRunning {
                            let date = timelineViewDefaultContext.date
                            let seconds = (kontestEndDate ?? Date()).timeIntervalSince(date)

                            #if os(iOS)
                            let remainingTimeInEndingOfRunningKontest = CalendarUtility.shortenedFormattedTimeFrom(seconds: Int(seconds))
                            #else
                            let remainingTimeInEndingOfRunningKontest = CalendarUtility.formattedTimeFrom(seconds: Int(seconds))
                            #endif

                            Text("Ends in \(remainingTimeInEndingOfRunningKontest)")
                                .font(FontUtility.getRemainingTimeFontSize().monospacedDigit())
                                .contentTransition(.numericText(countsDown: true))
                                .animation(.easeInOut, value: remainingTimeInEndingOfRunningKontest)
                        }

                        if isKontestOfFutureAndStartingInLessThan24Hours {
                            let date = timelineViewDefaultContext.date
                            let seconds = (kontestStartDate ?? Date()).timeIntervalSince(date)

                            let remainingTimeInStartingOfFutureKontest = CalendarUtility.formattedTimeFrom(seconds: Int(seconds))

                            Text("Starting in \(remainingTimeInStartingOfFutureKontest)")
                                .font(FontUtility.getRemainingTimeFontSize().monospacedDigit())
                                .contentTransition(.numericText(countsDown: true))
                                .animation(.easeInOut, value: remainingTimeInStartingOfFutureKontest)
                        }

                        HStack {
                            Image(systemName: "clock")

                            Text(CalendarUtility.getFormattedDuration(fromSeconds: kontest.duration) ?? "")
                        }
                        .font(FontUtility.getDateFontSize())
                    }
                    .padding(.vertical, 5)

                    #if os(macOS)
                    Text("\(CalendarUtility.getNumericKontestDate(date: kontestStartDate ?? Date())) (\(CalendarUtility.getWeekdayNameFromDate(date: kontestStartDate ?? Date()))) - \(CalendarUtility.getNumericKontestDate(date: kontestEndDate ?? Date())) (\(CalendarUtility.getWeekdayNameFromDate(date: kontestEndDate ?? Date())))")
                        .font(FontUtility.getDateFontSize())
                    #else
                    Text("\(CalendarUtility.getNumericKontestDate(date: kontestStartDate ?? Date())) - \(CalendarUtility.getNumericKontestDate(date: kontestEndDate ?? Date()))")
                    #endif
                } else {
                    Text("No date provided")
                }
            }
            .foregroundStyle(colorScheme == .light ? .black : .white)
            .font(.footnote)
        }
        #if os(macOS)
        .padding()
        #endif
    }
}

#Preview("SingleKontentView") {
    let allKontestsViewModel = Dependencies.instance.allKontestsViewModel

    return List {
        TimelineView(.periodic(from: .now, by: 1)) { timelineViewDefaultContext in
            SingleKontestView(kontest: KontestModel.from(dto: KontestDTO(name: "ProjectEuler+", url: "https://hackerrank.com/contests/projecteuler", startTime: "2014-07-07T15:38:00.000Z", endTime: "2024-07-30T18:30:00.000Z", duration: "317616720.0", site: "HackerRank", in_24_hours: "No", status: "BEFORE")), timelineViewDefaultContext: timelineViewDefaultContext)
        }

        TimelineView(.periodic(from: .now, by: 1)) { timelineViewDefaultContext in
            SingleKontestView(kontest: KontestModel.from(dto: KontestDTO(name: "1v1 Games by CodeChef", url: "https://www.codechef.com/GAMES", startTime: "2023-8-27 12:30:00 UTC", endTime: "2032-11-10 06:30:00 UTC", duration: "315619200.0", site: "CodeChef", in_24_hours: "No", status: "CODING")), timelineViewDefaultContext: timelineViewDefaultContext)
        }

        TimelineView(.periodic(from: .now, by: 1)) { timelineViewDefaultContext in
            SingleKontestView(kontest: KontestModel.from(dto: KontestDTO(name: "Weekly Contest 358", url: "https://leetcode.com/contest/weekly-contest-358", startTime: "2023-09-03T02:30:00.000Z", endTime: "2023-10-25T04:00:00.000Z", duration: "5400", site: "LeetCode", in_24_hours: "Yes", status: "BEFORE")), timelineViewDefaultContext: timelineViewDefaultContext)
        }

        TimelineView(.periodic(from: .now, by: 1)) { timelineViewDefaultContext in
            SingleKontestView(kontest: KontestModel.from(dto: KontestDTO(name: "Test Contest", url: "https://leetcode.com/contest/weekly-contest-358", startTime: "2023-08-13T02:30:00.000Z", endTime: "2023-08-13T05:00:00.000Z", duration: "1800", site: "LeetCode", in_24_hours: "Yes", status: "BEFORE")), timelineViewDefaultContext: timelineViewDefaultContext)
        }

        TimelineView(.periodic(from: .now, by: 1)) { timelineViewDefaultContext in
            SingleKontestView(kontest: KontestModel.from(dto: KontestDTO(name: "Starters 100 (Date to be decided)", url: "https://www.codechef.com/START100", startTime: "2023-08-30 14:30:00 UTC", endTime: "2023-08-30 16:30:00 UTC", duration: "7200", site: "CodeChef", in_24_hours: "No", status: "BEFORE")), timelineViewDefaultContext: timelineViewDefaultContext)
        }
    }
    .environment(allKontestsViewModel)
    .environment(ErrorState())

//    return SingleKontestView(kontest: KontestModel.from(dto: KontestDTO(name: "1v1 Games by CodeChef", url: "https://www.codechef.com/GAMES", start_time: "2023-11-10 06:30:00 UTC", end_time: "2032-11-10 06:30:00 UTC", duration: "315619200.0", site: "CodeChef", in_24_hours: "No", status: "CODING")))
//        .environment(allKontestsViewModel)
}
