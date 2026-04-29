//
//  LoginView.swift
//  Balance Digital
//

import SwiftUI
import UIKit

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var shakeOffset: CGFloat = 0
    @State private var appearances = Array(repeating: false, count: 5)
    @State private var showDashboardPreview = false

    var onLoginSuccess: () -> Void = {}

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "FBFBFD")
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Group {
                            Spacer().frame(height: 60)

                            logoSection
                                .scaleEffect(appearances[0] ? 1 : 0.8)
                                .opacity(appearances[0] ? 1 : 0)

                            Spacer().frame(height: 32)

                            headerSection
                                .offset(y: appearances[1] ? 0 : 20)
                                .opacity(appearances[1] ? 1 : 0)

                            Spacer().frame(height: 40)
                        }

                        Group {
                            fieldsSection
                                .offset(x: shakeOffset)
                                .offset(y: appearances[2] ? 0 : 20)
                                .opacity(appearances[2] ? 1 : 0)

                            Spacer().frame(height: 30)

                            loginButton
                                .offset(y: appearances[3] ? 0 : 20)
                                .opacity(appearances[3] ? 1 : 0)

                            Spacer().frame(height: 40)

                            dividerView
                        }

                        Group {
                            Spacer().frame(height: 24)

                            socialButtons

                            Spacer().frame(height: 40)

                            footerView

                            Spacer().frame(height: 40)
                        }
                    }
                    .padding(.horizontal, 28)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(.light)
            .onAppear {
                startSequence()
            }
        }
        .fullScreenCover(isPresented: $showDashboardPreview) {
            MainTabView()
        }
    }

    private var logoSection: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 100, height: 100)
                .shadow(color: .black.opacity(0.04), radius: 20, x: 0, y: 10)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [.black, Color(hex: "2D2D2D")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)

            Image(systemName: "leaf.fill")
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(.white)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Balance Digital")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .tracking(-0.8)

            Text("Recupera el control de tu tiempo")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
    }

    private var fieldsSection: some View {
        VStack(spacing: 16) {
            premiumField(
                icon: "envelope.fill",
                placeholder: "Correo electrónico",
                text: $email
            )
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)

            premiumField(
                icon: "lock.fill",
                placeholder: "Contraseña",
                text: $password,
                isSecure: !showPassword,
                showToggle: true
            )

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                Spacer()

                Button {
                    HapticManager.impact(style: .light)
                } label: {
                    Text("¿Olvidaste tu contraseña?")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func premiumField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool = false,
        showToggle: Bool = false
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(text.wrappedValue.isEmpty ? Color(.systemGray3) : .black)
                .frame(width: 20)

            ZStack(alignment: .leading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color(.systemGray3))
                }

                if isSecure {
                    SecureField("", text: text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                } else {
                    TextField("", text: text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
            }
            .font(.system(size: 15, weight: .medium))

            if showToggle {
                Button {
                    showPassword.toggle()
                    HapticManager.impact(style: .soft)
                } label: {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(Color(.systemGray3))
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 62)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var loginButton: some View {
        Button {
            handleLogin()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.black)

                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Iniciar Sesión")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(height: 62)
        }
        .disabled(isLoading)
    }

    private var dividerView: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(height: 1)

            Text("o continúa con")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)

            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(height: 1)
        }
    }

    private var socialButtons: some View {
        HStack(spacing: 16) {
            socialProviderButton(imageName: "mac", label: "Apple")
            socialProviderButton(imageName: "google", label: "Google")
        }
    }

    private func socialProviderButton(imageName: String, label: String) -> some View {
        Button {
            HapticManager.impact(style: .medium)
        } label: {
            HStack(spacing: 10) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                Text(label)
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
        }
    }

    private var footerView: some View {
        HStack(spacing: 5) {
            Text("¿No tienes cuenta?")
                .foregroundColor(.secondary)

            NavigationLink {
                RegisterView()
            } label: {
                Text("Regístrate")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
        }
        .font(.system(size: 14))
    }

    private func startSequence() {
        for index in appearances.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    appearances[index] = true
                }
            }
        }
    }

    private func handleLogin() {
        errorMessage = ""

        guard !email.isEmpty, !password.isEmpty else {
            triggerError(msg: "Por favor rellena todos los campos")
            return
        }

        isLoading = true
        HapticManager.impact(style: .medium)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            onLoginSuccess()
            showDashboardPreview = true
        }
    }

    private func triggerError(msg: String) {
        errorMessage = msg
        HapticManager.notification(type: .error)

        let offsets: [CGFloat] = [10, -10, 10, -10, 0]

        for (index, offset) in offsets.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                shakeOffset = offset
            }
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(ProfileViewModel())
    }
}
