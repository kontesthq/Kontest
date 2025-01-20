//
//  UserManager.swift
//  Kontest
//
//  Created by Ayush Singhal on 1/14/24.
//

import Foundation

actor UserManager {
    static var shared = UserManager()
    
    private init() {}
    
    func updateUserDetails(
        firstName: String? = nil,
        lastName: String? = nil,
        selectedCollegeState: String? = nil,
        selectedCollege: String? = nil,
        leetcodeUsername: String? = nil,
        codeForcesUsername: String? = nil,
        codeChefUsername: String? = nil
    ) async throws {
        // Retrieve JWT token
        guard let jwtToken = await AuthenticationManager.shared.getJWTToken() else {
            throw AppError(title: "Authentication Error", description: "Unable to retrieve JWT token.")
        }
        
        // Construct the URL
        let url = URL(string: Constants.Endpoints.userServiceURL)!.appendingPathComponent("user_info")
        
        // Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT" // Assuming you are using PUT method to update user details
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(jwtToken)", forHTTPHeaderField: "Authorization")
        
        // Prepare the request body
        var body: [String: Any] = [:]
        
        if let firstName = firstName {
            body["first_name"] = firstName
        }
        if let lastName = lastName {
            body["last_name"] = lastName
        }
        if let selectedCollegeState = selectedCollegeState {
            body["college_state"] = selectedCollegeState
        }
        if let selectedCollege = selectedCollege {
            body["college_name"] = selectedCollege
        }
        if let leetcodeUsername = leetcodeUsername {
            body["leetcode_username"] = leetcodeUsername
        }
        if let codeForcesUsername = codeForcesUsername {
            body["codeforces_username"] = codeForcesUsername
        }
        if let codeChefUsername = codeChefUsername {
            body["codechef_username"] = codeChefUsername
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        // Perform the network request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Ensure the response is successful
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Handle the response if needed
        // For example, decode the response if there's any data to process
        let responseData = String(data: data, encoding: .utf8)
        print("User details updated successfully. Response: \(responseData ?? "No response data")")
    }
    
    func getUser() async throws -> DBUser {
        guard let jwtToken = await AuthenticationManager.shared.getJWTToken() else { throw AppError(title: "JWT Token is missing", description: "JWT Token is missing") }
        
        guard let authenticatedUser = await AuthenticationManager.shared.getAuthenticatedUser() else {
            throw AppError(title: "Authenticated user is missing", description: "Authenticated user is missing")
        }
        
        let url = URL(string: Constants.Endpoints.userServiceURL)!.appending(components: "user_info")
        
        // Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("\(jwtToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS" // For microseconds
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Use POSIX locale for fixed date format
        dateFormatter.timeZone = TimeZone(abbreviation: "IST")
        
        // Ensure that the createdAt string is parsed correctly into a Date object
        if let dateCreatedString = decodedData["createdAt"] as? String {
            print("dateCreatedString: \(dateCreatedString)")
            
            if let dateCreated = dateFormatter.date(from: dateCreatedString) {
                // Create the DBUser object
                return DBUser(
                    firstName: decodedData["firstName"] as! String,
                    lastName: decodedData["lastName"] as! String,
                    email: authenticatedUser.email,
                    selectedCollegeState: decodedData["college_state"] as! String,
                    selectedCollege: decodedData["college_name"] as! String,
                    leetcodeUsername: decodedData["leetcodeUsername"] as! String,
                    codeForcesUsername: decodedData["codeforcesUsername"] as! String,
                    codeChefUsername: decodedData["codechefUsername"] as! String,
                    dateCreated: dateCreated // Use the parsed date here
                )
            } else {
                throw AppError(title: "Date Parsing Error", description: "Unable to parse the createdAt field.")
            }
        } else {
//            throw AppError(title: "Invalid Data", description: "createdAt field is missing.")
            return DBUser(
                firstName: decodedData["first_name"] as! String,
                lastName: decodedData["last_name"] as! String,
                email: decodedData["email"] as! String,
                selectedCollegeState: decodedData["college_state"] as! String,
                selectedCollege: decodedData["college_name"] as! String,
                leetcodeUsername: decodedData["leetcode_username"] as! String,
                codeForcesUsername: decodedData["codeforces_username"] as! String,
                codeChefUsername: decodedData["codechef_username"] as! String,
                dateCreated: .now
            )
        }
    }
}

struct DBUser: Codable {
    let firstName, lastName, email, selectedCollegeState, selectedCollege, leetcodeUsername, codeForcesUsername, codeChefUsername: String
    let dateCreated: Date
    
    init(firstName: String, lastName: String, email: String, selectedCollegeState: String, selectedCollege: String, leetcodeUsername: String, codeForcesUsername: String, codeChefUsername: String, dateCreated: Date) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.selectedCollegeState = selectedCollegeState
        self.selectedCollege = selectedCollege
        self.leetcodeUsername = leetcodeUsername
        self.codeForcesUsername = codeForcesUsername
        self.codeChefUsername = codeChefUsername
        self.dateCreated = dateCreated
    }
    
    static let temp = DBUser(
        firstName: "",
        lastName: "",
        email: "",
        selectedCollegeState: "",
        selectedCollege: "",
        leetcodeUsername: "",
        codeForcesUsername: "",
        codeChefUsername: "",
        dateCreated: .now
    )
}
