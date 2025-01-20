//
//  KeychainHelper.swift
//  Kontest
//
//  Created by Ayush Singhal on 9/18/24.
//

import Foundation
import Security

class KeychainHelper {
    static func storeData(data: Data, forService service: String, account: String, shouldSynchronize: Bool = true) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrSynchronizable as String: shouldSynchronize ? kSecAttrSynchronizableAny : kCFBooleanFalse!
        ]
        
        // First try to delete any existing data for the same service/account
        SecItemDelete(query as CFDictionary)
        
        // Add new data to the Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // Retrieve data from the Keychain
    static func retrieveData(forService service: String, account: String, shouldSynchronize: Bool = true) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue as Any, // Request the data to be returned
            kSecMatchLimit as String: kSecMatchLimitOne, // Only match one item
            kSecAttrSynchronizable as String: shouldSynchronize ? kSecAttrSynchronizableAny : kCFBooleanFalse!
        ]
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        // Check if the retrieval was successful
        if status == errSecSuccess {
            return item as? Data
        } else {
            return nil
        }
    }
    
    static func deleteData(forService service: String, account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    static func getUniqueDeviceIdentifier() -> String {
        let account = "deviceIdentifier"
        
        if let data = retrieveData(forService: Constants.keychainAuthTokensServiceName, account: account, shouldSynchronize: false),
           let identifier = String(data: data, encoding: .utf8)
        {
            return identifier
        } else {
            let uniqueID = UUID().uuidString
            storeData(data: uniqueID.data(using: .utf8)!, forService: Constants.keychainAuthTokensServiceName, account: account, shouldSynchronize: false)
            return uniqueID
        }
    }
}
