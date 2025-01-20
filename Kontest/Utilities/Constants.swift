//
//  Constants.swift
//  Kontest
//
//  Created by Ayush Singhal on 15/08/23.
//

import Foundation

enum Constants {
    static let minutesToBeReminderBefore = 10
    static let maximumDurationOfAKontestInMinutes = 12 * 60
    static let minimumDurationOfAKontestInMinutes = 0
    #if os(macOS)
        static let userDefaultsGroupID = "QU6F7R6MZS.com.ayush.kontest"
    #else
        static let userDefaultsGroupID = "group.com.ayush.kontest"
    #endif
    static let keychainAuthTokensServiceName = "com.ayush.kontest.authenticationTokens"
    
    static let codeforcesNotAvailableErrorResponseMessage = "Codeforces is temporarily unavailable"
    
    static let maximumDurationOfAKontestInMinutesKey = "maximumDurationOfAKontestInMinutesKey"
    static let minimumDurationOfAKontestInMinutesKey = "minimumDurationOfAKontestInMinutesKey"
    
    static let minimumLimitOfMinutesOfKontest = 0
    static let maximumLimitOfMinutesOfKontest = 12 * 60
    
    static let states: [String] = ["Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh", "Dehradun", "Delhi", "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jammu and Kashmir", "Jharkhand", "Karnataka", "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Puducherry", "Punjab", "Punjab and Haryana", "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh", "Uttarakhand", "West Bengal"]
    
    enum SiteAbbreviations: String {
        case AtCoder
        case CodeChef
        case CodeForces
        case CodeForcesGym = "CodeForces::Gym"
        case CodingNinjas = "Coding Ninjas"
        case CSAcademy = "CS Academy"
        case GeeksForGeeks = "Geeks For Geeks"
        case HackerEarth
        case HackerRank
        case LeetCode
        case ProjectEuler = "Project Euler"
        case TopCoder
        case Toph
        case YukiCoder = "Yuki Coder"
        case CupsOnline = "Cups Online"
        
        case RoboContext = "Robo Contest"
        case Ctftime = "CTFtime"
        case Lightoj = "Light OJ"
        case UCup
        case Kaggle
        case DMOJ
        case TLX
        case CodeRun
        case Eolymp = "eOlymp"
        case ICPCGlobal
        case Luogu
        case Spoj = "SPOJ"
        case GSU
    }
    
    //    static let automaticNotificationSuffix = "automaticNotificationSuffix"
    static let automaticNotification10MinutesSuffix = "automaticNotification10MinutesSuffix"
    static let automaticNotification30MinutesSuffix = "automaticNotification30MinutesSuffix"
    static let automaticNotification1HourSuffix = "automaticNotification1HourSuffix"
    static let automaticNotification6HoursSuffix = "automaticNotification6HoursSuffix"
    
    static let automaticCalendarEventSuffix = "automaticReminderSuffix"
    
    static let mySiteBaseURL: String = "https://kontest-api.ayushsinghal.tech"
    
    enum Endpoints {
        private static let graphql = "/graphql"
        private static let kontests = "/kontest"
        private static let auth = "/auth"
        private static let userService = "/user"
        
        // Computed properties to return full URLs
        static var graphqlURL: String {
            return "\(mySiteBaseURL)\(graphql)"
        }
        
        static var kontestsURL: String {
            return "\(mySiteBaseURL)\(kontests)"
        }
        
        static var authenticationURL: String {
            return "\(mySiteBaseURL)\(auth)"
        }
        
        static var userServiceURL: String {
            return "\(mySiteBaseURL)\(userService)"
        }
    }
}
