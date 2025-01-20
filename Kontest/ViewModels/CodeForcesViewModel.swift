//
//  CodeForcesViewModel.swift
//  Kontest
//
//  Created by Ayush Singhal on 16/08/23.
//

import OSLog
import SwiftUI

@Observable
final class CodeForcesViewModel: Sendable {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "CodeForcesViewModel")
    
    let repository: any CodeForcesFetcher
    
    let username: String
    var codeForcesRatings: CodeForcesUserRatingAPIModel?
    var codeForcesUserInfos: CodeForcesUserInfoAPIModel?
    var isLoading = false
    
    var attendedKontests: [CodeForcesuserRatingAPIResultModel] = []
    
    var error: (any Error)?
    
    init(username: String, repository: any CodeForcesFetcher) {
        self.error = nil
        self.username = username
        self.repository = repository
        self.isLoading = true
        
        self.sortedDates = []

        self.chartXScrollPosition = .now
        
        if !username.isEmpty {
            Task {
                await self.getCodeForcesRatings(username: username)
                await self.getCodeForcesUserInfo(username: username)
                
                if let codeForcesRatings {
                    self.sortedDates = codeForcesRatings.result.map { codeForcesuserRatingAPIResultModel in
                        let updateTime = codeForcesuserRatingAPIResultModel.ratingUpdateTimeSeconds
                        let updateDate = Date(timeIntervalSince1970: Double(updateTime))
                    
                        return updateDate
                    }
                    
                    for result in codeForcesRatings.result {
                        self.attendedKontests.append(result)
                    }
                }
                
                self.chartXScrollPosition = sortedDates.first?.addingTimeInterval(-86400 * 3) ?? .now
                
                self.isLoading = false
            }
        } else {
            self.isLoading = false
        }
    }
    
    private func getCodeForcesRatings(username: String) async {
        do {
            let fetchedCodeForcesRatings = try await repository.getUserRating(username: username)
//            logger.info("\("\(fetchedCodeForcesRatings)")")
            
            codeForcesRatings = CodeForcesUserRatingAPIModel.from(dto: fetchedCodeForcesRatings)
        } catch {
            self.error = error
            logger.error("error in fetching CodeForces Rating: \(error)")
        }
    }
    
    func getRatingsTitle() -> (title: String, color: Color) {
        guard let codeForcesRatings else { return ("U n r a t e d".uppercased(), .black) }
        
        let newRating = codeForcesRatings.result[codeForcesRatings.result.count - 1].newRating

        return if newRating <= 1199 {
            ("N e w b i e".uppercased(), .white)
        } else if newRating <= 1399 {
            ("P u p i l".uppercased(), .green.opacity(0.5))
        } else if newRating <= 1599 {
            ("S p e c i a l i s t".uppercased(), .cyan)
        } else if newRating <= 1899 {
            ("E x p e r t".uppercased(), .blue)
        } else if newRating <= 2199 {
            ("Candidate Master".uppercased(), Color(red: 255/255, green: 85/255, blue: 254/255))
        } else if newRating <= 2299 {
            ("M a s t e r".uppercased(), .orange)
        } else if newRating <= 2399 {
            ("International Master".uppercased(), .orange)
        } else if newRating <= 2599 {
            ("Grandmaster".uppercased(), .red)
        } else if newRating <= 2899 {
            ("International Grandmaster".uppercased(), .red)
        } else {
            ("Legendary Grandmaster".uppercased(), .red)
        }
    }
    
    private func getCodeForcesUserInfo(username: String) async {
        do {
            let fetchedCodeForcesUserInfo = try await repository.getUserInfo(username: username)
//            logger.info("\("\(fetchedCodeForcesUserInfo)")")
            
            codeForcesUserInfos = CodeForcesUserInfoAPIModel.from(dto: fetchedCodeForcesUserInfo)
        } catch {
            self.error = error
            logger.error("error in fetching CodeForces User Info: \(error)")
        }
    }
    
    var sortedDates: [Date]
    
    @ObservationIgnored
    var rawSelectedDate: Date? {
        didSet(newValue) {
            if let newValue {
                print("rawSelectedDate changed")

                let selectedDay = Calendar.current.startOfDay(for: newValue)

                let foundDate = sortedDates.first { date in
                    Calendar.current.startOfDay(for: date) == selectedDay
                }

                if let foundDate {
                    selectedDate = foundDate
                } else {
                    if selectedDate != nil {
                        selectedDate = nil
                    }
                }
            }
        }
    }
    
    var selectedDate: Date? {
        didSet {
            print("selectedDate changed")
        }
    }

    @ObservationIgnored
    var chartXScrollPosition: Date {
        willSet {
            print("chartScrollPosition willSet")
        }

        didSet {
            print("chartScrollPosition didSet")
        }
    }
}
