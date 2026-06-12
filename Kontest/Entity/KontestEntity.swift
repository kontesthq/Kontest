//
//  KontestEntity.swift
//  Kontest
//
//  Created by Ayush Singhal on 12/06/26.
//

import AppIntents
import CryptoKit
import CoreSpotlight

@available(iOS 18.0, macOS 15.0, *)
struct KontestEntity: AppEntity, Identifiable, IndexedEntity {
    static let typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "Kontest")

    static let defaultQuery = KontestQuery()

    let id: String
    let name: String
    let site: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: name),
            subtitle: LocalizedStringResource(stringLiteral: site)
        )
    }
}

@available(iOS 18.0, macOS 15.0, *)
extension KontestEntity {
    init(model: KontestModel) {
        self.id = model.id
        self.name = model.name
        self.site = model.site
    }

    init(dto: KontestDTO) {
        self.id = Self.generateUniqueID(dto: dto)
        self.name = dto.name
        self.site = dto.site
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

// MARK: - Spotlight Indexing (iOS 18+)
@available(iOS 18.0, macOS 15.0, *)
extension KontestEntity {
    static func indexContests(_ contests: [KontestEntity]) {
        Task {
            do {
                // Use the modern IndexedEntity API with named index
                try await CSSearchableIndex(name: "com.ayush.kontest.contests")
                    .indexAppEntities(contests, priority: 100)
                print("✅ Successfully indexed \(contests.count) contests to Spotlight")
            } catch {
                print("❌ Error indexing contests: \(error)")
            }
        }
    }

    static func clearIndex() {
        Task {
            do {
                try await CSSearchableIndex(name: "com.ayush.kontest.contests")
                    .deleteAllSearchableItems()
                print("✅ Successfully cleared Spotlight index")
            } catch {
                print("❌ Error clearing Spotlight index: \(error)")
            }
        }
    }
}

@available(iOS 18.0, macOS 15.0, *)
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
