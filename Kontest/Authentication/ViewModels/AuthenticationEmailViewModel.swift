//
//  AuthenticationEmailViewModel.swift
//  Kontest
//
//  Created by Ayush Singhal on 1/14/24.
//

import FirebaseAuth
import Foundation
import OSLog

@Observable
final class AuthenticationEmailViewModel: Sendable {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "AuthenticationEmailViewModel")

    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var selectedState: String = "Andhra Pradesh"
    var selectedCollege: String = ""

    var isLoading: Bool = false

    var error: (any Error)?

    static let shared = AuthenticationEmailViewModel()

    private init() {}

    func signIn() async -> Bool {
        if email.isEmpty {
            error = AppError(title: "Email cannot be empty.", description: "")
            logger.log("Email is empty.")
            return false
        }

        if password.isEmpty {
            error = AppError(title: "Password cannot be empty.", description: "")
            logger.log("Password is empty.")
            return false
        }

        self.isLoading = true

        do {
            let returnedUserData = try await AuthenticationManager.shared.signIn(email: email, password: password)

            logger.log("Success in logging in with email - password")
            logger.log("returnedUserData: \("\(returnedUserData)")")

            let uid = returnedUserData.email

            try await setDownloadedUsernamesAsLocalUsernames(userId: uid)

            self.isLoading = false
            return true

        } catch {
            let nsError = error as NSError

            if nsError.domain == "FIRAuthErrorDomain" { // checks if error is related to FirebaseAuth
//                let errorCodeName = nsError.userInfo[AuthErrorUserInfoNameKey] as? String
                let errorCode = AuthErrorCode(_nsError: nsError)

//                if errorCodeName == "ERROR_INVALID_CREDENTIAL" {
//                    self.error = AppError(title: "Password is wrong", description: "") // Gives (this) same errorCodeName in atlease these situations ---> Wrong password, Account not present
//                } else {
                switch errorCode {
                case AuthErrorCode.wrongPassword:
                    self.error = AppError(title: "Your provided password is wrong.", description: "")

                case AuthErrorCode.userDisabled:
                    self.error = AppError(title: "Your Account has been disabled.", description: "Contact Support - ayushsinghals02@gmail.com")

                case AuthErrorCode.tooManyRequests:
                    self.error = AppError(title: "Your Account has been temporarily disabled due to multiple wrong attempts.", description: "Contact Support - ayushsinghals02@gmail.com")

                case AuthErrorCode.userNotFound:
                    self.error = AppError(title: "You don't have an account, please Sign up instead!", description: "")

                default:
                    logger.error("\(error)")
                    self.error = error
                }
//                }
            } else {
                logger.error("\(error)")
                self.error = error
            }

            logger.error("Error in siging in with email - password: \(error)")

            self.isLoading = false
            return false
        }
    }

    func signUp() async -> Bool {
        isLoading = true

        guard !email.isEmpty,!password.isEmpty else {
            error = AppError(title: "Email or Password is Empty", description: "")
            logger.error("No email or password found.")
            return false
        }

        do {
            let returnedUserData = try await AuthenticationManager.shared.createNewUser(email: email, password: password)
            logger.log("Success in signing up with email - password")
            logger.log("returnedUserData: \("\(returnedUserData)")")

            self.isLoading = false

            try await UserManager.shared.updateUserDetails(
                firstName: self.firstName,
                lastName: self.lastName,
                selectedCollegeState: self.selectedState,
                selectedCollege: self.selectedCollege,
                leetcodeUsername: Dependencies.instance.changeUsernameViewModel.leetcodeUsername,
                codeForcesUsername: Dependencies.instance.changeUsernameViewModel.codeForcesUsername,
                codeChefUsername: Dependencies.instance.changeUsernameViewModel.codeChefUsername
            )

            return true
        } catch {
            let nsError = error as NSError

            if nsError.domain == "FIRAuthErrorDomain" { // checks if error is related to FirebaseAuth
                let errorCode = AuthErrorCode(_nsError: nsError)

                switch errorCode {
                case AuthErrorCode.userDisabled:
                    self.error = AppError(title: "Your Account has been disabled.", description: "Contact Support - ayushsinghals02@gmail.com")

                case AuthErrorCode.tooManyRequests:
                    self.error = AppError(title: "Your Account has been temporarily disabled due to multiple wrong attempts.", description: "Contact Support - ayushsinghals02@gmail.com")

                case AuthErrorCode.invalidEmail:
                    self.error = AppError(title: "Email is in invalid format.", description: "Please provide a valid email address.")

                case AuthErrorCode.emailAlreadyInUse:
                    self.error = AppError(title: "Email is already in use.", description: "Please use a different email address or sign in.")

                case AuthErrorCode.weakPassword:
                    self.error = AppError(title: "Password is weak.", description: "Your password must be at least 6 characters long.")

                case AuthErrorCode.operationNotAllowed:
                    self.error = AppError(title: "Signup is currently Not Allowed.", description: "Email/password signup is disabled for these credentials.")

                default:
                    logger.error("\(error)")
                    self.error = error
                }
            } else {
                logger.error("\(error)")
                self.error = error
            }

            logger.error("Error in siging up with email - password: \(error)")

            self.isLoading = false
            return false
        }
    }

    func clearAllFields() {
        self.email = ""
        self.password = ""
        self.confirmPassword = ""
        self.firstName = ""
        self.lastName = ""
        self.isLoading = false
        self.error = nil
    }

    func clearPasswordFields() {
        self.password = ""
        self.confirmPassword = ""
        self.isLoading = false
        self.error = nil
    }

    func setDownloadedUsernamesAsLocalUsernames(userId: String) async throws {
        let data = try await UserManager.shared.getUser()

        let changeUsernameViewModel: ChangeUsernameViewModel = Dependencies.instance.changeUsernameViewModel
        changeUsernameViewModel.setLeetcodeUsername(newLeetcodeUsername: data.leetcodeUsername == "" ? changeUsernameViewModel.leetcodeUsername : data.leetcodeUsername)
        changeUsernameViewModel.setCodeChefUsername(newCodeChefUsername: data.codeChefUsername == "" ? changeUsernameViewModel.codeChefUsername : data.codeChefUsername)
        changeUsernameViewModel.setCodeForcesUsername(newCodeForcesUsername: data.codeForcesUsername == "" ? changeUsernameViewModel.codeForcesUsername : data.codeForcesUsername)
    }

    func setNewPassword() async {
        if password.isEmpty {
            self.error = AppError(title: "Password cannot be empty", description: "Password cannot be empty")
            return
        }
        
        if password != confirmPassword {
            self.error = AppError(title: "Passwords do not match", description: "Passwords do not match")
            return
        }

        if !checkIfPasswordIsCorrect(password: password) {
            self.error = AppError(title: "Password is not strong enough", description: "Password is not strong enough")
            return
        }

        do {
            try await AuthenticationManager.shared.changePassword(newPassword: password)
        } catch {
            self.error = error
        }
    }
}

func checkIfEmailIsCorrect(emailAddress: String) -> Bool {
    let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: emailAddress)
}

func checkIfPasswordIsCorrect(password: String) -> Bool {
    // Check if the password is at least 8 characters long
    guard password.count >= 8 else {
        return false
    }

    // Check if the password contains at least one uppercase letter
    let uppercaseLetterRegex = ".*[A-Z]+.*"
    let uppercaseLetterTest = NSPredicate(format: "SELF MATCHES %@", uppercaseLetterRegex)
    guard uppercaseLetterTest.evaluate(with: password) else {
        return false
    }

    // Check if the password contains at least one lowercase letter
    let lowercaseLetterRegex = ".*[a-z]+.*"
    let lowercaseLetterTest = NSPredicate(format: "SELF MATCHES %@", lowercaseLetterRegex)
    guard lowercaseLetterTest.evaluate(with: password) else {
        return false
    }

    // Check if the password contains at least one digit (number)
    let digitRegex = ".*[0-9]+.*"
    let digitTest = NSPredicate(format: "SELF MATCHES %@", digitRegex)
    guard digitTest.evaluate(with: password) else {
        return false
    }

    // All requirements are met
    return true
}
