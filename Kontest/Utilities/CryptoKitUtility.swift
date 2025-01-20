//
//  CryptoKitUtility.swift
//  Kontest
//
//  Created by Ayush Singhal on 9/20/24.
//

import Foundation
import CryptoKit

class CryptoKitUtility {
    public static func sha512(for input: String) -> String {
        // Convert the input string to data
        let inputData = Data(input.utf8)
        
        // Generate SHA-256 hash
        let hashed = SHA512.hash(data: inputData)
        
        // Convert the hash to a hexadecimal string
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
