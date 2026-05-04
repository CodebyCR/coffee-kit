//
//  JWTValidator.swift
//  AuhenticationTest
//
//  Created by Christoph Rohde on 21.03.26.
//

import Foundation

// MARK: - JWT Error
public enum JWTError: Error {
    case invalidFormat
    case invalidBase64
    case decodingFailed
}

// MARK: - The Payload
/// We only extract the field we actually need.
private struct JWTPayload: Decodable {
    let exp: TimeInterval
}

// MARK: - The Decoder Service
public struct JWTValidator: Sendable {
    
    /// Checks if a JWT is expired (including a safety buffer)
    public static func isExpired(token: String) throws(JWTError) -> Bool {
        let parts = token.components(separatedBy: ".")
        
        // A valid JWT has exactly 3 parts
        guard parts.count == 3 else {
            throw .invalidFormat
        }
        
        let payloadBase64URL = parts[1]
        
        // 1. Convert Base64URL to normal Base64
        var base64 = payloadBase64URL
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // 2. Fill Base64 padding (with "=") if necessary, as Apple's decoder would otherwise crash
        let paddingLength = 4 - (base64.count % 4)
        if paddingLength < 4 {
            base64 += String(repeating: "=", count: paddingLength)
        }
        
        guard let payloadData = Data(base64Encoded: base64) else {
            throw .invalidBase64
        }
        
        // 3. Decode JSON
        do {
            let payload = try JSONDecoder().decode(JWTPayload.self, from: payloadData)
            let expirationDate = Date(timeIntervalSince1970: payload.exp)
            
            // ARCHITECTURE TIP: We subtract a 60-second buffer here!
            // Why? If the token expires in 2 seconds and the API request
            // takes 3 seconds, it will fail on the server.
            // With the buffer, we prefer to renew it a bit earlier.
            let safeExpirationDate = expirationDate.addingTimeInterval(-60)
            
            return Date.now >= safeExpirationDate
            
        } catch {
            throw .decodingFailed
        }
    }
}
