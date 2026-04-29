//
//  EditProfileView.swift
//  BalanceDigitalApp
//
//  Created by Bryan_Dev on 14/4/26.
// HOLA

import SwiftUI
import PhotosUI

struct EditProfileView: View {

    // MARK: - State — Datos personales
    @State private var firstName         = "Bryan"
    @State private var lastName          = "Diaz"
    @State private var birthDate         = Calendar.current.date(from: DateComponents(year: 2000, month: 6, day: 15)) ?? Date()
    @State private var email             = "bryan@example.com"

    // Contraseña
    @State private var oldPassword       = ""
    @State private var newPassword       = ""
    @State private var showOldPassword   = false
    @State private var showNewPassword   = false

    // Zona horaria
    @State private var selectedTimezone  = TimeZone.current

    // UI State
    @State private var isEditing         = false
    @State private var isLoading         = false
    @State private var errorMessage      = ""
    @State private var successMessage    = ""
    @State private var shakeOffset: CGFloat = 0
    @State private var appearances       = Array(repeating: false, count: 5)
    @State private var showDatePicker    = false
    @State private var showTimezonePicker = false

    // Foto
    @State private var selectedPhoto: PhotosPickerItem? = nil

    @EnvironmentObject var profileViewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss

    private let commonTimezones: [TimeZone] = {
        let ids = ["America/Mexico_City", "America/New_York", "America/Chicago",
                   "America/Denver", "America/Los_Angeles", "America/Bogota",
                   "America/Lima", "America/Santiago", "America/Sao_Paulo",
                   "Europe/Madrid", "Europe/London", "UTC"]
        return ids.compactMap { TimeZone(identifier: $0) }
    }()

    // MARK: - Body
    var body: some View {
        ZStack {
            Color(hex: "FBFBFD").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Botón Volver
                    Group {
                        Spacer().frame(height: 20)
                        backButton
                            .offset(y: appearances[0] ? 0 : 20)
                            .opacity(appearances[0] ? 1 : 0)
                    }

                    // Avatar
                    Group {
                        Spacer().frame(height: 30)
                        avatarSection
                            .scaleEffect(appearances[1] ? 1 : 0.85)
                            .opacity(appearances[1] ? 1 : 0)
                    }

                    // Header
                    Group {
                        Spacer().frame(height: 20)
                        VStack(spacing: 6) {
                            Text("Mi Perfil")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .tracking(-0.6)
                            Text(isEditing ? "Modifica tu información personal" : "Toca \"Editar\" para hacer cambios")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .offset(y: appearances[2] ? 0 : 20)
                        .opacity(appearances[2] ? 1 : 0)
                    }

                    // Campos
                    Group {
                        Spacer().frame(height: 28)
                        personalSection
                            .offset(x: shakeOffset)
                            .offset(y: appearances[3] ? 0 : 20)
                            .opacity(appearances[3] ? 1 : 0)
                    }

                    Group {
                        Spacer().frame(height: 20)
                        accountSection
                            .offset(y: appearances[4] ? 0 : 20)
                            .opacity(appearances[4] ? 1 : 0)
                    }

                    if isEditing {
                        Group {
                            Spacer().frame(height: 20)
                            passwordSection
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }

                    // Mensajes
                    Group {
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                                .padding(.top, 12)
                                .transition(.opacity)
                        }
                        if !successMessage.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "10A37F"))
                                Text(successMessage)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(hex: "10A37F"))
                            }
                            .padding(.top, 12)
                            .transition(.opacity)
                        }
                    }

                    // Botón principal + footer
                    Group {
                        Spacer().frame(height: 28)
                        actionButton

                        if isEditing {
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    isEditing = false
                                    errorMessage = ""
                                    successMessage = ""
                                    oldPassword = ""
                                    newPassword = ""
                                }
                                HapticManager.impact(style: .light)
                            } label: {
                                Text("Cancelar")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 14)
                            .transition(.opacity)
                        }

                        Spacer().frame(height: 60)
                    }
                }
                .padding(.horizontal, 28)
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
        .onAppear { startSequence() }
        .animation(.spring(response: 0.38, dampingFraction: 0.82), value: isEditing)
        // Date Picker Sheet
        .sheet(isPresented: $showDatePicker) {
            datepickerSheet
        }
        // Timezone Picker Sheet
        .sheet(isPresented: $showTimezonePicker) {
            timezonePickerSheet
        }
    }

    // MARK: - Back Button
    private var backButton: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                    Text("Volver")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.black)
            }
            Spacer()
            Text(isEditing ? "Editando" : "Solo lectura")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isEditing ? Color(hex: "6C63FF") : .secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isEditing ? Color(hex: "6C63FF").opacity(0.1) : Color(hex: "F2F2F7"))
                .clipShape(Capsule())
        }
    }

    // MARK: - Avatar
    private var avatarSection: some View {
        VStack(spacing: 10) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    if let avatarImage = profileViewModel.avatarImage {
                        avatarImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 96, height: 96)
                            .clipShape(Circle())
                    } else {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(hex: "1A1A1A"), Color(hex: "3A3A3A")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                                .frame(width: 96, height: 96)
                            Text(avatarInitials)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    ZStack {
                        Circle()
                            .fill(isEditing ? Color.black : Color(.systemGray4))
                            .frame(width: 30, height: 30)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 4, y: 4)
                }
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
            }
            .onChange(of: selectedPhoto) { newItem in
                Task { @MainActor in
                    guard let newItem else { return }
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        profileViewModel.avatarImage = Image(uiImage: uiImage)
                    }
                }
            }
            Text("Toca para cambiar foto")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Personal Section
    private var personalSection: some View {
        VStack(spacing: 14) {
            sectionLabel("Datos personales")

            profileField(
                icon: "person.fill",
                placeholder: "Nombre",
                text: $firstName,
                isDisabled: !isEditing
            )

            profileField(
                icon: "person.fill",
                placeholder: "Apellido",
                text: $lastName,
                isDisabled: !isEditing
            )

            // Fecha de nacimiento
            Button {
                if isEditing { showDatePicker = true }
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(!isEditing ? Color(.systemGray3) : .black)
                        .frame(width: 20)
                    Text(formattedBirthDate)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(!isEditing ? Color(.systemGray3) : .primary)
                    Spacer()
                    if isEditing {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(.systemGray3))
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 62)
                .background(!isEditing ? Color(hex: "F7F7FA") : Color.white)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(!isEditing ? Color.black.opacity(0.04) : Color.black.opacity(0.1), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(!isEditing)

            // Zona horaria
            Button {
                if isEditing { showTimezonePicker = true }
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "globe")
                        .font(.system(size: 16))
                        .foregroundColor(!isEditing ? Color(.systemGray3) : .black)
                        .frame(width: 20)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedTimezone.identifier.replacingOccurrences(of: "_", with: " "))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(!isEditing ? Color(.systemGray3) : .primary)
                        Text(timezoneOffset(selectedTimezone))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if isEditing {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(.systemGray3))
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 62)
                .background(!isEditing ? Color(hex: "F7F7FA") : Color.white)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(!isEditing ? Color.black.opacity(0.04) : Color.black.opacity(0.1), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(!isEditing)
        }
    }

    // MARK: - Account Section
    private var accountSection: some View {
        VStack(spacing: 14) {
            sectionLabel("Cuenta")

            profileField(
                icon: "envelope.fill",
                placeholder: "Correo electrónico",
                text: $email,
                isDisabled: !isEditing,
                keyboard: .emailAddress
            )
        }
    }

    // MARK: - Password Section
    private var passwordSection: some View {
        VStack(spacing: 14) {
            sectionLabel("Cambiar contraseña")

            profileField(
                icon: "lock.fill",
                placeholder: "Contraseña actual",
                text: $oldPassword,
                isDisabled: false,
                isSecure: !showOldPassword,
                showToggle: true,
                isVisible: $showOldPassword
            )

            profileField(
                icon: "lock.rotation",
                placeholder: "Contraseña nueva",
                text: $newPassword,
                isDisabled: false,
                isSecure: !showNewPassword,
                showToggle: true,
                isVisible: $showNewPassword
            )
        }
    }

    // MARK: - Action Button
    private var actionButton: some View {
        Button(action: handleAction) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.black)
                if isLoading {
                    ProgressView().colorInvert()
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: isEditing ? "checkmark" : "pencil")
                            .font(.system(size: 15, weight: .bold))
                        Text(isEditing ? "Guardar cambios" : "Editar perfil")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                }
            }
            .frame(height: 62)
        }
        .disabled(isLoading)
    }

    // MARK: - Date Picker Sheet
    private var datepickerSheet: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            Text("Fecha de nacimiento")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.top, 20)

            DatePicker(
                "",
                selection: $birthDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .padding(.horizontal, 20)

            Button {
                showDatePicker = false
                HapticManager.impact(style: .light)
            } label: {
                Text("Confirmar")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.black)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 34)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Timezone Picker Sheet
    private var timezonePickerSheet: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            Text("Zona horaria")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.top, 20)
                .padding(.bottom, 10)

            List(commonTimezones, id: \.identifier) { tz in
                Button {
                    selectedTimezone = tz
                    showTimezonePicker = false
                    HapticManager.impact(style: .light)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(tz.identifier.replacingOccurrences(of: "_", with: " "))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            Text(timezoneOffset(tz))
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if tz.identifier == selectedTimezone.identifier {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                }
                .listRowBackground(Color(hex: "FBFBFD"))
            }
            .listStyle(.plain)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Helpers
    private var avatarInitials: String {
        let f = firstName.prefix(1).uppercased()
        let l = lastName.prefix(1).uppercased()
        return "\(f)\(l)"
    }

    private var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateStyle = .long
        return formatter.string(from: birthDate)
    }

    private func timezoneOffset(_ tz: TimeZone) -> String {
        let seconds = tz.secondsFromGMT()
        let hours = seconds / 3600
        let minutes = abs(seconds / 60) % 60
        return String(format: "UTC%+d:%02d", hours, minutes)
    }

    private func sectionLabel(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            Spacer()
        }
        .padding(.horizontal, 4)
    }

    private func profileField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        isDisabled: Bool,
        isSecure: Bool = false,
        showToggle: Bool = false,
        isVisible: Binding<Bool>? = nil,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(isDisabled ? Color(.systemGray3) : (text.wrappedValue.isEmpty ? Color(.systemGray3) : .black))
                .frame(width: 20)
            ZStack(alignment: .leading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder).foregroundColor(Color(.systemGray3))
                }
                if isSecure {
                    SecureField("", text: text).disabled(isDisabled)
                } else {
                    TextField("", text: text)
                        .keyboardType(keyboard)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .disabled(isDisabled)
                }
            }
            .font(.system(size: 15, weight: .medium))
            if showToggle, let visible = isVisible {
                Button(action: {
                    visible.wrappedValue.toggle()
                    HapticManager.impact(style: .soft)
                }) {
                    Image(systemName: visible.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.systemGray3))
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 62)
        .background(isDisabled ? Color(hex: "F7F7FA") : Color.white)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(isDisabled ? Color.black.opacity(0.04) : Color.black.opacity(0.1), lineWidth: 1))
        .animation(.easeInOut(duration: 0.2), value: isDisabled)
    }

    // MARK: - Logic
    private func handleAction() {
        if !isEditing {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isEditing = true
                successMessage = ""
                errorMessage = ""
            }
            HapticManager.impact(style: .medium)
            return
        }
        errorMessage = ""
        successMessage = ""

        if firstName.trimmingCharacters(in: .whitespaces).isEmpty {
            triggerError("El nombre no puede estar vacío.")
            return
        }
        if lastName.trimmingCharacters(in: .whitespaces).isEmpty {
            triggerError("El apellido no puede estar vacío.")
            return
        }
        if !isValidEmail(email) {
            triggerError("El formato del correo no es válido.")
            return
        }
        if !oldPassword.isEmpty || !newPassword.isEmpty {
            if oldPassword.isEmpty {
                triggerError("Ingresa tu contraseña actual.")
                return
            }
            if newPassword.count < 6 {
                triggerError("La nueva contraseña debe tener al menos 6 caracteres.")
                return
            }
        }

        withAnimation { isLoading = true }
        HapticManager.impact(style: .medium)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation {
                isLoading = false
                isEditing = false
                successMessage = "¡Perfil actualizado correctamente!"
                oldPassword = ""
                newPassword = ""
            }
            HapticManager.notification(type: .success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { successMessage = "" }
            }
        }
    }

    private func isValidEmail(_ value: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: value)
    }

    private func triggerError(_ msg: String) {
        errorMessage = msg
        HapticManager.notification(type: .error)
        let offsets: [CGFloat] = [10, -10, 10, -10, 0]
        for (i, offset) in offsets.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                withAnimation(.interactiveSpring()) { shakeOffset = offset }
            }
        }
    }

    private func startSequence() {
        for i in 0..<appearances.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    appearances[i] = true
                }
            }
        }
    }
}

// MARK: - Preview
struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
            .environmentObject(ProfileViewModel())
    }
}
