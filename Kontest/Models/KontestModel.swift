//
//  KontestModel.swift
//  Kontest
//
//  Created by Ayush Singhal on 14/08/23.
//

import CryptoKit
import EventKit
import SwiftUI

@Observable
class KontestModel: Codable, Identifiable, Hashable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case url
        case start_time
        case end_time
        case duration
        case site
        case siteAbbreviation
        case in_24_hours
        case status
        case isSetForReminder10MiutesBefore
        case isSetForReminder30MiutesBefore
        case isSetForReminder1HourBefore
        case isSetForReminder6HoursBefore
        case logo
        case isCalendarEventAdded
        case calendarDate
        case selectedCalendarAccount
        case selectedCalendarName
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? "No ID"
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "No Name"
        url = try container.decodeIfPresent(String.self, forKey: .url) ?? "No URL"
        start_time = try container.decodeIfPresent(String.self, forKey: .start_time) ?? "No Start Time"
        end_time = try container.decodeIfPresent(String.self, forKey: .end_time) ?? "No End Time"
        duration = try container.decodeIfPresent(String.self, forKey: .duration) ?? "-1"
        site = try container.decodeIfPresent(String.self, forKey: .site) ?? "No Site"
        siteAbbreviation = try container.decodeIfPresent(String.self, forKey: .siteAbbreviation) ?? "No Site"
        in_24_hours = try container.decodeIfPresent(String.self, forKey: .in_24_hours) ?? "N/A"
        status = try container.decodeIfPresent(KontestStatus.self, forKey: .status) ?? KontestStatus.OnGoing
        isSetForReminder10MiutesBefore = try container.decodeIfPresent(Bool.self, forKey: .isSetForReminder10MiutesBefore) ?? false
        isSetForReminder30MiutesBefore = try container.decodeIfPresent(Bool.self, forKey: .isSetForReminder30MiutesBefore) ?? false
        isSetForReminder1HourBefore = try container.decodeIfPresent(Bool.self, forKey: .isSetForReminder1HourBefore) ?? false
        isSetForReminder6HoursBefore = try container.decodeIfPresent(Bool.self, forKey: .isSetForReminder6HoursBefore) ?? false
        logo = try container.decodeIfPresent(String.self, forKey: .logo) ?? "No Logo"
        isCalendarEventAdded = try container.decodeIfPresent(Bool.self, forKey: .isCalendarEventAdded) ?? false
        calendarEventDate = try container.decodeIfPresent(Date.self, forKey: .calendarDate)
        selectedCalendarAccount = try container.decodeIfPresent(String.self, forKey: .selectedCalendarAccount)
        selectedCalendarName = try container.decodeIfPresent(String.self, forKey: .selectedCalendarName)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(start_time, forKey: .start_time)
        try container.encode(end_time, forKey: .end_time)
        try container.encode(duration, forKey: .duration)
        try container.encode(site, forKey: .site)
        try container.encode(siteAbbreviation, forKey: .siteAbbreviation)
        try container.encode(in_24_hours, forKey: .in_24_hours)
        try container.encode(status, forKey: .status)
        try container.encode(calendarEventDate, forKey: .calendarDate)
        try container.encode(selectedCalendarAccount, forKey: .selectedCalendarAccount)
        try container.encode(selectedCalendarName, forKey: .selectedCalendarName)
    }
    
    let id: String
    let name: String
    let url: String
    let start_time, end_time, duration, site, in_24_hours: String
    var siteAbbreviation: String
    var status: KontestStatus
    var isSetForReminder10MiutesBefore: Bool
    var isSetForReminder30MiutesBefore: Bool
    var isSetForReminder1HourBefore: Bool
    var isSetForReminder6HoursBefore: Bool
    let logo: String
    var isCalendarEventAdded: Bool
    var calendarEventDate: Date?
    var selectedCalendarAccount: String?
    var selectedCalendarName: String?
    
    init(id: String, name: String, url: String, start_time: String, end_time: String, duration: String, site: String, in_24_hours: String, status: KontestStatus, logo: String) {
        self.id = id
        self.name = name
        self.url = url
        self.start_time = start_time
        self.end_time = end_time
        self.duration = duration
        self.site = site
        siteAbbreviation = KontestModel.getSiteAbbreviationFromSite(site: site)
        self.in_24_hours = in_24_hours
        self.status = status
        isSetForReminder10MiutesBefore = false
        isSetForReminder30MiutesBefore = false
        isSetForReminder1HourBefore = false
        isSetForReminder6HoursBefore = false
        self.logo = logo
        isCalendarEventAdded = false
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension KontestModel: Equatable {
    static func == (lhs: KontestModel, rhs: KontestModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension KontestModel {
    static func getSiteAbbreviationFromSite(site: String) -> String {
        switch site {
        case "atcoder.jp":
            Constants.SiteAbbreviations.AtCoder.rawValue
            
        case "codechef.com":
            Constants.SiteAbbreviations.CodeChef.rawValue
            
        case "codeforces.com":
            Constants.SiteAbbreviations.CodeForces.rawValue
            
        case "codingninjas.com":
            Constants.SiteAbbreviations.CodingNinjas.rawValue
            
        case "codingninjas.com/codestudio":
            Constants.SiteAbbreviations.CodingNinjas.rawValue
            
        case "csacademy.com":
            Constants.SiteAbbreviations.CSAcademy.rawValue
            
        case "geeksforgeeks.org":
            Constants.SiteAbbreviations.GeeksForGeeks.rawValue
            
        case "hackerearth.com":
            Constants.SiteAbbreviations.HackerEarth.rawValue
            
        case "hackerrank.com":
            Constants.SiteAbbreviations.HackerRank.rawValue
            
        case "leetcode.com":
            Constants.SiteAbbreviations.LeetCode.rawValue
            
        case "projecteuler.net":
            Constants.SiteAbbreviations.ProjectEuler.rawValue
            
        case "topcoder.com":
            Constants.SiteAbbreviations.TopCoder.rawValue
            
        case "toph.com":
            Constants.SiteAbbreviations.Toph.rawValue
            
        case "toph.co":
            Constants.SiteAbbreviations.Toph.rawValue
            
        case "yukicoder.me":
            Constants.SiteAbbreviations.YukiCoder.rawValue
            
        case "cups.online":
            Constants.SiteAbbreviations.CupsOnline.rawValue
            
        case "robocontest.uz":
            Constants.SiteAbbreviations.RoboContext.rawValue
            
        case "ctftime.org":
            Constants.SiteAbbreviations.Ctftime.rawValue
            
        case "lightoj.com":
            Constants.SiteAbbreviations.Lightoj.rawValue
            
        case "ucup.ac":
            Constants.SiteAbbreviations.UCup.rawValue
            
        case "kaggle.com":
            Constants.SiteAbbreviations.Kaggle.rawValue
            
        case "dmoj.ca":
            Constants.SiteAbbreviations.DMOJ.rawValue
            
        case "tlx.toki.id":
            Constants.SiteAbbreviations.TLX.rawValue
            
        case "coderun.yandex.ru":
            Constants.SiteAbbreviations.CodeRun.rawValue
            
        case "eolymp.com":
            Constants.SiteAbbreviations.Eolymp.rawValue
            
        case "icpc.global":
            Constants.SiteAbbreviations.ICPCGlobal.rawValue
            
        case "luogu.com.cn":
            Constants.SiteAbbreviations.Luogu.rawValue
            
        case "spoj.com":
            Constants.SiteAbbreviations.Spoj.rawValue
            
        case "dl.gsu.by":
            Constants.SiteAbbreviations.GSU.rawValue
            
        default:
            site
        }
    }
    
    static func from(dto: KontestDTO) -> KontestModel {
        let id = generateUniqueID(dto: dto)
        
        let kontestStartDate = CalendarUtility.getDate(date: dto.startTime)
        let kontestEndDate = CalendarUtility.getDate(date: dto.endTime)
        
        var status: KontestStatus {
            return getKontestStatus(kontestStartDate: kontestStartDate ?? Date(), kontestEndDate: kontestEndDate ?? Date())
        }
        
        let duration = (kontestEndDate?.timeIntervalSince1970 ?? 0) - (kontestStartDate?.timeIntervalSince1970 ?? 0)
        
        return KontestModel(
            id: id,
            name: dto.name,
            url: dto.url,
            start_time: dto.startTime,
            end_time: dto.endTime,
            duration: "\(duration)",
            site: dto.site,
            in_24_hours: dto.in_24_hours,
            status: status,
            logo: getLogo(siteAbbreviation: dto.site)
        )
    }
    
    public static func generateUniqueID(dto: KontestDTO) -> String {
        if let startTime = CalendarUtility.getDate(date: dto.startTime), let endTime = CalendarUtility.getDate(date: dto.endTime) {
            return generateUniqueID(name: dto.name, url: dto.url, startTime: startTime, endTime: endTime, site: dto.site)
        }
        
        return ""
    }
    
    public static func generateUniqueID(kontestModel: KontestModel) -> String {
        if let startTime = CalendarUtility.getDate(date: kontestModel.start_time), let endTime = CalendarUtility.getDate(date: kontestModel.end_time) {
            return generateUniqueID(name: kontestModel.name, url: kontestModel.url, startTime: startTime, endTime: endTime, site: kontestModel.site)
        }
        
        return ""
    }
    
    public static func generateUniqueID(name: String, url: String, startTime: Date, endTime: Date, site: String) -> String {
        let combinedString = "\(name)\(url)\(startTime)\(endTime)\(site)"
        
        if let data = combinedString.data(using: .utf8) {
            let hash = SHA256.hash(data: data)
            return hash.compactMap { String(format: "%02x", $0) }.joined()
        } else {
            return UUID().uuidString
        }
    }
    
    static func getColorForIdentifier(siteAbbreviation: String, colorScheme: ColorScheme = .light) -> Color {
        switch siteAbbreviation {
        case Constants.SiteAbbreviations.AtCoder.rawValue:
            Color(red: 187/255, green: 181/255, blue: 181/255)
            
        case Constants.SiteAbbreviations.CodeChef.rawValue:
            Color(red: 250/255, green: 155/255, blue: 101/255)
            
        case Constants.SiteAbbreviations.CodeForces.rawValue:
                .pink
            
        case Constants.SiteAbbreviations.CodeForcesGym.rawValue:
                .red
            
        case Constants.SiteAbbreviations.CodingNinjas.rawValue:
                .orange
            
        case Constants.SiteAbbreviations.CSAcademy.rawValue:
                .red
            
        case Constants.SiteAbbreviations.GeeksForGeeks.rawValue:
                .green
            
        case Constants.SiteAbbreviations.HackerEarth.rawValue:
            Color(red: 101/255, green: 125/255, blue: 251/255)
            
        case Constants.SiteAbbreviations.HackerRank.rawValue:
                .green
            
        case Constants.SiteAbbreviations.LeetCode.rawValue:
            Color(red: 235/255, green: 162/255, blue: 64/255)
            
        case Constants.SiteAbbreviations.ProjectEuler.rawValue:
            Color(red: 178/255, green: 128/255, blue: 100/255)
            
        case Constants.SiteAbbreviations.TopCoder.rawValue:
            if colorScheme == .light {
                .black
            } else {
                .white
            }
            
        case Constants.SiteAbbreviations.Toph.rawValue:
                .blue
            
        case Constants.SiteAbbreviations.YukiCoder.rawValue:
            Color(red: 60/255, green: 66/255, blue: 79/255)
            
        case Constants.SiteAbbreviations.CupsOnline.rawValue:
                .blue
            
        default:
                .red
        }
    }
    
    static func getLogo(siteAbbreviation: String, colorScheme: ColorScheme = .light) -> String {
        return switch siteAbbreviation {
        case Constants.SiteAbbreviations.AtCoder.rawValue:
            "AtCoder Logo"
            
        case Constants.SiteAbbreviations.CodeChef.rawValue:
            "CodeChef Logo"
            
        case Constants.SiteAbbreviations.CodeForces.rawValue:
            "CodeForces Logo"
            
        case Constants.SiteAbbreviations.CodeForcesGym.rawValue:
            "CodeForces Logo"
            
        case Constants.SiteAbbreviations.CodingNinjas.rawValue:
            "Coding Ninjas Logo"
            
        case Constants.SiteAbbreviations.CSAcademy.rawValue:
            "CSAcademy Logo"
            
        case Constants.SiteAbbreviations.GeeksForGeeks.rawValue:
            "Geeks For Geeks Logo"
            
        case Constants.SiteAbbreviations.HackerEarth.rawValue:
            "HackerEarth Logo"
            
        case Constants.SiteAbbreviations.HackerRank.rawValue:
            "HackerRank Logo"
            
        case Constants.SiteAbbreviations.LeetCode.rawValue:
            if colorScheme == .light {
                "LeetCode Light Logo"
            } else if colorScheme == .dark {
                "LeetCode Dark Logo"
            } else {
                ""
            }
            
        case Constants.SiteAbbreviations.ProjectEuler.rawValue:
            "Project Euler Logo"
            
        case Constants.SiteAbbreviations.TopCoder.rawValue:
            if colorScheme == .light {
                "TopCoder Light Logo"
            } else if colorScheme == .dark {
                "TopCoder Dark Logo"
            } else { "" }
            
        case Constants.SiteAbbreviations.Toph.rawValue:
            "Toph Logo"
            
        case Constants.SiteAbbreviations.YukiCoder.rawValue:
            "Yuki Coder Logo"
            
        case Constants.SiteAbbreviations.CupsOnline.rawValue:
            "Cups.online Logo"
            
        default:
            "Placeholder Flag"
        }
    }
    
    // Save reminder status to UserDefaults
    func saveReminderStatus(minutesBefore: Int, hoursBefore: Int, daysBefore: Int) {
        let userDefaultsID = LocalNotificationManager.instance.getNotificationID(kontestID: id, minutesBefore: minutesBefore, hoursBefore: hoursBefore, daysBefore: daysBefore)
        
        if minutesBefore == 10 {
            UserDefaults(suiteName: Constants.userDefaultsGroupID)!.set(isSetForReminder10MiutesBefore, forKey: userDefaultsID)
        } else if minutesBefore == 30 {
            UserDefaults(suiteName: Constants.userDefaultsGroupID)!.set(isSetForReminder30MiutesBefore, forKey: userDefaultsID)
        } else if hoursBefore == 1 {
            UserDefaults(suiteName: Constants.userDefaultsGroupID)!.set(isSetForReminder1HourBefore, forKey: userDefaultsID)
        } else {
            UserDefaults(suiteName: Constants.userDefaultsGroupID)!.set(isSetForReminder6HoursBefore, forKey: userDefaultsID)
        }
    }
    
    // Load reminder status from UserDefaults
    func loadReminderStatus() {
        var userDefaultsID = LocalNotificationManager.instance.getNotificationID(kontestID: id, minutesBefore: 10, hoursBefore: 0, daysBefore: 0)
        isSetForReminder10MiutesBefore = UserDefaults(suiteName: Constants.userDefaultsGroupID)!.bool(forKey: userDefaultsID)
        
        userDefaultsID = LocalNotificationManager.instance.getNotificationID(kontestID: id, minutesBefore: 30, hoursBefore: 0, daysBefore: 0)
        isSetForReminder30MiutesBefore = UserDefaults(suiteName: Constants.userDefaultsGroupID)!.bool(forKey: userDefaultsID)
        
        userDefaultsID = LocalNotificationManager.instance.getNotificationID(kontestID: id, minutesBefore: 0, hoursBefore: 1, daysBefore: 0)
        isSetForReminder1HourBefore = UserDefaults(suiteName: Constants.userDefaultsGroupID)!.bool(forKey: userDefaultsID)
        
        userDefaultsID = LocalNotificationManager.instance.getNotificationID(kontestID: id, minutesBefore: 0, hoursBefore: 6, daysBefore: 0)
        isSetForReminder6HoursBefore = UserDefaults(suiteName: Constants.userDefaultsGroupID)!.bool(forKey: userDefaultsID)
    }
    
    func removeReminderStatusFromUserDefaults() {
        UserDefaults(suiteName: Constants.userDefaultsGroupID)!.removeObject(forKey: id)
    }
    
    static func getKontestStatus(kontestStartDate: Date, kontestEndDate: Date) -> KontestStatus {
        if CalendarUtility.isKontestRunning(kontestStartDate: kontestStartDate, kontestEndDate: kontestEndDate) {
            .OnGoing
        } else if CalendarUtility.isKontestLaterToday(kontestStartDate: kontestStartDate) {
            .LaterToday
        } else if CalendarUtility.isKontestTomorrow(kontestStartDate: kontestStartDate) {
            .Tomorrow
        } else {
            .Later
        }
    }
    
    /// loads the calendar status of an event
    func loadCalendarStatus(allEvents: [EKEvent]) {
        let p = CalendarUtility.isEventPresentInCalendar(allEventsOfCalendar: allEvents, startDate: CalendarUtility.getDate(date: start_time) ?? Date(), endDate: CalendarUtility.getDate(date: end_time) ?? Date(), title: name, url: URL(string: url))
        
        isCalendarEventAdded = p
    }
    
    /// loads the date of first time notification of an event
    func loadCalendarEventDate(allEvents: [EKEvent]) {
        calendarEventDate = CalendarUtility.getCalendarDateOfEvent(allEventsOfCalendar: allEvents, startDate: CalendarUtility.getDate(date: start_time) ?? Date(), endDate: CalendarUtility.getDate(date: end_time) ?? Date(), title: name, url: URL(string: url))
    }
    
    /// loads the calendar name and account name of an event
    func loadEventCalendar(allEvents: [EKEvent]) {
        selectedCalendarAccount = CalendarUtility.getCalendarAccountNameOfAnEvent(allEventsOfCalendar: allEvents, startDate: CalendarUtility.getDate(date: start_time) ?? Date(), endDate: CalendarUtility.getDate(date: end_time) ?? Date(), title: name, url: URL(string: url))
        
        selectedCalendarName = CalendarUtility.getCalendarNameOfAnEvent(allEventsOfCalendar: allEvents, startDate: CalendarUtility.getDate(date: start_time) ?? Date(), endDate: CalendarUtility.getDate(date: end_time) ?? Date(), title: name, url: URL(string: url))
    }
    
    static var example: KontestModel {
        KontestModel.from(dto: KontestDTO(name: "ProjectEuler+1", url: "https://hackerrank.com/contests/projecteuler", startTime: "2023-08-15 18:29:00 UTC", endTime: "2023-08-18 17:43:00 UTC", duration: "1020.0", site: "HackerRank", in_24_hours: "No", status: "BEFORE"))
    }
}
