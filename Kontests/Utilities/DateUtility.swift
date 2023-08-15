//
//  DateUtility.swift
//  Kontests
//
//  Created by Ayush Singhal on 13/08/23.
//

import Foundation

class DateUtility {
    // DateFormatter for the first format: "2024-07-30T18:30:00.000Z"
    static func getFormattedDate1(date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let currentDate = formatter.date(from: date)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"

        return currentDate
    }

    // DateFormatter for the second format: "2022-10-10 06:30:00 UTC"
    static func getFormattedDate2(date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz" // 2023-08-30 14:30:00 UTC
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let currentDate = formatter.date(from: date)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"

        return currentDate
    }

    static func getDate(date: String) -> Date? {
        if let ansDate = getFormattedDate1(date: date) {
            return ansDate
        }
        else if let ansDate = getFormattedDate2(date: date) {
            return ansDate
        }
        else {
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

    static func getFormattedDuration(fromSeconds seconds: String) -> String? {
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

        let ans = dateComponents.hour ?? 1 <= 360 ? formatter.string(from: dateComponents) : nil
        return ans
    }

    static func getTimeBefore(originalDate: Date, minutes: Int, hours: Int) -> Date {
        var components = DateComponents()
        components.minute = -minutes
        components.hour = -hours

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
}
