import CoreData
import Foundation

class UserManager {
    static let shared = UserManager()
    private let context = PersistenceController.shared.container.viewContext

    // Guardar un nuevo usuario
    func saveUser(user: User, password: String) throws {
        let entity = UserEntity(context: context)
        entity.id = user.id
        entity.fullName = user.fullName
        entity.email = user.email.lowercased()
        entity.password = password // En una app real, aquí deberías encriptarla
        entity.createdAt = user.createdAt

        try context.save()
    }

    // Validar credenciales de usuario
    func validateUser(email: String, password: String) -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@ AND password == %@", email.lowercased(), password)
        
        return try? context.fetch(request).first
    }

    // Buscar si ya existe un usuario por email
    func fetchUser(byEmail email: String) -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email.lowercased())
        
        return try? context.fetch(request).first
    }

    // Borrar todos los usuarios de la base de datos
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
