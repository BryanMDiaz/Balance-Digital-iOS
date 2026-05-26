//
//  UserManager+Meditation.swift
//  Balance-Digital
//
//  Suma minutos de meditación al usuario logueado, para que se reflejen
//  en sus estadísticas de Perfil (campo `meditationMinutes`).
//

import CoreData
import Foundation

extension UserManager {

    /// Suma `minutes` al acumulado de meditación del usuario y devuelve el User actualizado.
    @discardableResult
    func addMeditationMinutes(userId: UUID, minutes: Int) -> User? {
        let context = PersistenceController.shared.container.viewContext
        guard let entity = fetchUser(byId: userId) else { return nil }

        entity.meditationMinutes += Int32(minutes)

        do {
            try context.save()
            return user(from: entity)
        } catch {
            print("❌ Error actualizando minutos de meditación: \(error)")
            return nil
        }
    }
}
