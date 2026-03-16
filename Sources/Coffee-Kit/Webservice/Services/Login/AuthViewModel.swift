//
//  AuthModel.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 05.07.25.
//

import Foundation
import Combine

@MainActor
public final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage: String?
    @Published var registrationSuccessful = false // Für die Registrierung

    // MARK: - Login-Logik

    func login() async {
        errorMessage = nil // Vorherige Fehlermeldungen löschen

        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Bitte E-Mail und Passwort eingeben."
            return
        }

        // Simuliere einen Netzwerkaufruf zum Backend
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000) // Simuliere 1 Sekunde Verzögerung

        // Hier würde der tatsächliche API-Aufruf zu deinem Backend erfolgen.
        // Das Backend würde die Authentifizierung überprüfen (Passwort salzen, pfeffern, hashen und vergleichen).
        // Wenn erfolgreich, würde es ein Authentifizierungstoken zurückgeben.
        // Andernfalls eine Fehlermeldung.

        // Simuliere Erfolg oder Misserfolg
        if email == "test@example.com" && password == "password123" {
            print("Login erfolgreich!")
            // Hier würdest du den Benutzerstatus in deiner App aktualisieren (z.B. User Defaults, KeyChain, etc.)
            // Und zur Hauptansicht navigieren.
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Ungültige E-Mail oder Passwort."
            }
        }
    }

    // MARK: - Registrierungs-Logik

    func register() async {
        errorMessage = nil // Vorherige Fehlermeldungen löschen
        registrationSuccessful = false

        guard !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty else {
            errorMessage = "Bitte alle Felder ausfüllen."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwörter stimmen nicht überein."
            return
        }

        // Simuliere einen Netzwerkaufruf zum Backend
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000) // Simuliere 1 Sekunde Verzögerung

        // Hier würde der tatsächliche API-Aufruf zu deinem Backend erfolgen.
        // Das Backend würde:
        // 1. Das Passwort sicher verarbeiten (salzen, pfeffern, hashen).
        // 2. Den neuen Benutzer in der Datenbank speichern.
        // 3. Eine Bestätigungs-E-Mail an die angegebene E-Mail-Adresse senden.
        // 4. Bei Erfolg einen Erfolgsstatus zurückgeben oder bei Misserfolg eine Fehlermeldung.

        // Simuliere Erfolg oder Misserfolg
        if email.contains("@") && password.count >= 6 { // Einfache Validierung
            DispatchQueue.main.async {
                self.registrationSuccessful = true
                self.errorMessage = "Registrierung erfolgreich! Bitte überprüfe deine E-Mial für die Bestätigung."
                // Hier könntest du auch zur LoginView zurückkehren.
            }
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Registrierung fehlgeschlagen. Bitte überprüfe deine Eingaben."
            }
        }
    }
}
