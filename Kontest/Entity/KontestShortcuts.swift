//
//  KontestShortcuts.swift
//  Kontest
//
//  Created by Ayush Singhal on 12/06/26.
//

import AppIntents

struct OpenContestIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Contest"
    static let description: IntentDescription = "Select a contest from Kontest"
    
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Contest")
    var kontest: KontestEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        let router = Router.instance
        let allKontestsViewModel = Dependencies.instance.allKontestsViewModel
        
        if let kontest = allKontestsViewModel.allFetchedKontests.first(where: { $0.id == kontest.id}) {
            router.path.append(.kontestModel(kontest))
        } else {
            router.goToRootView()
        }
        return .result()
    }
}

struct OpenSiteContestsIntent: AppIntent {
    static let title: LocalizedStringResource = "Filter by Site"
    static let description: IntentDescription = "Select a contest site"

    @Parameter(title: "Site")
    var site: SiteEntity

    func perform() async throws -> some IntentResult {
        return .result(value: "Contests from \(site.name)")
    }
}

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
