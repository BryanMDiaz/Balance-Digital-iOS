//
//   ProfileView.swift
//  BalanceDigitalApp
//
//  Created by Bryan_Dev on 14/4/26.
//

import SwiftUI

struct ProfileView: View {
    
    // MARK: - States
    @State private var showEditProfile = false
    @State private var appearances = Array(repeating: false, count: 4)
    @State private var selectedTab = 3 // Settings/Profile
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss

    // MARK: - Body
    var body: some View {
        ZStack {
            Color(hex: "FBFBFD").ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 28) {
                        
                        // Botón Volver
                        Group {
                            Spacer().frame(height: 20)
                            backButton
                                .offset(y: appearances[0] ? 0 : 20)
                                .opacity(appearances[0] ? 1 : 0)
                        }
                        
                        // Hero Card
                        profileHeroCard
                            .scaleEffect(appearances[1] ? 1 : 0.95)
                            .opacity(appearances[1] ? 1 : 0)
                        
                        // Sección de Estadísticas
                        statsSection
                            .offset(y: appearances[2] ? 0 : 20)
                            .opacity(appearances[2] ? 1 : 0)
                        
                        // Sección de Acciones
                        actionsSection
                            .offset(y: appearances[3] ? 0 : 20)
                            .opacity(appearances[3] ? 1 : 0)
                        
                        Spacer().frame(height: 120) // Extra space for TabBar
                    }
                    .padding(.horizontal, 28)
                }
            }

        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
        .onAppear { startSequence() }
        .fullScreenCover(isPresented: $showEditProfile) {
            EditProfileView()
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
    
    // MARK: - Profile Hero
    private var profileHeroCard: some View {
        VStack(spacing: 20) {
            if let avatarImage = profileViewModel.avatarImage {
                avatarImage
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
                    Text("BD")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
            }
            
            VStack(spacing: 8) {
                Text("Bryan Diaz")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                Text("Miembro desde Abr 2026")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 24) {
                badgeView(text: "Balance Pro", icon: "star.fill", color: .purple)
                badgeView(text: "18 días de racha", icon: "flame.fill", color: .orange)
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
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Estadísticas")
            HStack(spacing: 16) {
                statCard(value: "3h 15m", label: "Tiempo Promedio", icon: "clock.fill", color: .blue)
                statCard(value: "72%", label: "Tasa de Enfoque", icon: "target", color: .green)
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
                actionRow(title: "Cerrar Sesión", icon: "arrow.right.to.line.alt", isDestructive: true)
            }
        }
    }
    
    // MARK: - Reusable Components
    private func badgeView(text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
    
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
    }
    
    private func actionRow(title: String, icon: String, isDestructive: Bool = false) -> some View {
        Button(action: {}) {
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
        }
    }
    
    // MARK: - Logic
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
        ZStack {
            ProfileView()
            
            VStack {
                Spacer()
                CustomTabBarView(selectedTab: .constant(4), onAction: {})
            }
            .zIndex(100)
        }
        .environmentObject(ProfileViewModel())
    }
}
