//
//  KontestEntity.swift
//  Kontest
//
//  Created by Ayush Singhal on 12/06/26.
//

import AppIntents
import CryptoKit

struct KontestEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "Kontest")

    static let defaultQuery = KontestQuery()

    let id: String
    let name: String
    let site: String
    let startDate: Date
    let endDate: Date

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: name),
            subtitle: LocalizedStringResource(stringLiteral: site)
        )
    }
}

extension KontestEntity {
    init(model: KontestModel) {
        self.id = model.id
        self.name = model.name
        self.site = model.site
        self.startDate = CalendarUtility.getDate(date: model.start_time) ?? .now
        self.endDate = CalendarUtility.getDate(date: model.end_time) ?? .now
    }

    init(dto: KontestDTO) {
        self.id = Self.generateUniqueID(dto: dto)
        self.name = dto.name
        self.site = dto.site
        self.startDate = CalendarUtility.getDate(date: dto.startTime) ?? .now
        self.endDate = CalendarUtility.getDate(date: dto.endTime) ?? .now
    }

    private static func generateUniqueID(dto: KontestDTO) -> String {
        let combinedString = "\(dto.name)\(dto.url)\(dto.startTime)\(dto.endTime)\(dto.duration)\(dto.site)\(dto.in_24_hours)\(dto.status)"
        if let data = combinedString.data(using: .utf8) {
            let hash = SHA256.hash(data: data)
            return hash.compactMap { String(format: "%02x", $0) }.joined()
        }
        return ""
    }
}

struct KontestQuery: EntityStringQuery {

    func entities(
        for identifiers: [String]
    ) async throws -> [KontestEntity] {
        let allKontests = try await KontestNewRepository().getAllKontests()

        return allKontests
            .map(KontestEntity.init)
            .filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [KontestEntity] {
        print("returning suggested kontests")
        let allKontestsViewModel = Dependencies.instance.allKontestsViewModel
        let allKontests = allKontestsViewModel.allFetchedKontests

        return allKontests
            .map(KontestEntity.init)
            .filter { $0.endDate > .now }
            .sorted { $0.startDate < $1.startDate }
            .prefix(10)
            .map { $0 }
    }

    func entities(
        matching string: String
    ) async throws -> [KontestEntity] {
        let allKontestsViewModel = Dependencies.instance.allKontestsViewModel
        let allKontests = allKontestsViewModel.allFetchedKontests

        return allKontests
            .filter {
                $0.name.localizedCaseInsensitiveContains(string)
                ||
                $0.site.localizedCaseInsensitiveContains(string)
            }
            .map(KontestEntity.init)
    }
}
