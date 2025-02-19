//
//  PendingNotificationsScreen.swift
//  Kontest
//
//  Created by Ayush Singhal on 17/08/23.
//

import SwiftUI
import UserNotifications

struct PendingNotificationsScreen: View {
    let notificationsViewModel = Dependencies.instance.notificationsViewModel

    var body: some View {
        VStack {
            List {
                Text("Total Notifications: \(notificationsViewModel.pendingNotifications.count)")
                ForEach(notificationsViewModel.pendingNotifications, id: \.self) { notificationRequest in
                    HStack {
                        Spacer()
                        SingleNotificationView(notificationRequest: notificationRequest)
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            notificationsViewModel.getAllPendingNotifications()
        }
    }
}

struct SingleNotificationView: View {
    let notificationRequest: UNNotificationRequest
    var body: some View {
        VStack {
            Text("Title: \(notificationRequest.content.title)")
                .bold()

            Text("SubTitle: \(notificationRequest.content.subtitle)")
                .italic()

            Text("Body: \(notificationRequest.content.body)")
            
            Text("userInfo: \(notificationRequest.content.userInfo)")

            Text("ID: \(notificationRequest.identifier)")
            Spacer()
            if let trigger = notificationRequest.trigger as? UNCalendarNotificationTrigger {
                let triggerTime = trigger.nextTriggerDate()
                let triggerTimeString = (triggerTime ?? Date()).formatted(date: .abbreviated, time: .shortened)
                Text("Notification Trigger Time: \(triggerTimeString)")
            }
            Spacer()
        }
        .multilineTextAlignment(.center)
    }
}

#Preview {
    PendingNotificationsScreen()
}

#Preview("SingleNotificationView") {
    let kontent = UNMutableNotificationContent()
    kontent.title = "Toyota Programming Contest Final"
    kontent.subtitle = "AtCoder"
    kontent.body = "RECRUIT Nihonbashi Half Marathon 2023 Summer (AtCoder Heuristic Contest 022)"

    var dateComponents = DateComponents()
    dateComponents.year = 2023
    dateComponents.month = 8
    dateComponents.day = 18
    dateComponents.hour = 15
    dateComponents.minute = 30

    let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

    let mockRequest = UNNotificationRequest(
        identifier: "mockIdentifier",
        content: kontent,
        trigger: calendarTrigger
    )

    return
        List {
            SingleNotificationView(notificationRequest: mockRequest)
            SingleNotificationView(notificationRequest: mockRequest)
        }
}
