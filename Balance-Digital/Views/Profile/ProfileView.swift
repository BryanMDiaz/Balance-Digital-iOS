//
//   ProfileView.swift
//  Balance-Digital
//

import SwiftUI
import UIKit

struct ProfileView: View {

    // MARK: - States
    @State private var showEditProfile = false
    @State private var appearances = Array(repeating: false, count: 4)
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss

    // Usuario logueado (fuente de verdad). Si por alguna razón no hay
    // sesión, mostramos un placeholder seguro.
    private var user: User? { session.currentUser }

    // MARK: - Body
    var body: some View {
        ZStack {
            Color(hex: "FBFBFD").ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 28) {

                        Group {
                            Spacer().frame(height: 20)
                            backButton
                                .offset(y: appearances[0] ? 0 : 20)
                                .opacity(appearances[0] ? 1 : 0)
                        }

                        profileHeroCard
                            .scaleEffect(appearances[1] ? 1 : 0.95)
                            .opacity(appearances[1] ? 1 : 0)

                        statsSection
                            .offset(y: appearances[2] ? 0 : 20)
                            .opacity(appearances[2] ? 1 : 0)

                        actionsSection
                            .offset(y: appearances[3] ? 0 : 20)
                            .opacity(appearances[3] ? 1 : 0)

                        Spacer().frame(height: 120)
                    }
                    .padding(.horizontal, 28)
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
        .onAppear { startSequence() }
        .fullScreenCover(isPresented: $showEditProfile) {
            // Reinyectamos la sesión por seguridad al presentar de forma modal.
            EditProfileView()
                .environmentObject(session)
                .environmentObject(profileViewModel)
        }
    }

    // MARK: - Back Button
    private var backButton: some View {
        HStack(spacing: 6) {
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
        }
    }

    // MARK: - Avatar (foto o iniciales del usuario)
    @ViewBuilder
    private var avatarView: some View {
        if let data = user?.profileImageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 84, height: 84)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
        } else {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 84, height: 84)
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(hex: "1A1A1A"), Color(hex: "3A3A3A")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 76, height: 76)
                Text(user?.initials ?? "?")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
        }
    }

    // MARK: - Profile Hero
    private var profileHeroCard: some View {
        VStack(spacing: 20) {
            avatarView

            VStack(spacing: 8) {
                Text(user?.fullName.isEmpty == false ? user!.fullName : "Usuario")
                    .font(.system(size: 26, weight: .bold, design: .rounded))

                if let user {
                    Text("Miembro desde \(memberSince(user.createdAt))")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                // El correo del usuario logueado
                if let email = user?.email, !email.isEmpty {
                    Text(email)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            Button(action: { showEditProfile = true }) {
                Text("Editar Perfil")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(16)
            }
        }
        .padding(28)
        .background(Color.white)
        .cornerRadius(32)
        .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 20, y: 10)
    }

    // MARK: - Stats Section (estadísticas reales del usuario)
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Estadísticas")

            HStack(spacing: 16) {
                statCard(value: User.formatMinutes(user?.focusedMinutes ?? 0),
                         label: "Tiempo Enfocado", icon: "clock.fill", color: .blue)
                statCard(value: "\(user?.blockRate ?? 0)%",
                         label: "Tasa de Bloqueo", icon: "target", color: .green)
            }

            // Tiempo de meditación: solo si aplica (> 0)
            if let minutes = user?.meditationMinutes, minutes > 0 {
                HStack(spacing: 16) {
                    statCard(value: User.formatMinutes(minutes),
                             label: "Meditación", icon: "sparkles", color: .purple)
                    Spacer()
                }
            }
        }
    }

    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Más Opciones")

            VStack(spacing: 12) {
                actionRow(title: "Configuración", icon: "gearshape.fill")
                actionRow(title: "Ayuda y Soporte", icon: "questionmark.circle.fill")
                Button(action: { session.logout() }) {
                    actionRowContent(title: "Cerrar Sesión",
                                     icon: "arrow.right.to.line.alt",
                                     isDestructive: true)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Reusable Components
    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
                .padding(10)
                .background(color.opacity(0.1))
                .clipShape(Circle())

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func actionRow(title: String, icon: String, isDestructive: Bool = false) -> some View {
        Button(action: {}) {
            actionRowContent(title: title, icon: icon, isDestructive: isDestructive)
        }
        .buttonStyle(.plain)
    }

    private func actionRowContent(title: String, icon: String, isDestructive: Bool) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(isDestructive ? .red : .primary)
                .frame(width: 44, height: 44)
                .background(isDestructive ? Color.red.opacity(0.1) : Color(hex: "F2F2F7"))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(isDestructive ? .red : .primary)

            Spacer()

            if !isDestructive {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(.systemGray4))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
    }

    // MARK: - Logic
    private func memberSince(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date).capitalized
    }

    private func startSequence() {
        for i in 0..<appearances.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    appearances[i] = true
                }
            }
        }
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let session = SessionManager.shared
        session.currentUser = User(id: UUID(),
                                   fullName: "Bryan Diaz",
                                   email: "bryan@example.com",
                                   createdAt: Date(),
                                   focusedMinutes: 195,
                                   blockRate: 72,
                                   meditationMinutes: 40)
        return ProfileView()
            .environmentObject(session)
            .environmentObject(ProfileViewModel())
    }
}
