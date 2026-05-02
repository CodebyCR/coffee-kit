import Foundation
import FoundationKit


public actor AutenticationManager: Authenticating {
    private let keychain: KeychainService
    
    private let account = "currentUser"
    private let accessTokenService = "CoffeeLover.AccessToken"
    private let refreshTokenService = "CoffeeLover.RefreshToken"
    private let userService = "CoffeeLover.User"
    
    private let baseURL: URL

    // ARCHITECTURE TRICK: Hier speichern wir den aktuell laufenden Refresh-Call
    private var refreshTask: Task<String, Error>?
    
    public init(keychain: KeychainService, baseURL: URL) {
        self.keychain = keychain
        self.baseURL = baseURL
    }
    
    public func getValidAccessToken() async throws -> String {
        // 1. Versuch: Aktuellen Token lesen
        guard let currentToken = try? await getLocalAccessToken() else {
            return try await refreshSession()
        }

        // JWT Validierung ohne try!
        do {
            let expired = try await JWTValidator.isExpired(token: currentToken)
            if !expired {
                return currentToken
            }
        } catch {
            print("⚠️ Token validation failed: \(error). Attempting refresh...")
        }
        
        return try await refreshSession()
    }

    /// Erzwingt einen Refresh des Access Tokens
    public func forceRefreshAccessToken() async throws -> String {
        return try await refreshSession()
    }
    
    public func storeTokens(accessToken: String, refreshToken: String?) async throws {
        do {
            try await keychain.save(Data(accessToken.utf8), account: account, service: accessTokenService)
            if let refreshToken = refreshToken {
                try await keychain.save(Data(refreshToken.utf8), account: account, service: refreshTokenService)
            }
        } catch {
            throw AuthenticationError.keychainError(error)
        }
    }

    public func storeUser(_ user: User) async throws {
        do {
            let userEncoder = JSONEncoder()
            let data = try userEncoder.encode(user)
            try await keychain.save(data, account: account, service: userService)
        } catch {
            throw AuthenticationError.keychainError(error as! KeychainError)
        }
    }

    /// Lädt den gespeicherten Benutzer
    public func restoreUser() async -> User? {
        do {
            let data = try await keychain.read(account: account, service: userService)
            let userDecoder = JSONDecoder()
            return try userDecoder.decode(User.self, from: data)
        } catch {
            print("ℹ️ No user data found in keychain.")
            return nil
        }
    }
    
    /// Löscht alle gespeicherten Tokens (Logout)
    public func logout() async {
        do {
            try await keychain.delete(account: account, service: accessTokenService)
            try await keychain.delete(account: account, service: refreshTokenService)
            try await keychain.delete(account: account, service: userService)
            print("👤 User logged out and tokens/data cleared.")
        } catch {
            print("⚠️ Error during logout: \(error)")
        }
    }

    // Hilfsfunktion zum lokalen Lesen
    private func getLocalAccessToken() async throws(AuthenticationError) -> String {
        do {
            let data = try await keychain.read(account: account, service: accessTokenService)
            return String(decoding: data, as: UTF8.self)
        } catch {
            throw .keychainError(error)
        }
    }
    
    public func authenticate(_ request: inout URLRequest) async {
        // Wenn kein Refresh-Token da ist, sind wir nicht eingeloggt
        // Wir werfen hier keinen Fehler, damit öffentliche Requests (z.B. Menü) funktionieren.
        do {
            _ = try await keychain.read(account: account, service: refreshTokenService)
        } catch {
            print("ℹ️ No session active (Keychain error: \(error)). Skipping authentication header for \(request.url?.absoluteString ?? "unknown URL").")
            return
        }
        
        do {
            let token = try await getValidAccessToken()
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("✅ Added Authorization header to \(request.url?.absoluteString ?? "unknown URL").")
        } catch {
            print("⚠️ Authentication failed for \(request.url?.absoluteString ?? "unknown URL"): \(error)")
        }
    }

    /// Holt einen neuen AccessToken, schützt aber vor parallelen Aufrufen!
    private func refreshSession() async throws -> String {
        
        if let existingTask = refreshTask {
            print("⏳ Refresh already in progress. Attaching to the existing task...")
            return try await existingTask.value
        }
        
        let task = Task<String, Error> {
            
            let refreshTokenData: Data
            do {
                refreshTokenData = try await keychain.read(account: account, service: refreshTokenService)
            } catch {
                throw AuthenticationError.sessionExpired
            }
            let refreshToken = String(decoding: refreshTokenData, as: UTF8.self)
            
            let url = baseURL.appendingPathComponent("refresh")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONEncoder().encode(["refreshToken": refreshToken])
            
            do {
                print("🚀 Sending refresh call to backend...")
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw AuthenticationError.sessionExpired
                }
                
                struct TokenResponse: Decodable {
                    let accessToken: String
                    let refreshToken: String?
                }
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                
                try await storeTokens(accessToken: tokenResponse.accessToken, refreshToken: tokenResponse.refreshToken)
                
                print("✅ Refresh successful! New Access Token stored.")
                return tokenResponse.accessToken
                
            } catch let error as URLError {
                throw AuthenticationError.networkError(error)
            } catch {
                throw AuthenticationError.invalidResponse
            }
        }
        
        self.refreshTask = task
        defer { self.refreshTask = nil }
        
        return try await task.value
    }
}
