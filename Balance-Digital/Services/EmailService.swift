import Foundation

class EmailService {
    static let shared = EmailService()
    
    // Configuración
    private let apiKey = "TU_SENDGRID_API_KEY"
    
    // IMPORTANTE: Cambia esto por el correo que verificaste en SendGrid (Sender Identity)
    private let verifiedSenderEmail = "diazbryan1020@gmail.com" 
    
    func sendWelcomeEmail(to receiverEmail: String, name: String, password: String) {
        print("🚀 [DEBUG] Intentando enviar correo a: \(receiverEmail)")
        let url = URL(string: "https://api.sendgrid.com/v3/mail/send")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "personalizations": [
                [
                    "to": [["email": receiverEmail]],
                    "subject": "¡Bienvenido a Balance Digital!"
                ]
            ],
            "from": ["email": verifiedSenderEmail, "name": "Balance Digital"],
            "content": [
                [
                    "type": "text/plain",
                    "value": """
                    Hola \(name),
                    
                    ¡Gracias por unirte a Balance Digital! Estamos felices de tenerte.
                    
                    Tus credenciales de acceso son:
                    Email: \(receiverEmail)
                    Contraseña: \(password)
                    
                    Te recomendamos cambiar tu contraseña una vez dentro de la app.
                    """
                ]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Error serializando JSON: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error de red enviando correo: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    print("✅ Correo enviado con éxito (SendGrid)")
                } else {
                    print("❌ Error de SendGrid. Código: \(httpResponse.statusCode)")
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Respuesta de error: \(responseString)")
                    }
                }
            }
        }.resume()
    }
}
