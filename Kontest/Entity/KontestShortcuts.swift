//
//  KontestShortcuts.swift
//  Kontest
//
//  Created by Ayush Singhal on 12/06/26.
//

import AppIntents

@available(iOS 18.4, macOS 15.4, *)
struct OpenContestIntent: OpenIntent {
    static let title: LocalizedStringResource = "Open Contest"
    static let description: IntentDescription = "Select a contest from Kontest"

    static var openAppWhenRun: Bool = true

    @Parameter(title: "Contest")
    var target: KontestEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        let router = Router.instance
        let allKontestsViewModel = Dependencies.instance.allKontestsViewModel

        // Try to find in already-fetched contests by name and site
        if let matchedKontest = allKontestsViewModel.allFetchedKontests.first(where: {
            $0.name == target.name && $0.site == target.site
        }) {
            router.path.append(.kontestModel(matchedKontest))
            print("✅ Opened contest from Spotlight: \(target.name) (\(target.site))")
        } else {
            // If contests not yet loaded, go to root and they'll load
            // The search will make the contest visible
            router.goToRootView()
            print("🔍 Contest will load when app fetches contests: \(target.name) (\(target.site))")
        }
        return .result()
    }
}

@available(iOS 18.4, macOS 15.4, *)
struct GetLatestContestIntent: AppIntent {
    static let title: LocalizedStringResource = "Get Latest Contest"
    static let description: IntentDescription = "Find the latest contest, optionally for a specific platform"

    @Parameter(title: "Platform", description: "The contest platform (optional)")
    var site: SiteEntity?

    @MainActor
    func perform() async throws -> some IntentResult {
        let allKontests = try await KontestNewRepository().getAllKontests()

        var filteredContests = allKontests.compactMap { dto -> (dto: KontestDTO, startDate: Date)? in
            guard let startDate = CalendarUtility.getDate(date: dto.startTime) else { return nil }
            return (dto, startDate)
        }

        // Filter by site if provided
        if let siteName = site?.name {
            filteredContests = filteredContests.filter { $0.dto.site == siteName }
        }

        // Sort by start date to get latest
        filteredContests.sort { $0.startDate < $1.startDate }

        guard let latestContest = filteredContests.first else {
            let noResultsMsg = site != nil
                ? "No upcoming contests found for \(site!.name)"
                : "No upcoming contests found"
            return .result(value: noResultsMsg)
        }

        let dto = latestContest.dto
        let startDate = latestContest.startDate
        let endDate = CalendarUtility.getDate(date: dto.endTime) ?? Date()
        let duration = Int(endDate.timeIntervalSince(startDate) / 3600)

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        let siteInfo = site != nil ? "\(site!.name) " : ""
        let message = "Latest \(siteInfo)contest is \(dto.name). It starts on \(formatter.string(from: startDate)) and lasts \(duration) hours."

        // Donate this interaction to help Apple Intelligence learn
        try? await donate()

        return .result(value: message)
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Get latest \(\.$site) contest")
    }
}

@available(iOS 18.4, macOS 15.4, *)
struct OpenSiteContestsIntent: AppIntent {
    static let title: LocalizedStringResource = "Filter by Site"
    static let description: IntentDescription = "Select a contest site"

    @Parameter(title: "Site")
    var site: SiteEntity

    func perform() async throws -> some IntentResult {
        return .result(value: "Contests from \(site.name)")
    }
}

@available(iOS 18.4, macOS 15.0, *)
struct ShowContestSearchResultsIntent: AppIntent {
    static let title: LocalizedStringResource = "Show Search Results"
    static let description: IntentDescription = "Show contest search results in the app"

    static var openAppWhenRun: Bool = true

    @Parameter(title: "Search Query")
    var searchQuery: String

    @MainActor
    func perform() async throws -> some IntentResult {
        let router = Router.instance

        // Navigate to root to ensure app is initialized
        router.goToRootView()

        // TODO: Pass search query to AllKontestsScreen to auto-fill search
        print("🔍 Opening app with search results for: '\(searchQuery)'")

        return .result(value: "Searching for '\(searchQuery)'")
    }
}

@available(iOS 18.4, macOS 15.4, *)
struct KontestShortcuts: AppShortcutsProvider {

    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {

        AppShortcut(
            intent: OpenContestIntent(),
            phrases: [
                "Open contest in \(.applicationName)",
                "Show contest in \(.applicationName)",
                "Find contest in \(.applicationName)"
            ],
            shortTitle: "Open Contest",
            systemImageName: "trophy"
        )

        AppShortcut(
            intent: GetLatestContestIntent(),
            phrases: [
                "What is the latest contest in \(.applicationName)",
                "Show me the latest contest in \(.applicationName)",
                "Find the latest contest on \(\.$site) in \(.applicationName)",
                "What is the latest \(\.$site) contest in \(.applicationName)",
                "When is the next contest in \(.applicationName)",
                "Tell me about the latest contest in \(.applicationName)"
            ],
            shortTitle: "Latest Contest",
            systemImageName: "sparkles"
        )

        AppShortcut(
            intent: OpenSiteContestsIntent(),
            phrases: [
                "Filter contests by site in \(.applicationName)",
                "Show \(.applicationName) contests from site",
                "Find contests on site in \(.applicationName)"
            ],
            shortTitle: "Filter by Site",
            systemImageName: "building.2"
        )
    }
}
