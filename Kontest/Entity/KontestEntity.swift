//
//  KontestEntity.swift
//  Kontest
//
//  Created by Ayush Singhal on 12/06/26.
//

import AppIntents
import CryptoKit
import CoreSpotlight

@available(iOS 18.4, macOS 15.4, *)
struct KontestEntity: AppEntity, Identifiable, IndexedEntity {
    static let typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "Kontest")

    static let defaultQuery = KontestQuery()

    let id: String

    @Property(title: "Contest Name", indexingKey: \.title)
    var name: String

    @Property(title: "Site")
    var site: String
    
    @Property(title: "Platform")
    var platform: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: name),
            subtitle: LocalizedStringResource(stringLiteral: site)
        )
    }

    var attributeSet: CSSearchableItemAttributeSet {
        let attributes = CSSearchableItemAttributeSet()
        attributes.keywords = [site]
        attributes.contentDescription = platform
        return attributes
    }
}

@available(iOS 18.4, macOS 15.4, *)
extension KontestEntity {
    init(model: KontestModel) {
        self.id = model.id
        self.name = model.name
        self.site = model.site
        self.platform = model.siteAbbreviation
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
@available(iOS 18.4, macOS 15.4, *)
extension KontestEntity {
    static func indexContests(_ contests: [KontestEntity]) async {
        
            do {
                print("📋 Preparing to index \(contests.count) contests...")

                let index = CSSearchableIndex(name: "com.ayush.kontest.contests")

                // Use indexAppEntities directly - modern Spotlight approach recommended by Apple
                try await index.indexAppEntities(contests)
                print("✅ Successfully indexed \(contests.count) contests to Spotlight")
            } catch {
                let nsError = error as NSError
                if nsError.code == 4099 {
                    print("⚠️ Spotlight semantic indexing unavailable (simulator limitation) — will work on device")
                } else {
                    print("❌ Error indexing contests: \(error)")
                }
            }
        
    }

    static func clearIndex() async {
        
            do {
                try await CSSearchableIndex(name: "com.ayush.kontest.contests")
                    .deleteAllSearchableItems()
                print("✅ Successfully cleared Spotlight index")
            } catch {
                print("❌ Error clearing Spotlight index: \(error)")
            }
        }
    

}

@available(iOS 18.4, macOS 15.4, *)
struct KontestQuery: EntityStringQuery {

    func entities(
        for identifiers: [String]
    ) async throws -> [KontestEntity] {
        let allKontestsViewModel = Dependencies.instance.allKontestsViewModel
        let allKontests = allKontestsViewModel.allFetchedKontests

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

        let results = allKontests
            .filter {
                $0.name.localizedCaseInsensitiveContains(string)
                ||
                $0.site.localizedCaseInsensitiveContains(string)
            }
            .map(KontestEntity.init)

        print("🔍 === SIRI SEARCH RESULTS ===")
        print("Query: '\(string)'")
        print("Results: \(results.count) contests found")
        for result in results {
            print("  📍 \(result.name) | \(result.site)")
        }
        print("================================\n")

        return results
    }
}
