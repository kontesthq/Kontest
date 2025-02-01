//
//  AllKontestsViewModelTests.swift
//  KontestTests
//
//  Created by Ayush Singhal on 18/09/23.
//

@testable import Kontest
import XCTest

class AllKontestsViewModelTests: XCTestCase {
    var viewModel: AllKontestsViewModel!

    let originalMinimumDurationOfAKontestInMinutes = UserDefaults(suiteName: Constants.userDefaultsGroupID)!.float(forKey: Constants.minimumDurationOfAKontestInMinutesKey)
    let originalMaximumDurationOfAKontestInMinutes = UserDefaults(suiteName: Constants.userDefaultsGroupID)!.float(forKey: Constants.maximumDurationOfAKontestInMinutesKey)

    override func setUp() async throws {
        UserDefaults(suiteName: Constants.userDefaultsGroupID)?.set(0, forKey: Constants.minimumDurationOfAKontestInMinutesKey)
        UserDefaults(suiteName: Constants.userDefaultsGroupID)?.set(12 * 24 * 60, forKey: Constants.maximumDurationOfAKontestInMinutesKey) // 12 days

        viewModel = AllKontestsViewModel(
            notificationsViewModel: MockNotificationsViewModel(),
            filterWebsitesViewModel: MockFilterWebsitesViewModel(allowedWebsites: ["leetcode.com", "codeforces.com", "hackerearth.com"]),
            repos: MultipleRepositories(repos: [
                AnyFetcher(KontestsTestFakeRepository())
            ]))
    }

    override func tearDown() {
        UserDefaults(suiteName: Constants.userDefaultsGroupID)?.set(originalMinimumDurationOfAKontestInMinutes, forKey: Constants.minimumDurationOfAKontestInMinutesKey)
        UserDefaults(suiteName: Constants.userDefaultsGroupID)?.set(originalMaximumDurationOfAKontestInMinutes, forKey: Constants.maximumDurationOfAKontestInMinutesKey)

        viewModel = nil
    }

    func testInitialization() {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { [weak self] _, _ in
            self?.viewModel.allKontests.count == 4 && self?.viewModel.toShowKontests.count == 3 && self?.viewModel.backupKontests.count == 3
        }), object: nil)
        wait(for: [expectation], timeout: 2)
    }

    func testFilterKontestsUsingSearchText() {
        let expectation1 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { [weak self] _, _ in
            self?.viewModel.searchText = "LeetCode"
            return self?.viewModel.toShowKontests.count == 1
        }), object: nil)

        let expectation2 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { [weak self] _, _ in
            self?.viewModel.searchText = "HackerEarth"
            return self?.viewModel.toShowKontests.count == 1
        }), object: nil)

        let expectation3 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { [weak self] _, _ in
            self?.viewModel.searchText = "CodeForces"
            return self?.viewModel.toShowKontests.count == 1
        }), object: nil)

        wait(for: [expectation1, expectation2, expectation3], timeout: 2)
    }
}

class KontestsTestFakeRepository: KontestFetcher, Fetcher {
    typealias DataType = KontestDTO
    
    func getData() async throws -> [Kontest.KontestDTO] {
        return try await getAllKontests()
    }
    
    func getAllKontests() async throws -> [Kontest.KontestDTO] {
        var allKontests: [KontestDTO]

        let startDate = Date().addingTimeInterval(86400 * 2)
        let endDate = Date().addingTimeInterval(86400 * 5)

        let startDateString = CalendarUtility.formatDateToString(startDate)
        let endDateString = CalendarUtility.formatDateToString(endDate)

        print("startDateString: \(startDateString)")

        allKontests = [
            KontestDTO(name: "ProjectEuler+1", url: "https://hackerrank.com/contests/projecteuler", startTime: startDateString, endTime: endDateString, duration: "1020.0", site: "hackerrank.com", in_24_hours: "No", status: "BEFORE"),

            KontestDTO(name: "1v1 Games by CodeChef", url: "https://www.codechef.com/GAMES", startTime: "2022-10-10 06:30:00 UTC", endTime: "2032-10-10 06:30:00 UTC", duration: "315619200.0", site: "codechef.com", in_24_hours: "No", status: "CODING"), // Expired

            KontestDTO(name: "Weekly Contest 358", url: "https://leetcode.com/contest/weekly-contest-358", startTime: startDateString, endTime: endDateString, duration: "5400", site: "leetcode.com", in_24_hours: "Yes", status: "BEFORE"),

            KontestDTO(name: "CodeForces Round (Div. 2)", url: "https://codeforces.com/enter?back=%2FcontestRegistration%2F1871", startTime: startDateString, endTime: endDateString, duration: "\(86400 * 3)", site: "codeforces.com", in_24_hours: "Yes", status: "CODING"),

            KontestDTO(name: "Hacker Earth Coding", url: "https://hackerearth.com/", startTime: startDateString, endTime: endDateString, duration: "\(86400 * 3)", site: "hackerearth.com", in_24_hours: "Yes", status: "CODING")
        ]

        return allKontests
    }
}
