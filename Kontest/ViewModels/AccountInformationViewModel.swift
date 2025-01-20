//
//  AccountInformationViewModel.swift
//  Kontest
//
//  Created by Ayush Singhal on 1/16/24.
//

import Foundation
import OSLog

@Observable
class AccountInformationViewModel {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "AccountInformationViewModel")
    
    private init() {
        getAuthenticatedUser()
    }
    
    static let shared = AccountInformationViewModel()
    
    var user: DBUser?
    
    var firstName: String = ""
    var lastName: String = ""
    var fullName: String = ""
    var collegeName: String = ""
    var collegeState: String = ""
    var fullCollegeName: String = ""
    
    var isLoading: Bool = false
    
    func getAuthenticatedUser() {
        if !self.isLoading {
            Task {
                self.isLoading = true
                
                do {
                    let authDataResult = await AuthenticationManager.shared.getAuthenticatedUser()
                    
                    self.user = try await UserManager.shared.getUser()
                    
                    setProperties()
                } catch {
                    logger.log("Error in fetching user: \(error)")
                }
                
                self.isLoading = false
            }
        }
    }
    
    func setProperties() {
        self.firstName = self.user?.firstName ?? ""
        self.lastName = self.user?.lastName ?? ""
        self.fullName = (self.user?.firstName ?? "") + " " + (self.user?.lastName ?? "")
        self.collegeName = self.user?.selectedCollege ?? ""
        self.collegeState = self.user?.selectedCollegeState ?? ""
        self.fullCollegeName = (self.user?.selectedCollege ?? "") + ", " + (self.user?.selectedCollegeState ?? "")
    }
    
    func updateName(firstName: String, lastName: String) async throws {
        try await UserManager.shared.updateUserDetails(
            firstName: firstName,
            lastName: lastName
        )
        
        self.getAuthenticatedUser()
    }

    func updateCollege(collegeStateName: String, collegeName: String) async throws {
        try await UserManager.shared.updateUserDetails(
            selectedCollegeState: collegeStateName,
            selectedCollege: collegeName
        )
        
        self.getAuthenticatedUser()
    }
    
    func clearAllFields() {
        self.user = nil
        self.firstName = ""
        self.lastName = ""
        self.fullName = ""
        self.collegeName = ""
        self.collegeState = ""
        self.fullCollegeName = ""
    }
}
