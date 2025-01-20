//
//  JWTUtil.swift
//  Kontest
//
//  Created by Ayush Singhal on 9/18/24.
//

import Foundation

class JWTUtil {
    
    private static let accessTokenAccount = "accessToken"
    private static let refreshTokenAccount = "refreshToken"
    
    // MARK: - Storing JWT Tokens
    
    static func storeAccessToken(_ token: String) -> Bool {
        return KeychainHelper.storeData(data: token.data(using: .utf8)!, forService: Constants.keychainAuthTokensServiceName, account: accessTokenAccount)
    }
    
    static func storeRefreshToken(_ token: String) -> Bool {
        return KeychainHelper.storeData(data: token.data(using: .utf8)!, forService: Constants.keychainAuthTokensServiceName, account: refreshTokenAccount)
    }
    
    // MARK: - Retrieving JWT Tokens
    
    static func retrieveAccessToken() -> String? {
        return retrieveToken(forService: Constants.keychainAuthTokensServiceName, account: accessTokenAccount)
    }
    
    static func retrieveRefreshToken() -> String? {
        return retrieveToken(forService: Constants.keychainAuthTokensServiceName, account: refreshTokenAccount)
    }
    
    private static func retrieveToken(forService service: String, account: String) -> String? {
        if let data = KeychainHelper.retrieveData(forService: service, account: account) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    // MARK: - Deleting JWT Tokens
    
    static func deleteAccessToken() {
        KeychainHelper.deleteData(forService: Constants.keychainAuthTokensServiceName, account: accessTokenAccount)
    }
    
    static func deleteRefreshToken() {
        KeychainHelper.deleteData(forService: Constants.keychainAuthTokensServiceName, account: refreshTokenAccount)
    }
    
    // MARK: - JWT Decoding (Optional)
    
    static func decodeJWT(_ token: String) -> [String: Any]? {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return nil }
        
        let base64String = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let paddedBase64String = base64String.padding(toLength: ((base64String.count+3)/4)*4, withPad: "=", startingAt: 0)
        
        guard let data = Data(base64Encoded: paddedBase64String) else { return nil }
        
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    }
    
    // MARK: - JWT Validation
    
    static func isTokenExpired(_ token: String) -> Bool {
        guard let payload = decodeJWT(token), let exp = payload["exp"] as? TimeInterval else {
            return true
        }
        let expirationDate = Date(timeIntervalSince1970: exp)
        return expirationDate < Date()
    }
}
