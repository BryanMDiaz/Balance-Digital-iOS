//
//  RegisterView.swift
//  Balance Digital
//
//  Created by Bryan Diaz on 29/3/26.
//

import SwiftUI

struct RegisterView: View {
    // MARK: - States
    @State private var fullName         = ""
    @State private var email            = ""
    @State private var password         = ""
    @State private var confirmPassword  = ""
    @State private var acceptedTerms    = false
    
    // Estados de visibilidad
    @State private var showPassword         = false
    @State private var showConfirmPassword  = false
    @State private var showTermsModal       = false // Controla la modal
    
    @State private var isLoading        = false
    @State private var errorMessage     = ""
    @State private var shakeOffset: CGFloat = 0
    @State private var appearances      = Array(repeating: false, count: 7)

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(hex: "FBFBFD").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // 1. Botón Volver
                    Group {
                        Spacer().frame(height: 20)
                        backButton
                            .offset(y: appearances[0] ? 0 : 20)
                            .opacity(appearances[0] ? 1 : 0)
                    }

                    // 2. Logo
                    Group {
                        Spacer().frame(height: 30)
                        logoSection
                            .scaleEffect(appearances[1] ? 1 : 0.8)
                            .opacity(appearances[1] ? 1 : 0)
                    }

                    // 3. Header
                    Group {
                        Spacer().frame(height: 24)
                        VStack(spacing: 8) {
                            Text("Únete a Balance")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .tracking(-0.8)
                            Text("Crea tu cuenta en segundos")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .offset(y: appearances[2] ? 0 : 20)
                        .opacity(appearances[2] ? 1 : 0)
                    }

                    // 4. Fields
                    Group {
                        Spacer().frame(height: 32)
                        VStack(spacing: 16) {
                            premiumField(icon: "person.fill", placeholder: "Nombre completo", text: $fullName)
                            
                            premiumField(icon: "envelope.fill", placeholder: "Correo electrónico", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                            premiumField(icon: "lock.fill", placeholder: "Contraseña", text: $password, isSecure: !showPassword, showToggle: true, isPasswordVisible: $showPassword)
                            
                            premiumField(icon: "lock.rotation", placeholder: "Confirmar contraseña", text: $confirmPassword, isSecure: !showConfirmPassword, showToggle: true, isPasswordVisible: $showConfirmPassword)

                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.red)
                                    .transition(.opacity)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 4)
                            }

                            termsCheckbox
                        }
                        .offset(x: shakeOffset)
                        .offset(y: appearances[3] ? 0 : 20)
                        .opacity(appearances[3] ? 1 : 0)
                    }

                    // 5. Register Button
                    Group {
                        Spacer().frame(height: 30)
                        registerButton
                            .offset(y: appearances[4] ? 0 : 20)
                            .opacity(appearances[4] ? 1 : 0)
                    }

                    // 6. Social
                    Group {
                        Spacer().frame(height: 40)
                        dividerView
                        Spacer().frame(height: 24)
                        socialButtons
                    }
                    .offset(y: appearances[5] ? 0 : 20)
                    .opacity(appearances[5] ? 1 : 0)

                    // 7. Footer
                    Group {
                        Spacer().frame(height: 40)
                        footerView
                    }
                    .offset(y: appearances[6] ? 0 : 20)
                    .opacity(appearances[6] ? 1 : 0)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 28)
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
        .onAppear { startSequence() }
        // MODAL DE TÉRMINOS
        .sheet(isPresented: $showTermsModal) {
            termsModalView
        }
    }

    // MARK: - Componentes Visuales

    private var backButton: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left").font(.system(size: 16, weight: .bold))
                    Text("Volver").font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.black)
            }
            Spacer()
        }
    }

    private var logoSection: some View {
        ZStack {
            Circle().fill(Color.white).frame(width: 90, height: 90).shadow(color: .black.opacity(0.04), radius: 20, x: 0, y: 10)
            Circle().fill(LinearGradient(colors: [.black, Color(hex: "2D2D2D")], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 72, height: 72)
            Image(systemName: "leaf.fill").font(.system(size: 28, weight: .medium)).foregroundStyle(.white)
        }
    }

    private func premiumField(icon: String, placeholder: String, text: Binding<String>, isSecure: Bool = false, showToggle: Bool = false, isPasswordVisible: Binding<Bool>? = nil) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 16)).foregroundColor(text.wrappedValue.isEmpty ? Color(.systemGray3) : .black).frame(width: 20)
            ZStack(alignment: .leading) {
                if text.wrappedValue.isEmpty { Text(placeholder).foregroundColor(Color(.systemGray3)) }
                if isSecure { SecureField("", text: text) } else { TextField("", text: text).disableAutocorrection(true) }
            }
            .font(.system(size: 15, weight: .medium))
            if showToggle, let isVisible = isPasswordVisible {
                Button(action: { isVisible.wrappedValue.toggle(); HapticManager.impact(style: .soft) }) {
                    Image(systemName: isVisible.wrappedValue ? "eye.slash.fill" : "eye.fill").font(.system(size: 14)).foregroundColor(Color(.systemGray3))
                }
            }
        }
        .padding(.horizontal, 20).frame(height: 62).background(Color.white).cornerRadius(18).overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.06), lineWidth: 1))
    }

    private var termsCheckbox: some View {
        Button(action: {
            HapticManager.impact(style: .light)
            showTermsModal = true // Abrimos la modal al presionar
        }) {
            HStack(spacing: 10) {
                Image(systemName: acceptedTerms ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundColor(acceptedTerms ? .black : Color(.systemGray3))
                Text("Acepto los términos y condiciones")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(.horizontal, 4)
    }

    // VISTA DE LA MODAL
    private var termsModalView: some View {
        VStack(spacing: 20) {
            Capsule().fill(Color.gray.opacity(0.3)).frame(width: 40, height: 6).padding(.top, 12)
            
            Text("Política de Privacidad")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            ScrollView {
                Text("En Balance Digital, nos tomamos en serio tu privacidad. Al aceptar, nos otorgas permiso para manejar tus datos de actividad con el único fin de mejorar tu bienestar digital.\n\nPrometemos no vender tus datos a terceros y utilizarlos exclusivamente para las estadísticas de tu perfil.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .lineSpacing(6)
                    .padding()
            }
            
            Button(action: {
                acceptedTerms = true
                showTermsModal = false
                HapticManager.notification(type: .success)
            }) {
                Text("Aceptar y Continuar")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.black)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 30)
        }
        .presentationDetents([.medium]) // La modal ocupa la mitad de la pantalla
        .presentationDragIndicator(.visible)
    }

    private var registerButton: some View {
        Button(action: handleRegister) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.black)
                if isLoading { ProgressView().colorInvert() } else {
                    Text("Crear Cuenta").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                }
            }
            .frame(height: 62)
        }
        .disabled(isLoading) // Quitamos el disabled de términos para que el usuario reciba el error si no los acepta
    }

    private var dividerView: some View {
        HStack(spacing: 12) {
            Rectangle().fill(Color.black.opacity(0.1)).frame(height: 1)
            Text("o continúa con").font(.system(size: 13, weight: .medium)).foregroundColor(.secondary).fixedSize()
            Rectangle().fill(Color.black.opacity(0.1)).frame(height: 1)
        }
    }

    private var socialButtons: some View {
        HStack(spacing: 16) {
            socialProviderButton(imageName: "mac", label: "Apple")
            socialProviderButton(imageName: "google", label: "Google")
        }
    }

    private func socialProviderButton(imageName: String, label: String) -> some View {
        Button(action: { HapticManager.impact(style: .medium) }) {
            HStack(spacing: 10) {
                Image(imageName).resizable().scaledToFit().frame(width: 20, height: 20)
                Text(label).font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(.black).frame(maxWidth: .infinity).frame(height: 58).background(Color.white).cornerRadius(16).overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.1), lineWidth: 1))
        }
    }

    private var footerView: some View {
        HStack(spacing: 5) {
            Text("¿Ya tienes cuenta?").foregroundColor(.secondary)
            Button(action: { dismiss() }) {
                Text("Inicia Sesión").fontWeight(.bold).foregroundColor(.black)
            }
        }
        .font(.system(size: 14))
    }

    // MARK: - LÓGICA DE VALIDACIÓN

    private func handleRegister() {
        errorMessage = ""
        
        // 1. Validar Campos Vacíos
        if fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            triggerError(msg: "Por favor, completa todos los campos.")
            return
        }
        
        // 2. Validar Formato de Email
        if !isValidEmail(email) {
            triggerError(msg: "El formato del correo no es válido.")
            return
        }
        
        // 3. Validar Contraseñas Iguales
        if password != confirmPassword {
            triggerError(msg: "Las contraseñas no coinciden.")
            return
        }
        
        // 4. Validar Términos
        if !acceptedTerms {
            triggerError(msg: "Debes aceptar los términos y condiciones.")
            return
        }

        withAnimation { isLoading = true }
        HapticManager.impact(style: .medium)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { isLoading = false } }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    private func triggerError(msg: String) {
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
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { appearances[i] = true }
            }
        }
    }
}

// MARK: - Preview
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RegisterView()
        }
    }
}
