//
//  NotificationManager.swift
//  Kontest
//
//  Created by Ayush Singhal on 13/08/23.
//

import OSLog
@preconcurrency import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, Sendable {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "NotificationDelegate")

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        logger.info("\(userInfo)")

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

final class LocalNotificationManager: Sendable {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "LocalNotificationManager")

    static let instance = LocalNotificationManager() // singleton
    let center = UNUserNotificationCenter.current()
    private let delegate: NotificationDelegate = .init()

    private init() {
        center.delegate = delegate
    }

    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        center.requestAuthorization(options: options) { [weak self] _, error in
            if let error {
                self?.logger.error("ERROR: \(error)")
            } else {
                self?.logger.info("Success")
            }
        }
    }

    func scheduleIntervalNotification(id: String = UUID().uuidString, timeIntervalInSeconds: Int = 10) {
        let timedNotificationContent = UNMutableNotificationContent()
        timedNotificationContent.title = "This is my Timed notification"
        timedNotificationContent.subtitle = "This was sooo easy!"
        timedNotificationContent.body = "This is notification body"
        timedNotificationContent.sound = .default
        timedNotificationContent.badge = 1
        timedNotificationContent.userInfo = ["nextViewInterval": "loadingViewInterval"]

//        let userInfo: [AnyHashable: Any] = ["nextViewInterval": "loadingViewInterval"]

        // time
        let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeIntervalInSeconds), repeats: false)

        let timeNotificationRequest = UNNotificationRequest(identifier: id, content: timedNotificationContent, trigger: timeTrigger)
        logger.info("Scheduled Timed notification of after \(timeIntervalInSeconds) seconds")

        center.add(timeNotificationRequest)
    }

    func scheduleCalendarNotification(notificationContent: NotificationContent, id: String = UUID().uuidString) {
        checkNotificationPermissionGranted()

        let calendarNotificationContent = UNMutableNotificationContent()
        calendarNotificationContent.title = notificationContent.title
        calendarNotificationContent.subtitle = notificationContent.subtitle
        calendarNotificationContent.body = notificationContent.body
        calendarNotificationContent.userInfo = notificationContent.userInfo
        calendarNotificationContent.sound = .default
        calendarNotificationContent.badge = 1

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .timeZone, .hour, .minute], from: notificationContent.date)

        let userInfo: [AnyHashable: Any] = ["nextView": "loadingView"]
        calendarNotificationContent.userInfo = userInfo

        let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let calendarNotificationRequest = UNNotificationRequest(identifier: id, content: calendarNotificationContent, trigger: calendarTrigger)

        logger.info("Notification setted for: \(notificationContent.date)")

        center.add(calendarNotificationRequest)
    }

    private func checkNotificationPermissionGranted() {
        center.getNotificationSettings { settings in
            if settings.authorizationStatus != .authorized {
                self.requestAuthorization()
            }
        }
    }

    func getNotificationsAuthorizationLevel() async -> UNNotificationSettings {
        let settings = await withUnsafeContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }

        return settings
    }

    func setBadgeCountTo0() {
        center.setBadgeCount(0)
    }

    func printAllPendingNotifications() {
        logger.info("printing notifs")
        center.getPendingNotificationRequests { [weak self] requests in
            self?.logger.info("requests.count: \(requests.count)")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    let date = trigger.nextTriggerDate()
                    self?.logger.info("Identifier: \(request.identifier)\nTitle: \(request.content.title)\nBody: \(request.content.body)\nNext Trigger Date: \(date ?? Date())")
                } else {
                    self?.logger.info("Identifier: \(request.identifier)\nTitle: \(request.content.title)\nBody: \(request.content.body)")
                }
            }
        }
    }

    func getAllPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        var ans: [UNNotificationRequest] = []
        center.getPendingNotificationRequests { requests in
            ans.append(contentsOf: requests)
            completion(ans)
        }
    }

    func removeAllPendingNotifications() {
        center.removeAllPendingNotificationRequests()
    }

    func removePendingNotifications(identifiers: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func removeNotification(withID id: String) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
    }

    func shecduleCalendarNotifications(notifications: [NotificationContent]) {
        for notification in notifications {
            scheduleCalendarNotification(notificationContent: notification)
        }
    }

    struct NotificationContent {
        let title: String
        let subtitle: String
        let body: String
        let date: Date
        let userInfo: [AnyHashable: Any]
    }

    func getNotificationID(kontestID: String, minutesBefore: Int, hoursBefore: Int, daysBefore: Int) -> String {
        return kontestID + "\(minutesBefore)\(hoursBefore)\(daysBefore)"
    }

    func getAllNotificationIDsForAKontest(kontestID: String) -> [String] {
        var ans: [String] = []

        ans.append(getNotificationID(kontestID: kontestID, minutesBefore: 10, hoursBefore: 0, daysBefore: 0))
        ans.append(getNotificationID(kontestID: kontestID, minutesBefore: 30, hoursBefore: 0, daysBefore: 0))
        ans.append(getNotificationID(kontestID: kontestID, minutesBefore: 0, hoursBefore: 1, daysBefore: 0))
        ans.append(getNotificationID(kontestID: kontestID, minutesBefore: 0, hoursBefore: 6, daysBefore: 0))

        return ans
    }
}
