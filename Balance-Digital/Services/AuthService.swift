import Foundation
import CoreData

class AuthService {
    static let shared = AuthService()
    private let userManager = UserManager.shared

    func register(fullName: String, email: String, password: String) async throws -> User {
        // 1. Verificar si el usuario ya existe
        if userManager.fetchUser(byEmail: email) != nil {
            throw NSError(domain: "AuthService", code: 400, userInfo: [NSLocalizedDescriptionKey: "El correo ya está registrado."])
        }

        // 2. Crear el modelo de usuario
        let newUser = User(
            id: UUID(),
            fullName: fullName,
            email: email,
            createdAt: Date()
        )

        // 3. Guardar en la base de datos local
        try userManager.saveUser(user: newUser, password: password)
        
        // 4. Enviar correo de bienvenida
        print("📣 [DEBUG] Llamando a EmailService...")
        EmailService.shared.sendWelcomeEmail(to: email, name: fullName, password: password)
        
        return newUser
    }

    func login(email: String, password: String) async throws -> User {
        // 1. Intentar validar las credenciales
        guard let userEntity = userManager.validateUser(email: email, password: password) else {
            throw NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Correo o contraseña incorrectos."])
        }

        // 2. Retornar el modelo de usuario si es exitoso
        return User(
            id: userEntity.id ?? UUID(),
            fullName: userEntity.fullName ?? "",
            email: userEntity.email ?? "",
            createdAt: userEntity.createdAt ?? Date()
        )
    }
}
