import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    let fullName: String
    let email: String
    var createdAt: Date
    
    // Podemos agregar campos extra que necesites a futuro
    var profileImageUrl: String?
}
