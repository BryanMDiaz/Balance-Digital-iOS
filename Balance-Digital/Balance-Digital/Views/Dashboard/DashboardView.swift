//
//  DashboardView.swift
//  Balance Digital
//
//  Created by Bryan Diaz on 3/4/26.
//

import SwiftUI

struct DashboardView: View {
    private struct StatItem: Identifiable {
        let id = UUID()
        let title: String
        let value: String
        let icon: String
        let subtitle: String
        let color: Color
    }

    private struct AppUsageItem: Identifiable {
        let id = UUID()
        let name: String
        let iconName: String
        let time: String
        let progress: CGFloat
        let color: Color
    }

    private struct ActionItem: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let color: Color
    }

    // MARK: - States
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @State private var appearances = Array(repeating: false, count: 8)
    @State private var selectedTab = 0
    @State private var showAllApps = false
    @State private var showMeditation = false

    private let statItems: [StatItem] = [
        StatItem(title: "Bloqueos", value: "12", icon: "hand.raised.fill", subtitle: "Hoy", color: .orange),
        StatItem(title: "Enfoque", value: "85%", icon: "target", subtitle: "+5% vs ayer", color: .green)
    ]

    private let topAppItems: [AppUsageItem] = [
        AppUsageItem(name: "TikTok", iconName: "tiktok", time: "3h 12m", progress: 0.9, color: .black),
        AppUsageItem(name: "WhatsApp", iconName: "whatsapp", time: "2h 45m", progress: 0.75, color: Color(hex: "25D366")),
        AppUsageItem(name: "Instagram", iconName: "instagram", time: "1h 20m", progress: 0.6, color: .pink)
    ]

    private let moreAppItems: [AppUsageItem] = [
        AppUsageItem(name: "Facebook", iconName: "facebook", time: "55m", progress: 0.45, color: Color(hex: "1877F2")),
        AppUsageItem(name: "YouTube", iconName: "youtube", time: "42m", progress: 0.35, color: .red),
        AppUsageItem(name: "ChatGPT", iconName: "chatgpt", time: "30m", progress: 0.25, color: Color(hex: "10A37F")),
        AppUsageItem(name: "Spotify", iconName: "spotify", time: "25m", progress: 0.2, color: Color(hex: "1DB954")),
        AppUsageItem(name: "Telegram", iconName: "telegram", time: "18m", progress: 0.15, color: Color(hex: "26A5E4")),
        AppUsageItem(name: "Pinterest", iconName: "pinterest", time: "15m", progress: 0.12, color: Color(hex: "BD081C")),
        AppUsageItem(name: "Safari", iconName: "safari-2", time: "12m", progress: 0.1, color: .blue),
        AppUsageItem(name: "Unsplash", iconName: "unsplash", time: "5m", progress: 0.05, color: .black)
    ]

    private let actionItems: [ActionItem] = [
        ActionItem(title: "Límites de Tiempo", icon: "timer", color: .purple),
        ActionItem(title: "Modo Zen Profundo", icon: "leaf.fill", color: .cyan)
    ]

    var body: some View {
        ZStack {
            Color(hex: "FBFBFD").ignoresSafeArea()

            Circle()
                .fill(Color.black.opacity(0.03))
                .frame(width: 400, height: 400)
                .offset(x: 150, y: -200)
                .blur(radius: 80)

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 32) {
                        headerSection
                            .offset(y: appearances[0] ? 0 : 20)
                            .opacity(appearances[0] ? 1 : 0)

                        mainHeroCard
                            .scaleEffect(appearances[1] ? 1 : 0.95)
                            .opacity(appearances[1] ? 1 : 0)

                        metricsSection
                            .offset(y: appearances[2] ? 0 : 20)
                            .opacity(appearances[2] ? 1 : 0)

                        mostUsedAppsSection
                            .offset(y: appearances[3] ? 0 : 20)
                            .opacity(appearances[3] ? 1 : 0)

                        managementSection
                            .offset(y: appearances[4] ? 0 : 20)
                            .opacity(appearances[4] ? 1 : 0)

                        Spacer().frame(height: 120)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
        .onAppear {
            startSequence()
        }
    }

    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Estado Actual")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.horizontal, 4)

            HStack(spacing: 16) {
                ForEach(statItems) { item in
                    compactStatCard(item)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var mostUsedAppsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Uso por Aplicación")
                    .font(.system(size: 20, weight: .bold, design: .rounded))

                Spacer()

                Button(action: toggleAppList) {
                    Text(showAllApps ? "Ver menos" : "Ver más")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue)
                }
                .accessibilityLabel(showAllApps ? "Mostrar menos aplicaciones" : "Mostrar más aplicaciones")
            }
            .padding(.horizontal, 4)

            VStack(spacing: 20) {
                ForEach(topAppItems) { item in
                    appUsageRow(item)
                }

                if showAllApps {
                    Group {
                        ForEach(moreAppItems) { item in
                            appUsageRow(item)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
    }

    private var managementSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Gestión")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.horizontal, 4)

            VStack(spacing: 12) {
                ForEach(actionItems) { item in
                    premiumActionRow(item)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func toggleAppList() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showAllApps.toggle()
        }
        HapticManager.impact(style: .light)
    }

    private func appUsageRow(_ item: AppUsageItem) -> some View {
        HStack(spacing: 16) {
            Image(item.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 34, height: 34)
                .cornerRadius(8)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                HStack {
                    Text(item.name)
                        .font(.system(size: 15, weight: .bold))

                    Spacer()

                    Text(item.time)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(hex: "F2F2F7"))
                            .frame(height: 6)

                        Capsule()
                            .fill(item.color)
                            .frame(width: geo.size.width * item.progress, height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.name), \(item.time)")
    }

    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Bienvenido,")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)

                Text("Bryan Diaz")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .tracking(-0.5)
            }

            Spacer()

            if let avatarImage = profileViewModel.avatarImage {
                avatarImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
            } else {
                Image("profile_placeholder")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
            }
        }
    }

    private var mainHeroCard: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("TIEMPO EN PANTALLA")
                        .font(.system(size: 11, weight: .black))
                        .kerning(1.2)
                        .foregroundColor(.white.opacity(0.6))

                    Text("3h 42m")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                        .frame(width: 70, height: 70)

                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            Color.white,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))

                    Image(systemName: "bolt.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
            }

            HStack {
                HStack(spacing: -8) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle().stroke(Color.black.opacity(0.2), lineWidth: 1)
                            )
                    }
                }

                Text("Batiendo tu récord personal")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(30)
        .background(
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "1A1A1A"), .black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [Color.blue.opacity(0.3), .clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 200
                )
            }
        )
        .cornerRadius(32)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 20)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tiempo en pantalla, 3 horas 42 minutos")
    }

    private func compactStatCard(_ item: StatItem) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Image(systemName: item.icon)
                .foregroundColor(item.color)
                .font(.system(size: 20, weight: .bold))
                .padding(10)
                .background(item.color.opacity(0.1))
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))

                Text(item.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)

                Text(item.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.value), \(item.subtitle)")
    }

    private func premiumActionRow(_ item: ActionItem) -> some View {
        HStack(spacing: 16) {
            Image(systemName: item.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(item.color)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .accessibilityHidden(true)

            Text(item.title)
                .font(.system(size: 16, weight: .bold))

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(.systemGray4))
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.03), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
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
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            DashboardView()
            
            VStack {
                Spacer()
                CustomTabBarView(selectedTab: .constant(0), onAction: {})
            }
            .zIndex(100)
        }
        .environmentObject(ProfileViewModel())
    }
}
