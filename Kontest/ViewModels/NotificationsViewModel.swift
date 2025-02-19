//
//  NotificationsViewModel.swift
//  Kontest
//
//  Created by Ayush Singhal on 17/08/23.
//

import Foundation
import OSLog
import UserNotifications

@Observable
final class NotificationsViewModel: NotificationsViewModelProtocol {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "NotificationsViewModel")

    var pendingNotifications: [UNNotificationRequest] = []

    init() {
        getAllPendingNotifications()
    }

    func getAllPendingNotifications() {
        LocalNotificationManager.instance.getAllPendingNotifications(completion: { notifications in
            self.pendingNotifications = notifications.sorted(by: { firstNotificationRequest, secondNotificationRequest in
                let firstTrigger = firstNotificationRequest.trigger as? UNCalendarNotificationTrigger
                let firstTriggerTime = firstTrigger?.nextTriggerDate()

                let secondTrigger = secondNotificationRequest.trigger as? UNCalendarNotificationTrigger
                let secondTriggerTime = secondTrigger?.nextTriggerDate()

                return firstTriggerTime ?? Date() < secondTriggerTime ?? Date()
            })
        })
    }

    func getNumberOfNotificationsWhichCanBeSettedForAKontest(kontest: KontestModel) -> Int {
        var ans = 0
        let kontestStartDate = CalendarUtility.getDate(date: kontest.start_time)
        if kontestStartDate == nil {
            return 4
        }

        if CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, minutes: 10, hours: 0, days: 0) {
            ans += 1
        }

        if CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, minutes: 30, hours: 0, days: 0) {
            ans += 1
        }

        if CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, minutes: 0, hours: 1, days: 0) {
            ans += 1
        }

        if CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, minutes: 0, hours: 6, days: 0) {
            ans += 1
        }

        return ans
    }

    func getNumberOfSettedNotificationForAKontest(kontest: KontestModel) -> Int {
        var ans = 0
        let kontestStartDate = CalendarUtility.getDate(date: kontest.start_time)

        if !(CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, minutes: 10) && !kontest.isSetForReminder10MiutesBefore) {
            ans += 1
        }

        if !(CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, minutes: 30) && !kontest.isSetForReminder30MiutesBefore) {
            ans += 1
        }

        if !(CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, hours: 1) && !kontest.isSetForReminder1HourBefore) {
            ans += 1
        }

        if !(CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, hours: 6) && !kontest.isSetForReminder6HoursBefore) {
            ans += 1
        }

        return ans
    }

    internal func setNotification(kontest: KontestModel, minutesBefore: Int, hoursBefore: Int, daysBefore: Int, kontestTitle: String, kontestSubTitle: String, kontestBody: String) async throws {
        let notificationsAuthorizationLevel = await LocalNotificationManager.instance.getNotificationsAuthorizationLevel()

        if notificationsAuthorizationLevel.authorizationStatus == .denied {
            throw AppError(title: "Permission not Granted", description: "Notification permission is not granted")
        }

        let kontestStartDate = CalendarUtility.getDate(date: kontest.start_time)
        let notificationDate = CalendarUtility.getTimeBefore(originalDate: kontestStartDate ?? Date(), minutes: minutesBefore, hours: hoursBefore, days: daysBefore)
        let notificationID = LocalNotificationManager.instance.getNotificationID(kontestID: kontest.id, minutesBefore: minutesBefore, hoursBefore: hoursBefore, daysBefore: daysBefore)
        
        let kontestLink = createKontestLink(kontestModel: kontest)
        let userInfo: [String: String] = kontestLink != nil ? ["id": kontestLink!] : [:]

        LocalNotificationManager.instance.scheduleCalendarNotification(notificationContent: LocalNotificationManager.NotificationContent(title: kontestTitle, subtitle: kontestSubTitle, body: kontestBody, date: notificationDate, userInfo: userInfo), id: notificationID)

        updateIsSetForNotification(kontest: kontest, to: true, minutesBefore: minutesBefore, hoursBefore: hoursBefore, daysBefore: daysBefore)
    }

    func setNotificationForKontest(kontest: KontestModel, minutesBefore: Int, hoursBefore: Int, daysBefore: Int, kontestTitle: String = "", kontestSubTitle: String = "", kontestBody: String = "") async throws {
        let kontestStartDate = CalendarUtility.getDate(date: kontest.start_time)

        // Checking if we actually have given time in starting of kontest; like if given 6 hours, then checking if we actually have 6 hours or not in starting of kontest.
        if CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, minutes: minutesBefore, hours: hoursBefore, days: daysBefore) {
            let title = kontestTitle == "" ? kontest.name : kontestTitle
            let subTitle = kontestSubTitle == "" ? kontest.siteAbbreviation : kontestSubTitle
            let body = if hoursBefore > 0 {
                if hoursBefore == 1 {
                    kontestBody == "" ? "\(kontest.name) is starting in \(hoursBefore) hour." : kontestBody
                } else {
                    kontestBody == "" ? "\(kontest.name) is starting in \(hoursBefore) hours." : kontestBody
                }
            } else {
                kontestBody == "" ? "\(kontest.name) is starting in \(minutesBefore) minutes." : kontestBody
            }
            try await setNotification(kontest: kontest, minutesBefore: minutesBefore, hoursBefore: hoursBefore, daysBefore: daysBefore, kontestTitle: title, kontestSubTitle: subTitle, kontestBody: body)
        }
    }

    func setNotificationForAllKontests(minutesBefore: Int, hoursBefore: Int, daysBefore: Int, kontestTitle: String = "", kontestSubTitle: String = "", kontestBody: String = "") async throws {
        logger.info("count: \("\(Dependencies.instance.allKontestsViewModel.toShowKontests.count)")")
        for i in 0 ..< Dependencies.instance.allKontestsViewModel.toShowKontests.count {
            let kontest = Dependencies.instance.allKontestsViewModel.toShowKontests[i]
            let kontestStartDate = CalendarUtility.getDate(date: kontest.start_time)

            if CalendarUtility.isKontestOfFuture(kontestStartDate: kontestStartDate ?? Date()) {
                try await setNotificationForKontest(kontest: kontest, minutesBefore: minutesBefore, hoursBefore: hoursBefore, daysBefore: daysBefore, kontestTitle: kontestTitle, kontestSubTitle: kontestSubTitle, kontestBody: kontestBody)
            }
        }
    }

    func removeAllPendingNotifications() {
        LocalNotificationManager.instance.removeAllPendingNotifications()
        for i in 0 ..< Dependencies.instance.allKontestsViewModel.allKontests.count {
            updateIsSetForNotification(kontest: Dependencies.instance.allKontestsViewModel.allKontests[i], to: false, minutesBefore: -1, hoursBefore: -1, daysBefore: -1, removeAll: true)
        }
    }

    func removePendingNotification(kontest: KontestModel, minutesBefore: Int, hoursBefore: Int, daysBefore: Int) {
        let notificationID = LocalNotificationManager.instance.getNotificationID(kontestID: kontest.id, minutesBefore: minutesBefore, hoursBefore: hoursBefore, daysBefore: daysBefore)
        LocalNotificationManager.instance.removePendingNotifications(identifiers: [notificationID])
        updateIsSetForNotification(kontest: kontest, to: false, minutesBefore: minutesBefore, hoursBefore: hoursBefore, daysBefore: daysBefore)
    }

    func printAllPendingNotifications() {
        LocalNotificationManager.instance.printAllPendingNotifications()
    }

    func updateIsSetForNotification(kontest: KontestModel, to: Bool, minutesBefore: Int, hoursBefore: Int, daysBefore: Int, removeAll: Bool = false) {
        if to == false {
            if removeAll == true {
                if let index = Dependencies.instance.allKontestsViewModel.allKontests.firstIndex(where: { $0 == kontest }) {
                    Dependencies.instance.allKontestsViewModel.allKontests[index].isSetForReminder10MiutesBefore = false
                    Dependencies.instance.allKontestsViewModel.allKontests[index].isSetForReminder30MiutesBefore = false
                    Dependencies.instance.allKontestsViewModel.allKontests[index].isSetForReminder1HourBefore = false
                    Dependencies.instance.allKontestsViewModel.allKontests[index].isSetForReminder6HoursBefore = false

                    Dependencies.instance.allKontestsViewModel.allKontests[index].saveReminderStatus(minutesBefore: 10, hoursBefore: 0, daysBefore: 0)
                    Dependencies.instance.allKontestsViewModel.allKontests[index].saveReminderStatus(minutesBefore: 30, hoursBefore: 0, daysBefore: 0)
                    Dependencies.instance.allKontestsViewModel.allKontests[index].saveReminderStatus(minutesBefore: 0, hoursBefore: 1, daysBefore: 0)
                    Dependencies.instance.allKontestsViewModel.allKontests[index].saveReminderStatus(minutesBefore: 0, hoursBefore: 6, daysBefore: 0)
                }
            } else {
                if let index = Dependencies.instance.allKontestsViewModel.allKontests.firstIndex(where: { $0 == kontest }) {
                    if minutesBefore == 10 {
                        Dependencies.instance.allKontestsViewModel.allKontests[index].isSetForReminder10MiutesBefore = to
                    } else if minutesBefore == 30 {
                        Dependencies.instance.allKontestsViewModel.allKontests[index].isSetForReminder30MiutesBefore = to
                    } else if hoursBefore == 1 {
                        Dependencies.instance.allKontestsViewModel.allKontests[index].isSetForReminder1HourBefore = to
                    } else {
                        Dependencies.instance.allKontestsViewModel.allKontests[index].isSetForReminder6HoursBefore = to
                    }

                    Dependencies.instance.allKontestsViewModel.allKontests[index].saveReminderStatus(minutesBefore: minutesBefore, hoursBefore: hoursBefore, daysBefore: daysBefore)
                }
            }
        } else {
            if let index = Dependencies.instance.allKontestsViewModel.allKontests.firstIndex(where: { $0 == kontest }) {
                if minutesBefore == 10 {
                    Dependencies.instance.allKontestsViewModel.allKontests[index].isSetForReminder10MiutesBefore = to
                } else if minutesBefore == 30 {
                    Dependencies.instance.allKontestsViewModel.allKontests[index].isSetForReminder30MiutesBefore = to
                } else if hoursBefore == 1 {
                    Dependencies.instance.allKontestsViewModel.allKontests[index].isSetForReminder1HourBefore = to
                } else {
                    Dependencies.instance.allKontestsViewModel.allKontests[index].isSetForReminder6HoursBefore = to
                }

                Dependencies.instance.allKontestsViewModel.allKontests[index].saveReminderStatus(minutesBefore: minutesBefore, hoursBefore: hoursBefore, daysBefore: daysBefore)
            }
        }
    }

    func isSetForAllNotifications(kontest: KontestModel) -> Bool {
        var ans = true
        let kontestStartDate = CalendarUtility.getDate(date: kontest.start_time)

        if (CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, minutes: 10) && !kontest.isSetForReminder10MiutesBefore) || (CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, minutes: 30) && !kontest.isSetForReminder30MiutesBefore) || (CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, hours: 1) && !kontest.isSetForReminder1HourBefore) || (CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, hours: 6) && !kontest.isSetForReminder6HoursBefore) {
            ans = false
        }

        return ans
    }

    func removeAllNotificationForAKontest(kontest: KontestModel) {
        removePendingNotification(kontest: kontest, minutesBefore: 10, hoursBefore: 0, daysBefore: 0)
        removePendingNotification(kontest: kontest, minutesBefore: 30, hoursBefore: 0, daysBefore: 0)
        removePendingNotification(kontest: kontest, minutesBefore: 0, hoursBefore: 1, daysBefore: 0)
        removePendingNotification(kontest: kontest, minutesBefore: 0, hoursBefore: 6, daysBefore: 0)
    }
}
