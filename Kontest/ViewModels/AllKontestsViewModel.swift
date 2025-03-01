//
//  AllKontestsViewModel.swift
//  Kontest
//
//  Created by Ayush Singhal on 12/08/23.
//

import Combine
import Foundation
import OSLog
import UserNotifications

@Observable
final class AllKontestsViewModel: Sendable {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "AllKontestsViewModel")

    let notificationsViewModel: any NotificationsViewModelProtocol
    let filterWebsitesViewModel: any FilterWebsitesViewModelProtocol

    private var timer: AnyCancellable?

    var errorWrapper: ErrorWrapper?

    private(set) var allFetchedKontests: [KontestModel] = []
    private(set) var allKontests: [KontestModel] = []
    private(set) var toShowKontests: [KontestModel] = []
    private(set) var backupKontests: [KontestModel] = []

    private(set) var ongoingKontests: [KontestModel] = []
    private(set) var laterTodayKontests: [KontestModel] = []
    private(set) var tomorrowKontests: [KontestModel] = []
    private(set) var laterKontests: [KontestModel] = []

    private var nextDateToRefresh: Date?

    private var hasFullAccessToCalendar: Bool

    var searchText: String = "" {
        didSet {
            filterKontestsUsingSearchText()
        }
    }

    var isLoading = false

    let repositories: MultipleRepositories<KontestDTO>

    init(notificationsViewModel: any NotificationsViewModelProtocol, filterWebsitesViewModel: any FilterWebsitesViewModelProtocol, repos: MultipleRepositories<KontestDTO>) {
        repositories = repos
        self.notificationsViewModel = notificationsViewModel
        self.filterWebsitesViewModel = filterWebsitesViewModel
        hasFullAccessToCalendar = UserDefaults(suiteName: Constants.userDefaultsGroupID)!.bool(forKey: "shouldFetchAllEventsFromCalendar")
        setDefaultValuesForFilterWebsiteKeysToTrue()
        setDefaultValuesForMinAndMaxDurationKeys()
        setDefaultValuesForAutomaticCalendarEventToFalse()
        addAllowedWebsites()
        fetchAllKontests()

        #if os(macOS)
        do {
            try addCalendarObserver()
        } catch {
            logger.info("Can not add observer to Calendar with error: \(error)")
        }
        #endif

        _ = AuthenticationManager.shared // To initialize the AuthenticationManager
    }

    func fetchAllKontests() {
        isLoading = true
        Task {
            await getAllKontests()

            await cleanupContestsFromCalendarAndNotifications(allKontests: allKontests)

            await MainActor.run {
                sortAllKontests()
            }

            checkNotificationAuthorization()
            filterKontests()

            await addAutomaticEventsToCalendarAndNotifications()

            // Doing this here (after splitting kontests into categories initially)
            nextDateToRefresh = CalendarUtility.getNextDateToRefresh(
                ongoingKontests: ongoingKontests,
                laterTodayKontests: laterTodayKontests,
                tomorrowKontests: tomorrowKontests,
                laterKontests: laterKontests
            )

            isLoading = false
            removeReminderStatusFromUserDefaultsOfKontestsWhichAreEnded()

            self.timer = Timer.publish(every: 1, on: .main, in: .default)
                .autoconnect()
                .sink { [weak self] timer in
                    guard let self else { return }

                    let timeInterval = Double(timer.timeIntervalSince1970)
                    let currentDate = Date(timeIntervalSince1970: timeInterval)

                    if let nextDateToRefresh {
                        let timeInterval = currentDate.timeIntervalSince(nextDateToRefresh)
//                        logger.info("nextDateToRefresh: \(nextDateToRefresh.formatted())\ntimeInterval: \(timeInterval)")

                        if timeInterval >= -5, timeInterval <= 5 {
                            if self.searchText.isEmpty {
                                self.splitKontestsIntoDifferentCategories()
                            }
                        } else if timeInterval > 5, timeInterval <= 10 {
                            logger.log("Getting nextDateToRefresh")
                            self.nextDateToRefresh = CalendarUtility.getNextDateToRefresh(
                                ongoingKontests: ongoingKontests,
                                laterTodayKontests: laterTodayKontests,
                                tomorrowKontests: tomorrowKontests,
                                laterKontests: laterKontests
                            )
                        }
                    } else {
                        if self.searchText.isEmpty {
                            self.splitKontestsIntoDifferentCategories()
                        }
                    }
                }
        }
    }

    public func addAutomaticEventsToCalendarAndNotifications() async {
        // Adding automatic calendar events
        let automaticNotificationsViewModel = AutomaticNotificationsViewModel.instance
        if hasFullAccessToCalendar {
            await automaticNotificationsViewModel.addAutomaticCalendarEventToEligibleSites(kontests: toShowKontests)
        }

        // Adding automatic notifications
        let notificationAuthorizationLevel = await LocalNotificationManager.instance.getNotificationsAuthorizationLevel()
        if notificationAuthorizationLevel.authorizationStatus == .authorized {
            await automaticNotificationsViewModel.addAutomaticNotificationToEligibleSites(kontests: toShowKontests)
        }
    }

    private func getAllKontests() async {
        do {
            let fetchedKontests = try await repositories.fetchAllData()

            print("fetchedKontests: \(fetchedKontests)")

            hasFullAccessToCalendar = CalendarUtility.getAuthorizationStatus() == .fullAccess

            let allEvents = hasFullAccessToCalendar ? try await CalendarUtility.getAllEvents() : []

            allFetchedKontests = fetchedKontests
                .map { dto in
                    let kontest = KontestModel.from(dto: dto)
                    // Load Reminder status
                    kontest.loadReminderStatus()

                    // Load Calendar status
                    kontest.loadCalendarStatus(allEvents: allEvents ?? [])
                    kontest.loadCalendarEventDate(allEvents: allEvents ?? [])
                    kontest.loadEventCalendar(allEvents: allEvents ?? [])

                    return kontest
                }

            filterKontestsByTime()

        } catch {
            logger.error("error in fetching all Kontests: \(error)")

            allKontests = []
        }
    }

    func filterKontestsByTime() {
        allKontests = allFetchedKontests
            .filter { kontest in
                let kontestDuration = CalendarUtility.getFormattedDuration(fromSeconds: kontest.duration) ?? ""
                let kontestEndDate = CalendarUtility.getDate(date: kontest.end_time)
                let isKontestEnded = CalendarUtility.isKontestOfPast(kontestEndDate: kontestEndDate ?? Date())

                return !kontestDuration.isEmpty && !isKontestEnded
            }
    }

    func sortAllKontests() {
        allKontests.sort { CalendarUtility.getDate(date: $0.start_time) ?? Date() < CalendarUtility.getDate(date: $1.start_time) ?? Date() }
    }

    private func filterKontestsUsingSearchText() {
        let filteredKontests = backupKontests
            .filter { kontest in
                kontest.name.localizedCaseInsensitiveContains(searchText) || kontest.siteAbbreviation.localizedCaseInsensitiveContains(searchText) || kontest.url.localizedCaseInsensitiveContains(searchText)
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

    func addAllowedWebsites() {
        allowedWebsites.removeAll()

        logger.info("Ran addAllowedWebsites()")

        allowedWebsites.append(contentsOf: filterWebsitesViewModel.getAllowedWebsites())
    }

    func filterKontests() {
        toShowKontests = allKontests.filter { allowedWebsites.contains($0.site) }

        backupKontests = toShowKontests
        splitKontestsIntoDifferentCategories()
    }

    private func splitKontestsIntoDifferentCategories() {
        let today = Date()

        toShowKontests = toShowKontests.filter {
            let kontestEndDate = CalendarUtility.getDate(date: $0.end_time)
            let isKontestEnded = CalendarUtility.isKontestOfPast(kontestEndDate: kontestEndDate ?? Date())

            return !isKontestEnded
        }

        ongoingKontests = toShowKontests.filter { CalendarUtility.isKontestRunning(kontestStartDate: CalendarUtility.getDate(date: $0.start_time) ?? today, kontestEndDate: CalendarUtility.getDate(date: $0.end_time) ?? today) }

        ongoingKontests = ongoingKontests.sorted { kontestModel1, kontestModel2 in
            CalendarUtility.getDate(date: kontestModel1.end_time) ?? Date() < CalendarUtility.getDate(date: kontestModel2.end_time) ?? Date()
        }

        laterTodayKontests = toShowKontests.filter { CalendarUtility.isKontestLaterToday(kontestStartDate: CalendarUtility.getDate(date: $0.start_time) ?? Date()) }

        tomorrowKontests = toShowKontests.filter { CalendarUtility.isKontestTomorrow(kontestStartDate: CalendarUtility.getDate(date: $0.start_time) ?? Date()) }

        laterKontests = toShowKontests.filter { CalendarUtility.isKontestLater(kontestStartDate: CalendarUtility.getDate(date: $0.start_time) ?? Date()) }
    }

    private var allowedWebsites: [String] = []

    private func checkNotificationAuthorization() {
        Task {
            let notificationsAuthorizationLevel = await LocalNotificationManager.instance.getNotificationsAuthorizationLevel()

            if notificationsAuthorizationLevel.authorizationStatus == .denied {
                let numberOfNotifications = notificationsViewModel.pendingNotifications.count

                if numberOfNotifications > 0 {
                    logger.info("notificationsAuthorizationLevel.authorizationStatus: \("\(notificationsAuthorizationLevel.authorizationStatus)")")

                    errorWrapper = ErrorWrapper(
                        error: AppError(
                            title: "Permission not Granted",
                            description: "You have set some notifications, but notification permission is not granted",
                            action: {
                                self.notificationsViewModel.removeAllPendingNotifications()
                            },
                            actionLabel: "Remove all notifications"
                        ),
                        guidance: "Please provide Notification Permission in order to get notifications"
                    )

                    logger.info("errorWrapper: \("\(String(describing: self.errorWrapper))")")
                }
            }
        }
    }
    
    private func cleanupContestsFromCalendarAndNotifications(allKontests: [KontestModel]) async {
        await cleanupCancelledContestsFromCalendarAndNotifications(allKontests: allKontests)
        await cleanupDuplicateContestsFromCalendarAndNotifications()
    }

    private func cleanupCancelledContestsFromCalendarAndNotifications(allKontests: [KontestModel]) async {
        if CalendarUtility.getAuthorizationStatus() == .fullAccess {
            let allKontestEvents = await CalendarUtility.getAllKontestEvents()

            if let allKontestEvents {
                for kontestEvent in allKontestEvents {
                    if kontestEvent.startDate > .now { // remove only those events which are not gonna happen in future
                        if allKontests.contains(where: { $0.name == kontestEvent.title && CalendarUtility.getDate(date: $0.start_time) == kontestEvent.startDate && CalendarUtility.getDate(date: $0.end_time) == kontestEvent.endDate }) {
                            continue
                        }

                        try? await CalendarUtility.removeEvent(event: kontestEvent)
                    }
                }
            }
        }

        if hasFullAccessToCalendar {
            let notificationVM = Dependencies.instance.notificationsViewModel
            let localNotificationManager = LocalNotificationManager.instance

            let allPendingNotifications = notificationVM.pendingNotifications

            for notification in allPendingNotifications {
                if allKontests.contains(where: { kontestModel in
                    localNotificationManager.getAllNotificationIDsForAKontest(kontestID: kontestModel.id).contains(notification.identifier)
                }) {
                    continue
                }

                localNotificationManager.removeNotification(withID: notification.identifier)
            }
        }
    }

    private func cleanupDuplicateContestsFromCalendarAndNotifications() async {
        if CalendarUtility.getAuthorizationStatus() == .fullAccess {
            let allKontestEvents = await CalendarUtility.getAllKontestEvents()

            if let allKontestEvents {
                var seenEvents = Set<String>()

                for kontestEvent in allKontestEvents {
                    let eventKey = "\(kontestEvent.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))-\(String(describing: kontestEvent.startDate))-\(String(describing: kontestEvent.endDate))"

                    if seenEvents.contains(eventKey) {
                        try? await CalendarUtility.removeEvent(event: kontestEvent)
                    } else {
                        seenEvents.insert(eventKey)
                    }
                }
            }
        }

        if hasFullAccessToCalendar {
            let notificationVM = Dependencies.instance.notificationsViewModel
            let localNotificationManager = LocalNotificationManager.instance

            let allPendingNotifications = notificationVM.pendingNotifications
            var seenNotifications = Set<String>()

            for notification in allPendingNotifications {
                let triggerTime: String

                if let calendarTrigger = notification.trigger as? UNCalendarNotificationTrigger,
                   let triggerDate = Calendar.current.date(from: calendarTrigger.dateComponents)
                {
                    triggerTime = "\(triggerDate.timeIntervalSince1970)"
                } else if let timeTrigger = notification.trigger as? UNTimeIntervalNotificationTrigger {
                    triggerTime = "\(timeTrigger.timeInterval)"
                } else {
                    triggerTime = "unknown" // Fallback for non-time-based triggers
                }

                let notificationKey = "\(notification.content.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))-\(notification.content.body.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))-\(triggerTime)"

                if seenNotifications.contains(notificationKey) {
                    localNotificationManager.removePendingNotifications(identifiers: [notification.identifier])
                } else {
                    seenNotifications.insert(notificationKey)
                }
            }
        }
    }

    func toPerformWhenAppBecomeActive(codeChefUsername: String, codeForcesUsername: String, leetcodeUsername: String) {
        Task {
            await refreshKontests()
        }

        LocalNotificationManager.instance.setBadgeCountTo0()
    }

    func refreshData(codeChefUsername: String, codeForcesUsername: String, leetcodeUsername: String) async {
        Dependencies.instance.changeCodeChefUsername(codeChefUsername: codeChefUsername)
        Dependencies.instance.changeCodeForcesUsername(codeForcesUsername: codeForcesUsername)
        Dependencies.instance.changeLeetcodeUsername(leetCodeUsername: leetcodeUsername)

        await refreshKontests()
    }

    func refreshKontests() async {
        await getAllKontests()
        filterKontests()
        await addAutomaticEventsToCalendarAndNotifications()
        await cleanupContestsFromCalendarAndNotifications(allKontests: allKontests)
    }

    #if os(macOS)
    func addCalendarObserver() throws {
        if CalendarUtility.getAuthorizationStatus() == .fullAccess {
            CalendarUtility.addCalendarObserver(onChange: { [weak self] _ in
                guard let self else { return }
                print("Yes")

                Task {
                    let allEvents = self.hasFullAccessToCalendar ? try await CalendarUtility.getAllEvents() : []

                    for kontest in self.ongoingKontests {
                        kontest.loadCalendarStatus(allEvents: allEvents ?? [])
                        kontest.loadCalendarEventDate(allEvents: allEvents ?? [])
                        kontest.loadEventCalendar(allEvents: allEvents ?? [])
                    }

                    for kontest in self.laterTodayKontests {
                        kontest.loadCalendarStatus(allEvents: allEvents ?? [])
                        kontest.loadCalendarEventDate(allEvents: allEvents ?? [])
                        kontest.loadEventCalendar(allEvents: allEvents ?? [])
                    }

                    for kontest in self.tomorrowKontests {
                        kontest.loadCalendarStatus(allEvents: allEvents ?? [])
                        kontest.loadCalendarEventDate(allEvents: allEvents ?? [])
                        kontest.loadEventCalendar(allEvents: allEvents ?? [])
                    }

                    for kontest in self.laterKontests {
                        kontest.loadCalendarStatus(allEvents: allEvents ?? [])
                        kontest.loadCalendarEventDate(allEvents: allEvents ?? [])
                        kontest.loadEventCalendar(allEvents: allEvents ?? [])
                    }
                }
            })
        }
    }
    #endif
}
