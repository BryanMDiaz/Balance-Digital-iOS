//
//  SessionManager.swift
//  Balance-Digital
//
//  Fuente de verdad del usuario autenticado durante toda la sesión.
//  Cualquier vista que necesite saber "quién está logueado" lee desde aquí.
//  Esto garantiza que ninguna vista pueda mostrar o editar datos de otro usuario:
//  el único usuario accesible es `currentUser`.
//

import SwiftUI

final class SessionManager: ObservableObject {

    /// Instancia compartida e inyectada como EnvironmentObject en el App.
    static let shared = SessionManager()

    /// Usuario actualmente logueado. `nil` = no hay sesión activa.
    @Published var currentUser: User?

    /// Conveniencia para saber si hay sesión.
    var isLoggedIn: Bool { currentUser != nil }

    private init() {}

    /// Inicia sesión: guarda el usuario autenticado tras un login exitoso.
    func start(with user: User) {
        currentUser = user
    }

    /// Refresca en memoria los datos del usuario tras una edición de perfil.
    /// Mantiene la sesión activa (no cierra sesión).
    func refresh(with user: User) {
        currentUser = user
    }

    /// Cierra la sesión.
    func logout() {
        currentUser = nil
    }
}
