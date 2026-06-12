//
//  SiteEntity.swift
//  Kontest
//
//  Created by Ayush Singhal on 12/06/26.
//

import AppIntents

struct SiteEntity: AppEntity {
    static let typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "Contest Site")

    static let defaultQuery = SiteQuery()

    let id: String
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: name))
    }
}

struct SiteQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [SiteEntity] {
        let allKontests = try await KontestNewRepository().getAllKontests()
        let uniqueSites = Array(Set(allKontests.map { $0.site })).sorted()

        return uniqueSites
            .filter { identifiers.contains($0) }
            .map { SiteEntity(id: $0, name: $0) }
    }

    func suggestedEntities() async throws -> [SiteEntity] {
        print("returning suggested sites")
        let allKontestsViewModel = Dependencies.instance.allKontestsViewModel
        let allKontests = allKontestsViewModel.allFetchedKontests
        let uniqueSites = Array(Set(allKontests.map { $0.site })).sorted()

        return uniqueSites
            .prefix(10)
            .map { SiteEntity(id: $0, name: $0) }
    }

    func entities(matching string: String) async throws -> [SiteEntity] {
        let allKontestsViewModel = Dependencies.instance.allKontestsViewModel
        let allKontests = allKontestsViewModel.allFetchedKontests
        let uniqueSites = Array(Set(allKontests.map { $0.site })).sorted()

        return uniqueSites
            .filter { $0.localizedCaseInsensitiveContains(string) }
            .map { SiteEntity(id: $0, name: $0) }
    }
}
