//
//  AllKontestsViewModel.swift
//  Kontest
//
//  Created by Ayush Singhal on 12/08/23.
//

import Combine
import Foundation
import OSLog

@Observable
class AllKontestsViewModel {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "AllKontestsViewModel")

    let repository = KontestRepository()

    static let instance = AllKontestsViewModel()

    private var timer: AnyCancellable?

    var errorWrapper: ErrorWrapper?

    private(set) var allKontests: [KontestModel] = []
    private(set) var toShowKontests: [KontestModel] = []
    private(set) var backupKontests: [KontestModel] = []

    private(set) var ongoingKontests: [KontestModel] = []
    private(set) var laterTodayKontests: [KontestModel] = []
    private(set) var tomorrowKontests: [KontestModel] = []
    private(set) var laterKontests: [KontestModel] = []

    private let shouldFetchAllEventsFromCalendar: Bool

    var searchText: String = "" {
        didSet {
            filterKontestsUsingSearchText()
        }
    }

    var isLoading = false

    private init() {
        shouldFetchAllEventsFromCalendar = UserDefaults.standard.bool(forKey: "shouldFetchAllEventsFromCalendar")
        setDefaultValuesForFilterWebsiteKeysToTrue()
        addAllowedWebsites()
        fetchAllKontests()
    }

    func fetchAllKontests() {
        isLoading = true
        Task {
            await getAllKontests()
            checkNotificationAuthorization()
            filterKontests()
            isLoading = false
            removeReminderStatusFromUserDefaultsOfKontestsWhichAreEnded()

            self.timer = Timer.publish(every: 1, on: .main, in: .default)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self else { return }

                    if self.searchText.isEmpty {
                        self.splitKontestsIntoDifferentCategories()
                    }
                }
        }
    }

    private func getAllKontests() async {
        do {
            let fetchedKontests = try await repository.getAllKontests()

            let allEvents = shouldFetchAllEventsFromCalendar ? try await CalendarUtility.getAllEvents() : []

            await MainActor.run {
                self.allKontests = fetchedKontests
                    .map { dto in
                        let kontest = KontestModel.from(dto: dto)
                        // Load Reminder status
                        kontest.loadReminderStatus()

                        // Load Calendar status
                        kontest.loadCalendarStatus(allEvents: allEvents ?? [])

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
            logger.error("error in fetching all Kontests: \(error)")
        }
    }

    private func filterKontestsUsingSearchText() {
        let filteredKontests = backupKontests
            .filter { kontest in
                kontest.name.localizedCaseInsensitiveContains(searchText) || kontest.site.localizedCaseInsensitiveContains(searchText) || kontest.url.localizedCaseInsensitiveContains(searchText)
            }

        // Update the filtered kontests
        toShowKontests = searchText.isEmpty ? backupKontests : filteredKontests

        splitKontestsIntoDifferentCategories()
    }

    private func removeReminderStatusFromUserDefaultsOfKontestsWhichAreEnded() {
        for kontest in toShowKontests {
            if isKontestEnded(kontestEndDate: kontest.end_time) {
                kontest.removeReminderStatusFromUserDefaults()
                logger.info("kontest with id: \(kontest.id)'s notification is deleted as kontest is ended.")
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

    func filterKontests() {
        toShowKontests = allKontests.filter {
            let isKontestWebsiteInAllowedWebsites = allowedWebsites.contains($0.site)

            return isKontestWebsiteInAllowedWebsites
        }
        backupKontests = toShowKontests
        splitKontestsIntoDifferentCategories()
    }

    private func splitKontestsIntoDifferentCategories() {
        let today = Date()
        let tomorrow = CalendarUtility.getTomorrow()
        let dayAfterTomorrow = CalendarUtility.getDayAfterTomorrow()

        toShowKontests = toShowKontests.filter {
            let kontestEndDate = CalendarUtility.getDate(date: $0.end_time)
            let isKontestEnded = CalendarUtility.isKontestOfPast(kontestEndDate: kontestEndDate ?? Date())

            return !isKontestEnded
        }

        ongoingKontests = toShowKontests.filter { CalendarUtility.isKontestRunning(kontestStartDate: CalendarUtility.getDate(date: $0.start_time) ?? today, kontestEndDate: CalendarUtility.getDate(date: $0.end_time) ?? today) }

        laterTodayKontests = toShowKontests.filter {
            CalendarUtility.getDate(date: $0.start_time) ?? today < tomorrow && !(ongoingKontests.contains($0))
        }

        tomorrowKontests = toShowKontests.filter { (CalendarUtility.getDate(date: $0.start_time) ?? today >= tomorrow) && (CalendarUtility.getDate(date: $0.start_time) ?? today < dayAfterTomorrow) }

        laterKontests = toShowKontests.filter {
            CalendarUtility.getDate(date: $0.start_time) ?? today >= dayAfterTomorrow
        }
    }

    private var allowedWebsites: [String] = []

    func addAllowedWebsites() {
        allowedWebsites.removeAll()

        logger.info("Ran addAllowedWebsites()")

        if UserDefaults.standard.bool(forKey: FilterWebsiteKey.codeForcesKey.rawValue) {
            allowedWebsites.append("CodeForces")
        }

        if UserDefaults.standard.bool(forKey: FilterWebsiteKey.atCoderKey.rawValue) {
            allowedWebsites.append("AtCoder")
        }

        if UserDefaults.standard.bool(forKey: FilterWebsiteKey.cSAcademyKey.rawValue) {
            allowedWebsites.append("CS Academy")
        }

        if UserDefaults.standard.bool(forKey: FilterWebsiteKey.codeChefKey.rawValue) {
            allowedWebsites.append("CodeChef")
        }

        if UserDefaults.standard.bool(forKey: FilterWebsiteKey.hackerRankKey.rawValue) {
            allowedWebsites.append("HackerRank")
        }

        if UserDefaults.standard.bool(forKey: FilterWebsiteKey.hackerEarthKey.rawValue) {
            allowedWebsites.append("HackerEarth")
        }

        if UserDefaults.standard.bool(forKey: FilterWebsiteKey.leetCodeKey.rawValue) {
            allowedWebsites.append("LeetCode")
        }

        if UserDefaults.standard.bool(forKey: FilterWebsiteKey.tophKey.rawValue) {
            allowedWebsites.append("Toph")
        }
    }

    private func checkNotificationAuthorization() {
        Task {
            let numberOfNotifications = NotificationsViewModel.instance.pendingNotifications.count
            if numberOfNotifications > 0 {
                let notificationsAuthorizationLevel = await LocalNotificationManager.instance.getNotificationsAuthorizationLevel()

                if notificationsAuthorizationLevel.authorizationStatus == .denied {
                    logger.info("notificationsAuthorizationLevel.authorizationStatus: \("\(notificationsAuthorizationLevel.authorizationStatus)")")

                    errorWrapper = ErrorWrapper(error: AppError(title: "Permission not Granted", description: "You have set some notifications, but notification permission is not granted"), guidance: "Please provide Notification Permission in order to get notifications")

                    logger.info("errorWrapper: \("\(String(describing: errorWrapper))")")
                }
            }
        }
    }
}
