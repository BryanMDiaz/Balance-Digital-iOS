//
//  UserManager.swift
//  Balance-Digital
//

import CoreData
import Foundation

class UserManager {
    static let shared = UserManager()
    private let context = PersistenceController.shared.container.viewContext

    // MARK: - Crear
    func saveUser(user: User, password: String) throws {
        let entity = UserEntity(context: context)
        entity.id = user.id
        entity.fullName = user.fullName
        entity.email = user.email.lowercased()
        entity.password = password // En una app real, aquí deberías encriptarla
        entity.createdAt = user.createdAt
        entity.profileImageData = user.profileImageData
        entity.focusedMinutes = Int32(user.focusedMinutes)
        entity.blockRate = Int16(user.blockRate)
        entity.meditationMinutes = Int32(user.meditationMinutes)

        try context.save()
    }

    // MARK: - Validar credenciales
    func validateUser(email: String, password: String) -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@ AND password == %@",
                                        email.lowercased(), password)
        return try? context.fetch(request).first
    }

    // MARK: - Buscar por email
    func fetchUser(byEmail email: String) -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email.lowercased())
        return try? context.fetch(request).first
    }

    // MARK: - Buscar por ID (usuario autenticado)
    func fetchUser(byId id: UUID) -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request).first
    }

    // MARK: - Actualizar SOLO al usuario autenticado (por su id)
    /// Actualiza nombre, correo y foto del usuario identificado por `id`.
    /// Opcionalmente cambia la contraseña.
    /// - Throws: si el usuario no existe o si el correo ya pertenece a OTRA cuenta.
    /// - Returns: el `User` ya actualizado (para refrescar la sesión y la vista).
    @discardableResult
    func updateUser(id: UUID,
                    fullName: String,
                    email: String,
                    profileImageData: Data?,
                    newPassword: String? = nil) throws -> User {

        guard let entity = fetchUser(byId: id) else {
            throw NSError(domain: "UserManager", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "No se encontró el usuario."])
        }

        let normalizedEmail = email
            .lowercased()
            .trimmingCharacters(in: .whitespaces)

        // El correo no puede pertenecer a OTRO usuario (aislamiento de cuentas).
        if let other = fetchUser(byEmail: normalizedEmail), other.id != id {
            throw NSError(domain: "UserManager", code: 409,
                          userInfo: [NSLocalizedDescriptionKey: "Ese correo ya está en uso por otra cuenta."])
        }

        entity.fullName = fullName.trimmingCharacters(in: .whitespaces)
        entity.email = normalizedEmail
        entity.profileImageData = profileImageData
        if let newPassword, !newPassword.isEmpty {
            entity.password = newPassword
        }

        try context.save()
        return user(from: entity)
    }

    // MARK: - Mapear Entity -> Modelo
    func user(from entity: UserEntity) -> User {
        User(
            id: entity.id ?? UUID(),
            fullName: entity.fullName ?? "",
            email: entity.email ?? "",
            createdAt: entity.createdAt ?? Date(),
            profileImageData: entity.profileImageData,
            focusedMinutes: Int(entity.focusedMinutes),
            blockRate: Int(entity.blockRate),
            meditationMinutes: Int(entity.meditationMinutes)
        )
    }

    // MARK: - Borrar todo (debug)
    func deleteAllUsers() {
        let request: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("🗑️ Todos los registros de usuarios han sido eliminados.")
        } catch {
            print("❌ Error al borrar usuarios: \(error)")
        }
    }
}
