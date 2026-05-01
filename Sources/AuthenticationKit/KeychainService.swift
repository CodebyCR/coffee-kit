//
//  KeychainService.swift
//  AuhenticationTest
//
//  Created by Christoph Rohde on 21.03.26.
//

import Foundation
import Security

public enum KeychainError: Error {
    case duplicateEntry
    case unknown(OSStatus)
    case itemNotFound
    case invalidData
}

public protocol KeychainService: Sendable {
    func save(_ data: Data, account: String, service: String) async throws(KeychainError)
    func read(account: String, service: String) async throws(KeychainError) -> Data
    func delete(account: String, service: String) async throws(KeychainError)
}

// MARK: - Slim, pragmatic actor
public actor DefaultKeychainManager: KeychainService {
    
    public init() {}
    
    public func save(_ data: Data, account: String, service: String) async throws(KeychainError) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data,
            // AccessibleAfterFirstUnlock is usually the best compromise between security and background capability
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw .unknown(status)
        }
    }
    
    public func read(account: String, service: String) async throws(KeychainError) -> Data {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw .invalidData
            }
            return data
        case errSecItemNotFound:
            throw .itemNotFound
        default:
            throw .unknown(status)
        }
    }
    
    public func delete(account: String, service: String) async throws(KeychainError) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw .unknown(status)
        }
    }
}
