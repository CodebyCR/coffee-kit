
import Foundation

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let id: UUID?
    let name: String?
    
    // Backward compatibility for existing code that uses .token
    var token: String { accessToken }
}
