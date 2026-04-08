
import Foundation

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    
    // Backward compatibility for existing code that uses .token
    var token: String { accessToken }
}
