# Integración: Perfil + Edición + Meditación

Archivos generados/modificados para tres tareas. Lo que YA está escrito en el
repo y lo que TÚ debes hacer en Xcode (no se puede hacer solo con archivos).

## Archivos NUEVOS (creados)
- `Balance-Digital/Session/SessionManager.swift`
- `Balance-Digital/Meditation/MeditationSessionManager.swift`
- `Balance-Digital/Database/MeditationManager.swift`
- `Balance-Digital/Database/UserManager+Meditation.swift`

## Archivos REEMPLAZADOS
- `Balance-Digital/Models/User.swift`
- `Balance-Digital/Database/UserManager.swift`
- `Balance-Digital/Services/AuthService.swift`
- `Balance-Digital/App/Balance_DigitalApp.swift`
- `Balance-Digital/Views/Aunth/LoginView.swift`
- `Balance-Digital/Views/Profile/ProfileView.swift`
- `Balance-Digital/Views/Profile/EditProfileView.swift`
- `Balance-Digital/Views/Meditation/MeditationView.swift`

## Modelo CoreData (ya reescrito el `contents`)
`Balance_Digital.xcdatamodeld/.../contents` ahora incluye:
- `UserEntity` + atributos nuevos: `profileImageData` (Binary), `focusedMinutes`,
  `blockRate`, `meditationMinutes` (Integers).
- Entidad nueva `MeditationSessionEntity` (id, mode, durationSeconds, completedAt, userId).

---

## PENDIENTES MANUALES en Xcode (importante)

1. **Agregar los archivos nuevos al target.** Las 2 carpetas nuevas (`Session/`,
   `Meditation/`) y los archivos sueltos deben aparecer en el navegador de Xcode y
   estar marcados en *Target Membership → Balance-Digital*. Si usas Claude Code,
   pídele que actualice `project.pbxproj` para incluirlos, o arrástralos en Xcode.

2. **Verificar el modelo de datos.** Abre `Balance_Digital.xcdatamodeld` en Xcode
   y confirma que `UserEntity` tiene los 4 atributos nuevos y que existe
   `MeditationSessionEntity`. (Edité el `contents` directamente; Xcode debería
   leerlo. Si algo se ve raro, agrega los atributos a mano.)

3. **Activar Background Audio** (para que la música no se corte al minimizar):
   Target → *Signing & Capabilities* → **+ Capability** → **Background Modes** →
   marca **Audio, AirPlay, and Picture in Picture**.

4. **Agregar los audios** al target (Copy Bundle Resources):
   `deepsleep.mp3` y `anxiety.mp3`. Sin ellos el cronómetro funciona pero sin sonido.

5. **Duplicado preexistente:** `HapticManager` y `Color(hex:)` están en
   `Balance_DigitalApp.swift` Y en `App/GlobalHelpers.swift`. Si compila hoy, solo
   uno está en el target. Si sale error de "redeclaración", elimina una de las dos copias.

> No se pudo compilar desde aquí (no hay Xcode). Revisa el build en tu máquina.
