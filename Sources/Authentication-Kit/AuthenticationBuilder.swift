
import Foundation


public enum CredentialDenyReason {
    case noNumbersIncluded
    case noSpecialCharacter
    case noUppercaseLetter
    case noLowercaseLetter
    case lessThanEightSymbols
    case invalidEmailFormat
    case passwordsDontMatch

    public var message: String {
        return switch self {
        case .noLowercaseLetter:
            String(localized: "No lower case letter included.")
        case .lessThanEightSymbols:
            String(localized: "The given password is too short, please use at least 8 symbols.")
        case .noNumbersIncluded:
            String(localized: "No number included.")
        case .noUppercaseLetter:
            String(localized: "No upper case letter included.")
        case .noSpecialCharacter:
            String(localized: "No special case letter included.")
        case .invalidEmailFormat:
            String(localized: "The given email is not valid.")
        case .passwordsDontMatch:
            String(localized: "The given passwords do not match.")
        }
    }
}

public enum CredentialState {
    case valid(String)
    case invalid(CredentialDenyReason)
}



@Observable
public final class AuthenticationBuilder {
    public var name: String = ""
    public var email: String = ""
    public var password: String = ""
    public var passwordRetyped: String = ""
    
    public var status: LoginStatus = .idle
    
    private let authManager: AutenticationManager
    @ObservationIgnored private let baseURL: URL
    @ObservationIgnored private let session = URLSession.shared

    public init(
        authManager: AutenticationManager,
        baseURL: URL
    ) {
        self.authManager = authManager
        self.baseURL = baseURL
    }

    public var isValidEmail: CredentialState {
        guard !email.contains(" ") else {
            return .invalid(.invalidEmailFormat)
        }

        let parts = email.split(separator: "@")
        guard parts.count == 2 else {
            return .invalid(.invalidEmailFormat)
        }

        let localPart = parts[0]
        let domainPart = parts[1]

        guard !localPart.isEmpty else {
            return .invalid(.invalidEmailFormat)
        }

        let domainParts = domainPart.split(separator: ".")
        guard domainParts.count >= 2 else {
            return .invalid(.invalidEmailFormat)
        }

        guard !domainParts.first!.isEmpty,
              !domainParts.last!.isEmpty else {
            return .invalid(.invalidEmailFormat)
        }
        
        return .valid(email)
    }

    public var isValidPassword: CredentialState {
        guard password.count >= 8 else {
            return .invalid(.lessThanEightSymbols)
        }
        
        guard password.contains(where: { $0.isUppercase }) else {
            return .invalid(.noUppercaseLetter)
        }
        
        guard password.contains(where: { $0.isLowercase }) else {
            return .invalid(.noLowercaseLetter)
        }
        
        guard password.contains(where: { $0.isNumber }) else {
            return .invalid(.noNumbersIncluded)
        }
        
        guard password.contains(where: { "!@#$%^&*(),.?".contains($0) }) else {
            return .invalid(.noSpecialCharacter)
        }
        
        guard password == passwordRetyped else {
            return .invalid(.passwordsDontMatch)
        }
        
        return .valid(password)
    }
    
    @MainActor
    public func logout() async {
        await authManager.logout()
        status = .loggedOut
    }
    
    @MainActor
    public func login() async {
        status = .loading
        
        do {
            let url = baseURL.appendingPathComponent("login")
            let body = ["email": email, "password": password]
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            request.timeoutInterval = 10
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse =
                    response as? HTTPURLResponse,
                    httpResponse.statusCode == 200
            else {
                print("Statuscode: \(response)")
                        
                throw AuthenticationError.invalidCredentials
            }
            
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            
            // Tokens im AuthManager speichern
            try await authManager.storeTokens(
                accessToken: loginResponse.accessToken,
                refreshToken: loginResponse.refreshToken
            )
            
            let user = User(
                id: loginResponse.id ?? UUID(),
                email: email,
                name: loginResponse.name ?? "User",
                token: loginResponse.accessToken
            )
            
            // Benutzer im AuthManager speichern
            try await authManager.storeUser(user)
            
            status = .loggedIn(user)
            
        } catch let error as AuthenticationError {
            status = .error(error)
        } catch {
            status = .error(.serverError(error.localizedDescription))
        }
    }

    /// Prüft, ob eine gültige Session (Token/User) existiert
    @MainActor
    public func checkPersistentLogin() async {
        status = .loading
        
        // 1. Haben wir einen gespeicherten User?
        guard let savedUser = await authManager.restoreUser() else {
            status = .idle
            return
        }

        // 2. Haben wir einen gültigen (oder refresh-baren) Token?
        do {
            let token = try await authManager.getValidAccessToken()
            
            // Wenn der Token sich geändert hat, bauen wir das User-Objekt neu zusammen
            let updatedUser = User(
                id: savedUser.id,
                email: savedUser.email,
                name: savedUser.name,
                token: token
            )
            
            // Den aktualisierten User auch speichern (für den Token)
            try? await authManager.storeUser(updatedUser)
            
            status = .loggedIn(updatedUser)
            print("🔐 Restored session for \(updatedUser.name)")
            
        } catch {
            print("ℹ️ Session expired or invalid: \(error)")
            status = .loggedOut
        }
    }

    @MainActor
    public func register() async {
        status = .loading
        
        do {
            let url = baseURL.appendingPathComponent("register")
            let body = ["name": name, "email": email, "password": password]
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw AuthenticationError.serverError("Registration failed")
            }
            
            // Nach erfolgreicher Registrierung direkt einloggen
            await login()
            
        } catch let error as AuthenticationError {
            status = .error(error)
        } catch {
            status = .error(.serverError(error.localizedDescription))
        }
    }
}
