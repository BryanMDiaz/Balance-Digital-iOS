//
//  User.swift
//  Balance-Digital
//

import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var fullName: String
    var email: String
    var createdAt: Date

    /// Foto de perfil guardada como datos crudos (opcional).
    var profileImageData: Data?

    // MARK: - Estadísticas personales
    /// Tiempo enfocado acumulado, en minutos.
    var focusedMinutes: Int
    /// Tasa de bloqueo (porcentaje 0–100).
    var blockRate: Int
    /// Tiempo de meditación acumulado, en minutos.
    var meditationMinutes: Int

    init(id: UUID,
         fullName: String,
         email: String,
         createdAt: Date,
         profileImageData: Data? = nil,
         focusedMinutes: Int = 0,
         blockRate: Int = 0,
         meditationMinutes: Int = 0) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.createdAt = createdAt
        self.profileImageData = profileImageData
        self.focusedMinutes = focusedMinutes
        self.blockRate = blockRate
        self.meditationMinutes = meditationMinutes
    }
}

// MARK: - Helpers de Nombre / Apellido / Iniciales
extension User {

    /// Primera palabra del nombre completo -> "Nombre".
    var firstName: String {
        fullName.split(separator: " ").first.map(String.init) ?? fullName
    }

    /// Resto de palabras del nombre completo -> "Apellido(s)".
    var lastName: String {
        let parts = fullName.split(separator: " ").map(String.init)
        guard parts.count > 1 else { return "" }
        return parts.dropFirst().joined(separator: " ")
    }

    /// Iniciales para el avatar cuando no hay foto (ej: "BD").
    var initials: String {
        let f = firstName.first.map { String($0) } ?? ""
        let l = lastName.first.map { String($0) } ?? ""
        let result = (f + l).uppercased()
        return result.isEmpty ? "?" : result
    }

    /// Combina Nombre + Apellido en un solo `fullName` limpio.
    static func combinedName(first: String, last: String) -> String {
        [first, last]
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Formatea minutos como "3h 15m", "45m", etc.
    static func formatMinutes(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        if h > 0 && m > 0 { return "\(h)h \(m)m" }
        if h > 0          { return "\(h)h" }
        return "\(m)m"
    }
}
