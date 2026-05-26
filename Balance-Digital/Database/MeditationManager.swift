//
//  MeditationManager.swift
//  Balance-Digital
//
//  Registro de sesiones de meditación finalizadas en la base de datos.
//

import CoreData
import Foundation

final class MeditationManager {
    static let shared = MeditationManager()
    private let context = PersistenceController.shared.container.viewContext

    /// Guarda un registro de la sesión completada.
    /// - Parameters:
    ///   - mode: nombre del modo (ej. "Sueño profundo").
    ///   - durationSeconds: duración total de la sesión.
    ///   - userId: id del usuario logueado (para aislar el historial por usuario).
    @discardableResult
    func registerCompletedSession(mode: String,
                                  durationSeconds: Int,
                                  userId: UUID?) -> Bool {
        let entity = MeditationSessionEntity(context: context)
        entity.id = UUID()
        entity.mode = mode
        entity.durationSeconds = Int32(durationSeconds)
        entity.completedAt = Date()
        entity.userId = userId

        do {
            try context.save()
            print("✅ Sesión de meditación registrada: \(mode) — \(durationSeconds)s")
            return true
        } catch {
            print("❌ Error registrando la sesión de meditación: \(error)")
            return false
        }
    }

    /// Sesiones completadas por un usuario (para historial / estadísticas).
    func sessions(for userId: UUID) -> [MeditationSessionEntity] {
        let request: NSFetchRequest<MeditationSessionEntity> = MeditationSessionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "completedAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
}
