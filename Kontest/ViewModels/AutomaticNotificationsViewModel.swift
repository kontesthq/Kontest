//
//  AutomaticNotificationsViewModel.swift
//  Kontest
//
//  Created by Ayush Singhal on 2/20/24.
//

import Foundation
import OSLog

@Observable
final class AutomaticNotificationsViewModel: Sendable {
    static let instance = AutomaticNotificationsViewModel()

    private init() {}

    private let notificationViewModel = Dependencies.instance.notificationsViewModel

    func addAutomaticNotificationToEligibleSites(kontests: [KontestModel]) async {
        let userDefaults = UserDefaults(suiteName: Constants.userDefaultsGroupID)!

        for siteAbbreviation in getAllSiteAbbreviations() {
            let notificationKey10MinutesBefore = siteAbbreviation + Constants.automaticNotification10MinutesSuffix
            let notificationKey30MinutesBefore = siteAbbreviation + Constants.automaticNotification30MinutesSuffix
            let notificationKey1HourBefore = siteAbbreviation + Constants.automaticNotification1HourSuffix
            let notificationKey6HoursBefore = siteAbbreviation + Constants.automaticNotification6HoursSuffix

            if userDefaults.bool(forKey: notificationKey10MinutesBefore) == true {
                await addAutomaticNotifications(kontests: kontests, siteAbbreviation: siteAbbreviation, minutesBefore: 10, hoursBefore: 0, daysBefore: 0)
            }

            if userDefaults.bool(forKey: notificationKey30MinutesBefore) == true {
                await addAutomaticNotifications(kontests: kontests, siteAbbreviation: siteAbbreviation, minutesBefore: 30, hoursBefore: 0, daysBefore: 0)
            }

            if userDefaults.bool(forKey: notificationKey1HourBefore) == true {
                await addAutomaticNotifications(kontests: kontests, siteAbbreviation: siteAbbreviation, minutesBefore: 0, hoursBefore: 1, daysBefore: 0)
            }

            if userDefaults.bool(forKey: notificationKey6HoursBefore) == true {
                await addAutomaticNotifications(kontests: kontests, siteAbbreviation: siteAbbreviation, minutesBefore: 0, hoursBefore: 6, daysBefore: 0)
            }
        }
    }

    func addAutomaticCalendarEventToEligibleSites(kontests: [KontestModel]) async {
        if CalendarUtility.getAuthorizationStatus() == .fullAccess {
            let userDefaults = UserDefaults(suiteName: Constants.userDefaultsGroupID)!

            for siteAbbreviation in getAllSiteAbbreviations() {
                let newKey = siteAbbreviation + Constants.automaticCalendarEventSuffix

                if userDefaults.bool(forKey: newKey) == true {
                    await addAutomaticCalendarEvent(kontests: kontests, siteAbbreviation: siteAbbreviation)
                }
            }
        }
    }

    private func addAutomaticNotifications(kontests: [KontestModel], siteAbbreviation: String, minutesBefore: Int, hoursBefore: Int, daysBefore: Int) async {
        let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "addAutomaticNotifications")

        for kontestModel in kontests {
            if kontestModel.siteAbbreviation == siteAbbreviation {
                if minutesBefore == 10 {
                    if !kontestModel.isSetForReminder10MiutesBefore {
                        do {
                            try await notificationViewModel.setNotificationForKontest(kontest: kontestModel, minutesBefore: minutesBefore, hoursBefore: hoursBefore, daysBefore: daysBefore)
                        } catch {
                            logger.error("Error in adding automatic notification to kontest: \("\(kontestModel)") with error: \(error)")
                        }
                    }
                } else if minutesBefore == 30 {
                    if !kontestModel.isSetForReminder30MiutesBefore {
                        do {
                            try await notificationViewModel.setNotificationForKontest(kontest: kontestModel, minutesBefore: minutesBefore, hoursBefore: hoursBefore, daysBefore: daysBefore)
                        } catch {
                            logger.error("Error in adding automatic notification to kontest: \("\(kontestModel)") with error: \(error)")
                        }
                    }
                } else if hoursBefore == 1 {
                    if !kontestModel.isSetForReminder1HourBefore {
                        do {
                            try await notificationViewModel.setNotificationForKontest(kontest: kontestModel, minutesBefore: minutesBefore, hoursBefore: hoursBefore, daysBefore: daysBefore)
                        } catch {
                            logger.error("Error in adding automatic notification to kontest: \("\(kontestModel)") with error: \(error)")
                        }
                    }
                } else if hoursBefore == 6 {
                    if !kontestModel.isSetForReminder6HoursBefore {
                        do {
                            try await notificationViewModel.setNotificationForKontest(kontest: kontestModel, minutesBefore: minutesBefore, hoursBefore: hoursBefore, daysBefore: daysBefore)
                        } catch {
                            logger.error("Error in adding automatic notification to kontest: \("\(kontestModel)") with error: \(error)")
                        }
                    }
                }
            }
        }
    }

    private func addAutomaticCalendarEvent(kontests: [KontestModel], siteAbbreviation: String) async {
        let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "addAutomaticCalendarEvent")

        for kontestModel in kontests {
            if kontestModel.siteAbbreviation == siteAbbreviation {
                if !kontestModel.isCalendarEventAdded {
                    let kontestStartDate = CalendarUtility.getDate(date: kontestModel.start_time)
                    let kontestEndDate = CalendarUtility.getDate(date: kontestModel.end_time)

                    if let kontestStartDate, let kontestEndDate {
                        do {
                            if try await CalendarUtility.addEvent(
                                startDate: kontestStartDate,
                                endDate: kontestEndDate,
                                title: kontestModel.name,
                                notes: "",
                                url: URL(string: kontestModel.url),
                                alarmAbsoluteDate: kontestStartDate.addingTimeInterval(-15 * 60)
                            ) {
                                kontestModel.isCalendarEventAdded = true
                                kontestModel.calendarEventDate = kontestStartDate.addingTimeInterval(-15 * 60)
                            }
                        } catch {
                            logger.error("Error in adding automatic calendar event to kontest: \("\(kontestModel)") with error: \(error)")
                        }
                    }
                }
            }
        }
    }
}
