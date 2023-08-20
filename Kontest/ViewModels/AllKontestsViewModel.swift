//
//  AllKontestsViewModel.swift
//  Kontest
//
//  Created by Ayush Singhal on 12/08/23.
//

import Combine
import SwiftUI

@Observable
class AllKontestsViewModel {
    let repository = KontestRepository()

    private var timer: AnyCancellable?

    var allKontests: [KontestModel] = []
    var searchText: String = "" {
        didSet {
            updateFilteredKontests()
        }
    }

    var isLoading = false

    private(set) var backupKontests: [KontestModel] = []

    init() {
        fetchAllKontests()
    }

    func fetchAllKontests() {
        isLoading = true
        Task {
            await getAllKontests()
            isLoading = false
            backupKontests = allKontests
            removeReminderStatusFromUserDefaults()

            self.timer = Timer.publish(every: 10, on: .main, in: .default)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.updateKontestStatus()
                }
        }
    }

    private func getAllKontests() async {
        do {
            let fetchedKontests = try await repository.getAllKontests()

            await MainActor.run {
                self.allKontests = fetchedKontests
                    .map { dto in
                        let kontest = KontestModel.from(dto: dto)
                        // Load Reminder status
                        kontest.loadReminderStatus()
                        return kontest
                    }
                    .filter { kontest in
                        let kontestDuration = CalendarUtility.getFormattedDuration(fromSeconds: kontest.duration) ?? ""
                        let kontestEndDate = CalendarUtility.getDate(date: kontest.end_time)
                        let isKontestEnded = CalendarUtility.isKontestOfPast(kontestEndDate: kontestEndDate ?? Date())

                        return !kontestDuration.isEmpty && !isKontestEnded
                    }
            }
        } catch {
            print("error in fetching all Kontests: \(error)")
        }
    }

    private func setNotification(kontest: KontestModel, minutesBefore: Int = Constants.minutesToBeReminderBefore, hoursBefore: Int = 0, daysBefore: Int = 0) {
        let kontestStartDate = CalendarUtility.getDate(date: kontest.start_time)
        let notificationDate = CalendarUtility.getTimeBefore(originalDate: kontestStartDate ?? Date(), minutes: minutesBefore, hours: hoursBefore, days: daysBefore)

        LocalNotificationManager.instance.scheduleCalendarNotification(notificationContent: LocalNotificationManager.NotificationContent(title: kontest.name, subtitle: kontest.site, body: "\(kontest.name) is starting in \(Constants.minutesToBeReminderBefore) minutes.", date: notificationDate), id: kontest.id)

        updateIsSetForNotification(kontest: kontest, to: true)
    }

    func setNotificationForKontest(kontest: KontestModel, minutesBefore: Int = Constants.minutesToBeReminderBefore, hoursBefore: Int = 0, daysBefore: Int = 0) {
        setNotification(kontest: kontest, minutesBefore: minutesBefore, hoursBefore: hoursBefore, daysBefore: daysBefore)
    }

    func setNotificationForAllKontests() {
        for i in 0 ..< allKontests.count {
            let kontest = allKontests[i]
            let kontestStartDate = CalendarUtility.getDate(date: kontest.start_time)
            if CalendarUtility.isKontestOfFuture(kontestStartDate: kontestStartDate ?? Date()) {
                setNotification(kontest: kontest, minutesBefore: 10, hoursBefore: 0, daysBefore: 0)

                kontest.isSetForReminder = true
            }
        }
    }

    func removeAllPendingNotifications() {
        LocalNotificationManager.instance.removeAllPendingNotifications()
        for i in 0 ..< allKontests.count {
            updateIsSetForNotification(kontest: allKontests[i], to: false)
        }
    }

    func removePendingNotification(kontest: KontestModel) {
        LocalNotificationManager.instance.removePendingNotification(identifiers: [kontest.id])
        updateIsSetForNotification(kontest: kontest, to: false)
    }

    func printAllPendingNotifications() {
        LocalNotificationManager.instance.printAllPendingNotifications()
    }

    func updateIsSetForNotification(kontest: KontestModel, to: Bool) {
        if let index = allKontests.firstIndex(where: { $0 == kontest }) {
            allKontests[index].isSetForReminder = to
            allKontests[index].saveReminderStatus()
        }
    }

    private func updateFilteredKontests() {
        let filteredKontests = backupKontests
            .filter { kontest in
                kontest.name.localizedCaseInsensitiveContains(searchText) || kontest.site.localizedCaseInsensitiveContains(searchText) || kontest.url.localizedCaseInsensitiveContains(searchText)
            }

        // Update the filtered kontests
        allKontests = searchText.isEmpty ? backupKontests : filteredKontests
    }

    private func removeReminderStatusFromUserDefaults() {
        for kontest in allKontests {
            if isKontestEnded(kontestEndDate: kontest.end_time) {
                kontest.removeReminderStatusFromUserDefaults()
                print("kontest with id: \(kontest.id)'s notification is deleted as kontest is ended.")
            }
        }
    }

    private func isKontestEnded(kontestEndDate: String) -> Bool {
        let currentDate = Date()
        if let formattedKontestEndDate = CalendarUtility.getDate(date: kontestEndDate) {
            return formattedKontestEndDate < currentDate
        }

        return true
    }

    private func updateKontestStatus() {
        var indices: [Int] = []
        for i in 0 ..< allKontests.count {
            allKontests[i].status = allKontests[i].updateKontestStatus()

            if allKontests[i].status == .Ended {
                indices.append(i)
            }
        }

        let indexSet = IndexSet(indices)
        allKontests.remove(atOffsets: indexSet)
    }
}
