//
//  CalendarUtility.swift
//  Kontest
//
//  Created by Ayush Singhal on 13/08/23.
//

import Combine
@preconcurrency import EventKit
import Foundation
import OSLog

enum CalendarUtility {
    private static let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "CalendarUtility")

    private static let eventStore = EKEventStore()

    // DateFormatter for the third format: "December 07, 2023 18:30:00"
    static func getFormattedDate1(date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM dd, yyyy HH:mm:ss"
        formatter.timeZone = .gmt

        let currentDate = formatter.date(from: date)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"

        return currentDate
    }

    // DateFormatter for the second format: "2024-07-30T18:30:00.000Z"
    static func getFormattedDate2(date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let currentDate = formatter.date(from: date)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"

        return currentDate
    }

    // DateFormatter for the third format: "2022-10-10 06:30:00 UTC"
    static func getFormattedDate3(date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz" // 2023-08-30 14:30:00 UTC
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let currentDate = formatter.date(from: date)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"

        return currentDate
    }

    // DateFormatter for the fourth format: "2023-06-21 22:00:06"
    static func getFormattedDateForCodeChefKontestRatings(date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 2023-06-21 22:00:06
        formatter.locale = Locale(identifier: "en_US_POSIX")

        formatter.timeZone = .init(abbreviation: "IST")

        let currentDate = formatter.date(from: date)

        return currentDate
    }

    static func getDate(date: String) -> Date? {
        if let ansDate = getFormattedDate1(date: date) {
            return ansDate
        } else if let ansDate = getFormattedDate2(date: date) {
            return ansDate
        } else if let ansDate = getFormattedDate3(date: date) {
            return ansDate
        } else {
            return nil
        }
    }

    static func isKontestOfPast(kontestEndDate: Date) -> Bool {
        let currentDate = Date()
        let ans = kontestEndDate <= currentDate
        return ans
    }

    static func isKontestOfFuture(kontestStartDate: Date) -> Bool {
        return Date() <= kontestStartDate
    }

    static func isKontestRunning(kontestStartDate: Date, kontestEndDate: Date) -> Bool {
        let currentDate = Date()
        return currentDate >= kontestStartDate && currentDate <= kontestEndDate
    }

    static func isKontestLaterToday(kontestStartDate: Date) -> Bool {
        let currentDate = Date()
        let tomorrow = CalendarUtility.getTomorrow()
        return kontestStartDate > currentDate && kontestStartDate < tomorrow
    }

    static func isKontestTomorrow(kontestStartDate: Date) -> Bool {
        let tomorrow = CalendarUtility.getTomorrow()
        let dayAfterTomorrow = CalendarUtility.getDayAfterTomorrow()

        return kontestStartDate > tomorrow && kontestStartDate < dayAfterTomorrow
    }

    static func isKontestLater(kontestStartDate: Date) -> Bool {
        let dayAfterTomorrow = CalendarUtility.getDayAfterTomorrow()

        return kontestStartDate > dayAfterTomorrow
    }

    static func getFormattedDuration(fromSeconds seconds: String, minimumDuration: Float? = nil, maximumDuration: Float? = nil) -> String? {
        guard let totalSecondsInDouble = Double(seconds) else {
            return "Invalid Duration"
        }

        let totalSeconds = Int(totalSecondsInDouble)

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60

        let formatter = DateComponentsFormatter()
        #if os(iOS)
            formatter.unitsStyle = .abbreviated
        #else
            formatter.unitsStyle = .full
        #endif

        formatter.allowedUnits = [.day, .hour, .minute, .second]

        let dateComponents = DateComponents(hour: hours, minute: minutes)

        let totalMinutes = (dateComponents.hour ?? 0) * 60 + (dateComponents.minute ?? 0)

        let minimumDurationOfAKontestInMins = minimumDuration ?? UserDefaults(suiteName: Constants.userDefaultsGroupID)!.float(forKey: Constants.minimumDurationOfAKontestInMinutesKey)

        let maximumDurationOfAKontestInMins = maximumDuration ?? UserDefaults(suiteName: Constants.userDefaultsGroupID)!.float(forKey: Constants.maximumDurationOfAKontestInMinutesKey)

        let ans = ((totalMinutes <= Int(maximumDurationOfAKontestInMins)) && (totalMinutes >= Int(minimumDurationOfAKontestInMins))) ? formatter.string(from: dateComponents) : nil // It verifies that kontest duration is in between minimum and maximum range, and if it is not in range then returns nil. If it is nil then in "AllKontestsViewModel", during filtering it removes that kontest entry.

        return ans
    }

    static func getTimeBefore(originalDate: Date, minutes: Int, hours: Int, days: Int) -> Date {
        var components = DateComponents()
        components.minute = -minutes
        components.hour = -hours
        components.day = -days

        if let newDate = Calendar.current.date(byAdding: components, to: originalDate) {
            return newDate
        }

        return originalDate
    }

    static func getNumericKontestDate(date: Date) -> String {
        #if os(iOS)
            "\(date.formatted(date: .numeric, time: .omitted))"
        #else
            "\(date.formatted(date: .abbreviated, time: .omitted))"
        #endif
    }

    static func getKontestDate(date: Date) -> String {
        #if os(iOS)
            "\(date.formatted(date: .abbreviated, time: .omitted))"
        #else
            "\(date.formatted(date: .abbreviated, time: .omitted))"
        #endif
    }

    static func convertUTCToLocal(utcDate: Date) -> Date? {
        let localTimeZone = TimeZone.current
        let secondsFromGMT = localTimeZone.secondsFromGMT(for: utcDate)
        return Date(timeInterval: TimeInterval(secondsFromGMT), since: utcDate)
    }

    static func getTomorrow() -> Date {
        let today = Date()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: today))!
        return tomorrow
    }

    static func getDayAfterTomorrow() -> Date {
        let today = Date()
        let calendar = Calendar.current
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: calendar.startOfDay(for: today))!
        return dayAfterTomorrow
    }

    static func getTimeDifferenceString(startDate: Date, endDate: Date) -> String {
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: startDate, to: endDate)

        var formattedTime = ""

        if let days = components.day, days > 0 {
            formattedTime.append("\(days)D")
        } else {
            if let minutes = components.minute, minutes > 0 {
                if let hours = components.hour, hours > 0 {
                    formattedTime.append("\(hours)H \(minutes)M")
                } else {
                    formattedTime.append("\(minutes)M")
                }
            } else {
                if let hours = components.hour, hours > 0 {
                    formattedTime.append("\(hours)H")
                }
            }
        }

        return formattedTime.isEmpty ? "0H" : formattedTime
    }

    static func getWeekdayNameFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: date).uppercased()
    }

    static func getTimeFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }

    static func isRemainingTimeGreaterThanGivenTime(date: Date?, minutes: Int = 0, hours: Int = 0, days: Int = 0) -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()

        guard let date, let targetDate = calendar.date(byAdding: .minute, value: minutes, to: currentDate),
              let targetDateWithHours = calendar.date(byAdding: .hour, value: hours, to: targetDate),
              let targetDateWithDays = calendar.date(byAdding: .day, value: days, to: targetDateWithHours)
        else {
            return false
        }

        return targetDateWithDays < date
    }

    static func formattedTimeFrom(seconds: Int) -> String {
        let days = seconds / 86400 // 86400 seconds in a day
        let hours = (seconds % 86400) / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60

        return if days > 0 {
            if days == 1 {
                String(format: "%d day and %02d:%02d:%02d", days, hours, minutes, remainingSeconds)
            } else {
                String(format: "%d days and %02d:%02d:%02d", days, hours, minutes, remainingSeconds)
            }
        } else if hours > 0 {
            String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
        } else {
            String(format: "%02d:%02d", minutes, remainingSeconds)
        }
    }

    static func shortenedFormattedTimeFrom(seconds: Int) -> String {
        let days = seconds / 86400 // 86400 seconds in a day
        let hours = (seconds % 86400) / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60

        return if days > 0 {
            String(format: "%dd, %02d:%02d:%02d", days, hours, minutes, remainingSeconds)
        } else if hours > 0 {
            String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
        } else {
            String(format: "%02d:%02d", minutes, remainingSeconds)
        }
    }

    static func getNextDateToRefresh(ongoingKontests: [KontestModel], laterTodayKontests: [KontestModel], tomorrowKontests: [KontestModel], laterKontests: [KontestModel]) -> Date {
        let maxNextDateToRefresh = Date.now.advanced(by: 0.5 * 60 * 60)
        var nextDateToRefresh = maxNextDateToRefresh

        if !ongoingKontests.isEmpty {
            let endTime = CalendarUtility.getDate(date: ongoingKontests.first!.end_time) ?? maxNextDateToRefresh

            if endTime > .now {
                nextDateToRefresh = min(nextDateToRefresh, endTime)
            }
        }

        if !laterTodayKontests.isEmpty {
            let startTime = CalendarUtility.getDate(date: laterTodayKontests.first!.start_time) ?? maxNextDateToRefresh

            if startTime > .now {
                nextDateToRefresh = min(nextDateToRefresh, startTime)
            }
        }

        if !tomorrowKontests.isEmpty {
            let startTime = CalendarUtility.getDate(date: tomorrowKontests.first!.start_time) ?? maxNextDateToRefresh

            if startTime > .now {
                nextDateToRefresh = min(nextDateToRefresh, startTime)
            }
        }

        if !laterKontests.isEmpty {
            let startTime = CalendarUtility.getDate(date: laterKontests.first!.start_time) ?? maxNextDateToRefresh

            if startTime > .now {
                nextDateToRefresh = min(nextDateToRefresh, startTime)
            }
        }

        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
            if let tomorrowAtMidnight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) {
                nextDateToRefresh = min(nextDateToRefresh, tomorrowAtMidnight)
            }
        }

        return nextDateToRefresh
    }

    static func requestFullAccessToReminders() async throws -> Bool {
        do {
            try await eventStore.requestFullAccessToEvents()
        } catch {
            throw error
        }

        let isGranted = EKEventStore.authorizationStatus(for: EKEntityType.event) == .fullAccess
        return isGranted
    }

    static func addEvent(startDate: Date, endDate: Date, title: String, notes: String, url: URL?, alarmAbsoluteDate: Date, calendar: EKCalendar = getSelectedCalendar()) async throws -> Bool {
        // Check the authorization status for calendar events
        let authorizationStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)

        if authorizationStatus != .fullAccess {
            // If not authorized, request permission asynchronously
            do {
                let isGranted = try await requestFullAccessToReminders()

                if isGranted {
                    // Permission granted, continue to create and save the event
                    do {
                        return try createAndSaveEvent(startDate: startDate, endDate: endDate, title: title, notes: notes, url: url, alarmAbsoluteDate: alarmAbsoluteDate, calendar: calendar)
                    } catch {
                        throw error
                    }
                }

                throw AppError(title: "Permission not Granted", description: "Calendar Permission is not granted.")
            } catch {
                logger.error("Error in addEvent: \(error)")
                throw error
            }

        } else {
            // If already authorized, create and save the event
            do {
                return try createAndSaveEvent(startDate: startDate, endDate: endDate, title: title, notes: notes, url: url, alarmAbsoluteDate: alarmAbsoluteDate, calendar: calendar)
            } catch {
                throw error
            }
        }
    }

    // Function to create and save the event
    private static func createAndSaveEvent(startDate: Date, endDate: Date, title: String, notes: String, url: URL?, alarmAbsoluteDate: Date, calendar: EKCalendar?) throws -> Bool {
        UserDefaults(suiteName: Constants.userDefaultsGroupID)!.set(true, forKey: "shouldFetchAllEventsFromCalendar")
        let event = EKEvent(eventStore: eventStore)
//        event.calendar = eventStore.defaultCalendarForNewEvents
        event.calendar = calendar
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        event.url = url

        let alarm = EKAlarm(absoluteDate: alarmAbsoluteDate)
        event.alarms = [alarm]

        do {
            try eventStore.save(event, span: .thisEvent)
            logger.info("Event saved: \(event)")
            return true
        } catch {
            logger.error("Error in saving event: \(error)")
            throw error
        }
    }

    static func getAllEvents() async throws -> [EKEvent]? {
        logger.info("FullAccessYes")

        if EKEventStore.authorizationStatus(for: EKEntityType.event) != .fullAccess {
            do {
                let isGranted = try await requestFullAccessToReminders()

                if !isGranted {
                    logger.info("Full Access To Reminders not Granted")
                    return nil
                }
            } catch {
                logger.info("Error in requesting Full Access To Reminders")
                throw error
            }
        }

        let interval = DateInterval(start: Date(), end: Calendar.current.date(byAdding: .year, value: 1, to: Date())!)

        let predicate = eventStore.predicateForEvents(withStart: interval.start, end: interval.end, calendars: nil)

        let events = eventStore.events(matching: predicate)

//        logger.info("FullAccessinterval: \(interval)")
//        logger.info("FullAccess Events: \(events)")

        return events
    }

    static func removeEvent(startDate: Date, endDate: Date, title: String, notes: String, url: URL?) async throws {
        do {
            let allEvents = try await getAllEvents()

            let events = allEvents?.filter { event in
                event.startDate == startDate && event.endDate == endDate && event.title == title && event.url == url
            }

            if let events, !events.isEmpty {
                do {
                    try eventStore.remove(events[0], span: .thisEvent)
                } catch {
                    logger.error("Error in removing event: \(error)")
                }
            }
        } catch {
            throw error
        }
    }

    static func isEventPresentInCalendar(allEventsOfCalendar: [EKEvent], startDate: Date, endDate: Date, title: String, url: URL?) -> Bool {
        return allEventsOfCalendar.contains { event in
            event.startDate == startDate && event.endDate == endDate && event.title == title && event.url == url
        }
    }

    static func formatDateToString(_ date: Date) -> String { // yyyy-MM-dd HH:mm:ss zzz
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        // Remove AM/PM by setting the locale to "en_US_POSIX" and using 24-hour format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        return dateFormatter.string(from: date)
    }

    static func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }

    static func getCalendarDateOfEvent(allEventsOfCalendar: [EKEvent], startDate: Date, endDate: Date, title: String, url: URL?) -> Date? {
        let event = allEventsOfCalendar.first { event in
            event.startDate == startDate && event.endDate == endDate && event.title == title && event.url == url
        }

        if let event {
            if let absoluteDate = event.alarms?.first?.absoluteDate {
                return absoluteDate
            } else if let relativeOffset = event.alarms?.first?.relativeOffset {
                return event.startDate.addingTimeInterval(relativeOffset)
            } else {
                return event.alarms?.first?.absoluteDate ?? event.startDate.addingTimeInterval(-15 * 60)
            }
        } else {
            return nil
        }
    }

    static func addCalendarObserver(onChange: @escaping @Sendable (Notification) -> Void) {
        logger.info("Observation of calendar started")

        NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: nil, queue: nil) { notification in
            onChange(notification)
        }

        //        var cancellables: [AnyCancellable] = []
        //
        //        NotificationCenter.default.publisher(for: .EKEventStoreChanged, object: eventStore).sink { notification in
        //            print("Observation Changed")
        //        }
        //        .store(in: &cancellables)
    }

    static func getAllCalendars() throws -> [EKCalendar] {
        let authorizationStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)

        if authorizationStatus != .fullAccess {
            throw AppError(title: "Permission not Granted", description: "Calendar Permission is not granted.")
        }

        let allCalendars = eventStore.calendars(for: .event)

        for calendar in allCalendars {
            if calendar.type != .subscription {
                logger.log("\(calendar) , source - \(calendar.source.title) \n\n")
            }
        }

        return allCalendars
    }

    static func getCalendarsByTheirSources() throws -> [String: [EKCalendar]] {
        let authorizationStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)

        if authorizationStatus != .fullAccess {
            throw AppError(title: "Permission not Granted", description: "Calendar Permission is not granted.")
        }

        let allCalendars = eventStore.calendars(for: .event)

        var ans: [String: [EKCalendar]] = [:]

        for calendar in allCalendars {
            if ans[calendar.source.title] == nil {
                ans[calendar.source.title] = []
            }

            ans[calendar.source.title]?.append(calendar)
        }

        return ans
    }

    static func getChangableCalendarsByTheirSources() throws -> [(String, [EKCalendar])] {
        let authorizationStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)

        if authorizationStatus != .fullAccess {
            throw AppError(title: "Permission not Granted", description: "Calendar Permission is not granted.")
        }

        let allCalendars = eventStore.calendars(for: .event)

        var ans: [(String, [EKCalendar])] = []

        for calendar in allCalendars {
            // Check if the calendar allows content modifications
            if calendar.allowsContentModifications {
                // Try to find an existing entry for the calendar source in the result array
                if let index = ans.firstIndex(where: { $0.0 == calendar.source.title }) {
                    // If the entry exists, append the calendar to the existing array
                    ans[index].1.append(calendar)
                } else {
                    // If the entry doesn't exist, create a new entry with the source title and the calendar
                    ans.append((calendar.source.title, [calendar]))
                }
            }
        }

        return ans
    }

    static func getCalendarAccountNameOfAnEvent(allEventsOfCalendar: [EKEvent], startDate: Date, endDate: Date, title: String, url: URL?) -> String? {
        let event = allEventsOfCalendar.first { event in
            event.startDate == startDate && event.endDate == endDate && event.title == title && event.url == url
        }

        if let event {
            let calendarAccountName = event.calendar.source.title

            return calendarAccountName
        } else {
            return nil
        }
    }

    static func getCalendarNameOfAnEvent(allEventsOfCalendar: [EKEvent], startDate: Date, endDate: Date, title: String, url: URL?) -> String? {
        let event = allEventsOfCalendar.first { event in
            event.startDate == startDate && event.endDate == endDate && event.title == title && event.url == url
        }

        if let event {
            let calendarName = event.calendar.title

            return calendarName
        } else {
            return nil
        }
    }

    static func getDefaultCalendarOfDevice() -> EKCalendar {
        if let defaultCalendar = eventStore.defaultCalendarForNewEvents {
            return defaultCalendar
        } else {
            return eventStore.calendars(for: .event).first!
        }
    }

    static func setSelectedCalendar(calendar: EKCalendar) {
        print("Changing selected calendar to: \(calendar)")
        UserDefaults(suiteName: Constants.userDefaultsGroupID)!.set(calendar.calendarIdentifier, forKey: Constants.defaultCalendarKey)
    }

    static func getSelectedCalendar() -> EKCalendar {
        let setCalendarIdentifier = UserDefaults(suiteName: Constants.userDefaultsGroupID)!.string(forKey: Constants.defaultCalendarKey)

        if let setCalendarIdentifier {
            if let calendar = eventStore.calendar(withIdentifier: setCalendarIdentifier) {
                return calendar
            } else {
                return getDefaultCalendarOfDevice()
            }
        } else {
            return getDefaultCalendarOfDevice()
        }
    }
    
    static func getAllCalendarsWithSelectedCalendarIndices() -> ([(String, [EKCalendar])], Int, Int) {
        let allCalendars = try! getChangableCalendarsByTheirSources()
        
        let selectedCalendar = getSelectedCalendar()
        
        var selectedAccountIndex = 0
        var selectedCalendarIndex = 0;
        
        for (accountIndex, account) in allCalendars.enumerated() {
            for (calendarIndex, calendar) in account.1.enumerated() {
                if calendar.calendarIdentifier == selectedCalendar.calendarIdentifier {
                    selectedAccountIndex = accountIndex
                    selectedCalendarIndex = calendarIndex
                    break
                }
            }
        }
        
        return (allCalendars, selectedAccountIndex, selectedCalendarIndex)
    }
}
