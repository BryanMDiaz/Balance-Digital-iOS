//
//  ApproachView.swift
//  Balance Digital
//
//  Created by Bryan Programer on 7/4/26.
//

import SwiftUI

struct ApproachView: View {
    // MARK: - Models
    private struct AppItem: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let iconAssetName: String?
        let fallbackSystemName: String
    }

    // MARK: - State
    @State private var apps: [AppItem] = [
        .init(name: "TikTok", iconAssetName: "tiktok", fallbackSystemName: "play.rectangle.fill"),
        .init(name: "Instagram", iconAssetName: "instagram", fallbackSystemName: "camera.fill"),
        .init(name: "YouTube", iconAssetName: "youtube", fallbackSystemName: "play.tv.fill"),
        .init(name: "WhatsApp", iconAssetName: "whatsapp", fallbackSystemName: "message.fill"),
        .init(name: "Telegram", iconAssetName: "telegram", fallbackSystemName: "paperplane.fill"),
        .init(name: "Safari", iconAssetName: "safari-2", fallbackSystemName: "safari.fill"),
        .init(name: "X", iconAssetName: nil, fallbackSystemName: "xmark"),
        .init(name: "Facebook", iconAssetName: "facebook", fallbackSystemName: "person.2.fill"),
        .init(name: "Spotify", iconAssetName: "spotify", fallbackSystemName: "music.note"),
        .init(name: "ChatGPT", iconAssetName: "chatgpt", fallbackSystemName: "sparkles")
    ]

    @State private var selectedAppIDs = Set<UUID>()
    @State private var showDurationSheet = false
    @State private var sheetHours = 0
    @State private var sheetMinutes = 30
    @State private var confirmedTotalSeconds: Int? = nil
    @State private var frozenRemaining: TimeInterval = 0
    @State private var countdownEnd: Date? = nil
    @State private var isRunning = false
    @State private var showStartError = false
    @State private var startErrorMessage = ""
    @State private var selectedTab = -1 // Ningún tab seleccionado
    @State private var showCompletionModal = false
    @State private var completionTitle = ""
    @State private var completionSubtitle = ""
    @State private var showProgrammedApproach = false
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FBFBFD"), Color(hex: "F4F6FB"), Color(hex: "EEF2F8")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.black.opacity(0.03))
                .frame(width: 420)
                .offset(x: 180, y: -220)
                .blur(radius: 90)

            Circle()
                .fill(Color(hex: "1A1A1A").opacity(0.04))
                .frame(width: 280)
                .offset(x: -170, y: 420)
                .blur(radius: 80)

            VStack(spacing: 0) {
                // Barra superior con botón volver
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white).shadow(color: .black.opacity(0.05), radius: 8))
                    }
                    
                    Spacer()
                    
                    Button(action: { showProgrammedApproach = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Programados")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .background(Capsule().fill(Color.white).shadow(color: .black.opacity(0.05), radius: 8))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerSection
                        appsCard
                        scheduleCard
                        Spacer().frame(height: 140)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                }
            }

            if showCompletionModal {
                completionOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .zIndex(200)
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
        .sheet(isPresented: $showDurationSheet) { durationPickerSheet }
        .fullScreenCover(isPresented: $showProgrammedApproach) {
            NavigationStack {
                ProgrammedApproach()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cerrar") {
                                showProgrammedApproach = false
                            }
                            .foregroundColor(.black)
                        }
                    }
            }
        }
        .alert("Atención", isPresented: $showStartError) {
            Button("Entendido", role: .cancel) {}
        } message: {
            Text(startErrorMessage)
        }
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: "1A1A1A"), .black], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 70, height: 70)
                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                }
                .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)

                Text(completionTitle)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                Text(completionSubtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .padding(22)
            .frame(maxWidth: 320)
            .background(Color.white)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.12), radius: 30, x: 0, y: 18)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.86), value: showCompletionModal)
    }

    // MARK: - UI Components

    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Enfoque")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .tracking(-0.6)
                Text("Selecciona las apps que quieres bloquear y define cuánto tiempo quieres proteger tu atención.")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1A1A1A"), .black],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)

                Image(systemName: "target")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }

    private var appsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Aplicaciones")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                Text("\(selectedAppIDs.count) seleccionadas")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            VStack(spacing: 12) {
                ForEach(apps) { app in appRow(app) }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.88))
        )
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 18, x: 0, y: 10)
    }

    private func appRow(_ app: AppItem) -> some View {
        let isOn = selectedAppIDs.contains(app.id)
        return HStack(spacing: 14) {
            appIcon(assetName: app.iconAssetName, fallbackSystemName: app.fallbackSystemName, selected: isOn)

            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.system(size: 16, weight: .bold))

                Text(isOn ? "Se bloqueará durante el enfoque" : "Toca para bloquearla")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { newValue in
                    HapticManager.impact(style: .soft)
                    if newValue { selectedAppIDs.insert(app.id) } else { selectedAppIDs.remove(app.id) }
                }
            ))
            .labelsHidden()
            .tint(.black)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(isOn ? Color.black.opacity(0.04) : Color(hex: "FBFBFD"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isOn ? Color.black.opacity(0.10) : Color.black.opacity(0.04), lineWidth: 1)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: isOn)
    }

    private var scheduleCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Bloqueo")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                Button { showDurationSheet = true } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "timer")
                        Text(durationButtonTitle)
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.1), lineWidth: 1))
                }
            }

            ZStack {
                Circle().stroke(Color(hex: "F2F2F7"), lineWidth: 14).frame(width: 200, height: 200)
                Circle().trim(from: 0, to: ringProgress)
                    .stroke(LinearGradient(colors: [Color(hex: "1A1A1A"), .black], startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .frame(width: 200, height: 200).rotationEffect(.degrees(-90))
                countdownLabel
            }.frame(maxWidth: .infinity)

            Text(statusLabel).font(.system(size: 14, weight: .medium)).foregroundColor(.secondary).frame(maxWidth: .infinity)

            HStack(spacing: 12) {
                if isRunning {
                    Button(action: pause) { controlLabel(title: "Pausar", icon: "pause.fill", filled: false) }
                } else if canShowResume {
                    Button(action: resume) { controlLabel(title: "Continuar", icon: "play.fill", filled: true) }
                } else {
                    Button(action: start) { controlLabel(title: "Iniciar", icon: "play.fill", filled: true) }
                }
                Button(action: reset) { controlLabel(title: "Reiniciar", icon: "arrow.counterclockwise", filled: false) }
                    .disabled(!canReset).opacity(canReset ? 1 : 0.4)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.9))
        )
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 18, x: 0, y: 10)
    }

    // MARK: - FUNCIÓN CORREGIDA (controlLabel)
    private func controlLabel(title: String, icon: String, filled: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 15, weight: .bold))
            Text(title).font(.system(size: 16, weight: .bold))
        }
        .foregroundColor(filled ? .white : .black)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            ZStack {
                if filled {
                    RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.black)
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.white)
                    RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.black.opacity(0.1), lineWidth: 1)
                }
            }
        )
    }

    // MARK: - Logic & Helpers
    private var durationButtonTitle: String {
        guard let t = confirmedTotalSeconds, t > 0 else { return "Elegir tiempo" }
        return formattedDuration(TimeInterval(t))
    }

    private var ringProgress: CGFloat {
        guard totalDuration > 0 else { return 0 }
        return CGFloat(max(0, min(1, 1 - displayRemaining / totalDuration)))
    }

    private var totalDuration: TimeInterval { Double(confirmedTotalSeconds ?? 0) }
    private var displayRemaining: TimeInterval {
        if isRunning, let end = countdownEnd { return max(0, end.timeIntervalSinceNow) }
        return frozenRemaining
    }

    @ViewBuilder
    private var countdownLabel: some View {
        if isRunning, let end = countdownEnd {
            TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { context in
                let left = max(0, end.timeIntervalSince(context.date))
                Text(formattedCountdown(left)).font(.system(size: 44, weight: .bold, design: .rounded)).monospacedDigit()
                    .onChange(of: left) { newValue in if newValue <= 0.05 { finishCountdown() } }
            }
        } else {
            Text(confirmedTotalSeconds != nil ? formattedCountdown(displayRemaining) : "--:--")
                .font(.system(size: 44, weight: .bold, design: .rounded)).monospacedDigit()
                .foregroundColor(confirmedTotalSeconds != nil ? .primary : Color(.systemGray3))
        }
    }

    private var statusLabel: String {
        if isRunning { return "Bloqueo activo" }
        if canShowResume { return "Pausado" }
        return "Configura apps y duración"
    }

    private var canShowResume: Bool { !isRunning && frozenRemaining > 0 }
    private var canReset: Bool { isRunning || frozenRemaining > 0 }

    private func formattedCountdown(_ t: TimeInterval) -> String {
        let secs = Int(t); let m = (secs % 3600) / 60; let s = secs % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func formattedDuration(_ t: TimeInterval) -> String { "\(Int(t)/60) min" }

    private func confirmDuration() {
        let total = sheetHours * 3600 + sheetMinutes * 60
        confirmedTotalSeconds = total; frozenRemaining = TimeInterval(total)
        showDurationSheet = false
    }

    private func start() {
        guard !selectedAppIDs.isEmpty else { startErrorMessage = "Selecciona apps primero"; showStartError = true; return }
        guard let total = confirmedTotalSeconds, total > 0 else { startErrorMessage = "Selecciona el tiempo"; showStartError = true; return }
        countdownEnd = Date().addingTimeInterval(frozenRemaining)
        isRunning = true
    }

    private func pause() {
        if let end = countdownEnd { frozenRemaining = max(0, end.timeIntervalSinceNow) }
        countdownEnd = nil; isRunning = false
    }

    private func resume() {
        countdownEnd = Date().addingTimeInterval(frozenRemaining)
        isRunning = true
    }

    private func reset() {
        countdownEnd = nil; isRunning = false; frozenRemaining = Double(confirmedTotalSeconds ?? 0)
    }

    private func finishCountdown() {
        guard isRunning else { return }

        let blockedApps = apps.filter { selectedAppIDs.contains($0.id) }.map(\.name)
        countdownEnd = nil
        frozenRemaining = 0
        isRunning = false
        HapticManager.notification(type: .success)

        showCompletion(for: blockedApps)
    }

    private func showCompletion(for blockedApps: [String]) {
        completionTitle = "¡Bloqueo completado!"
        if blockedApps.isEmpty {
            completionSubtitle = "Cumpliste con el tiempo de bloqueo configurado."
        } else if blockedApps.count <= 3 {
            completionSubtitle = "Cumpliste el tiempo de bloqueo para: \(blockedApps.joined(separator: ", "))."
        } else {
            completionSubtitle = "Cumpliste el tiempo de bloqueo para \(blockedApps.count) aplicaciones seleccionadas."
        }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            showCompletionModal = true
        }

        selectedAppIDs.removeAll()
        confirmedTotalSeconds = nil
        frozenRemaining = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeOut(duration: 0.2)) {
                showCompletionModal = false
            }
        }
    }

    private var durationPickerSheet: some View {
        NavigationStack {
            VStack {
                Picker("Minutos", selection: $sheetMinutes) {
                    ForEach(1..<61) { Text("\($0) min").tag($0) }
                }
                .pickerStyle(.wheel)

                Button("Confirmar") { confirmDuration() }
                    .fontWeight(.bold)
                    .padding(.vertical, 10)
            }
            .navigationTitle("Tiempo").toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cerrar") { showDurationSheet = false } } }
        }
    }

    private func appIcon(assetName: String?, fallbackSystemName: String, selected: Bool) -> some View {
        Group {
            if let assetName {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: fallbackSystemName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .frame(width: 28, height: 28)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(selected ? Color.black.opacity(0.08) : Color.black.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(selected ? Color.black.opacity(0.10) : Color.black.opacity(0.04), lineWidth: 1)
        )
        .shadow(color: .black.opacity(selected ? 0.06 : 0.03), radius: 8, x: 0, y: 4)
        .accessibilityHidden(true)
    }
}
struct ApproachView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ApproachView()
            
            VStack {
                Spacer()
                CustomTabBarView(selectedTab: .constant(3), onAction: {})
            }
            .zIndex(100)
        }
    }
}
