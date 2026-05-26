//
//  MeditationView.swift
//  Balance Digital
//
//  Created by Bryan Programer on 7/4/26.
//
//  NOTA: el enum `MeditationMode` ahora vive en MeditationSessionManager.swift.
//

import SwiftUI

struct MeditationView: View {
    var onBack: () -> Void = {}

    // Controlador que posee el cronómetro + el audio.
    @StateObject private var manager = MeditationSessionManager()
    @EnvironmentObject var session: SessionManager

    // Configuración (modo + duración elegidos antes de iniciar)
    @State private var selectedMode: MeditationMode?
    @State private var confirmedTotalSeconds: Int?

    @State private var appearances = Array(repeating: false, count: 5)

    @State private var durationSheetMode: MeditationMode?
    @State private var sheetHours = 0
    @State private var sheetMinutes = 15

    @State private var showPlayConfigAlert = false
    @State private var showZeroDurationAlert = false
    @State private var showCompletionModal = false
    @State private var completionTitle = ""
    @State private var completionSubtitle = ""

    // MARK: - Derivados del manager
    private var isRunning: Bool { manager.isRunning }
    private var totalDuration: TimeInterval { manager.totalDuration }
    private var displayRemaining: TimeInterval { manager.remaining }

    private var sessionLocksCards: Bool {
        if manager.isRunning { return true }
        return manager.totalDuration > 0
            && manager.remaining > 0
            && manager.remaining < manager.totalDuration - 0.25
    }

    private var ringProgress: CGFloat {
        let total = totalDuration
        guard total > 0 else { return 0 }
        return CGFloat(max(0, min(1, 1 - displayRemaining / total)))
    }

    var body: some View {
        ZStack {
            Color(hex: "FBFBFD").ignoresSafeArea()

            Circle()
                .fill(Color.black.opacity(0.03))
                .frame(width: 380)
                .offset(x: 140, y: -220)
                .blur(radius: 80)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Group {
                        Spacer().frame(height: 8)
                        headerBlock
                            .offset(y: appearances[0] ? 0 : 16)
                            .opacity(appearances[0] ? 1 : 0)
                    }
                    Group {
                        Spacer().frame(height: 28)
                        modePicker
                            .offset(y: appearances[1] ? 0 : 16)
                            .opacity(appearances[1] ? 1 : 0)
                    }
                    Group {
                        Spacer().frame(height: 28)
                        timerCard
                            .offset(y: appearances[2] ? 0 : 16)
                            .opacity(appearances[2] ? 1 : 0)
                    }
                    Group {
                        Spacer().frame(height: 24)
                        controlButtons
                            .offset(y: appearances[3] ? 0 : 16)
                            .opacity(appearances[3] ? 1 : 0)
                    }
                    Group {
                        Spacer().frame(height: 20)
                        hintText
                            .offset(y: appearances[4] ? 0 : 16)
                            .opacity(appearances[4] ? 1 : 0)
                    }
                    Spacer().frame(height: 120)
                }
                .padding(.horizontal, 24)
            }

            if showCompletionModal {
                completionOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .zIndex(200)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack(spacing: 0) {
                backToDashboardButton
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 10)
            .background(Color(hex: "FBFBFD"))
        }
        .sheet(item: $durationSheetMode) { mode in
            durationPickerSheet(for: mode)
        }
        .alert("No puedes iniciar aún", isPresented: $showPlayConfigAlert) {
            Button("Entendido", role: .cancel) {}
        } message: {
            Text(playConfigAlertMessage)
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
        .onAppear { startSequence() }
        // Cuando el manager termina la sesión (incluso en background), reaccionamos aquí.
        .onChange(of: manager.completionSignal) { _ in
            handleCompletion()
        }
    }

    // MARK: - Fin de sesión: registro + modal
    private func handleCompletion() {
        let mode = manager.lastCompletedMode
        let totalSeconds = Int(manager.lastCompletedDuration)
        let minutes = totalSeconds / 60

        // 1) Registrar la sesión finalizada en la base de datos.
        MeditationManager.shared.registerCompletedSession(
            mode: mode?.rawValue ?? "Desconocido",
            durationSeconds: totalSeconds,
            userId: session.currentUser?.id
        )

        // 2) Sumar minutos al usuario logueado (se reflejan en Perfil).
        if let id = session.currentUser?.id,
           let updated = UserManager.shared.addMeditationMinutes(userId: id, minutes: minutes) {
            session.refresh(with: updated)
        }

        HapticManager.notification(type: .success)
        showCompletion(for: mode)
    }

    private var playConfigAlertMessage: String {
        if selectedMode == nil {
            return "Selecciona primero una tarjeta (Sueño profundo o Ansiedad) y confirma una duración en la ventana que se abre."
        }
        if confirmedTotalSeconds == nil || confirmedTotalSeconds == 0 {
            return "Debes elegir horas y minutos y pulsar Confirmar antes de iniciar el cronómetro."
        }
        return "Configura la sesión antes de dar play."
    }

    private func durationPickerSheet(for mode: MeditationMode) -> some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(mode.rawValue)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("¿Cuánto durará la sesión?")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 0) {
                    Picker("Horas", selection: $sheetHours) {
                        ForEach(0..<24, id: \.self) { h in Text("\(h) h").tag(h) }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)

                    Picker("Minutos", selection: $sheetMinutes) {
                        ForEach(0..<60, id: \.self) { m in Text("\(m) min").tag(m) }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 180)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        durationSheetMode = nil
                        HapticManager.impact(style: .light)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirmar") { confirmDuration(for: mode) }
                        .fontWeight(.bold)
                }
            }
            .alert("Duración no válida", isPresented: $showZeroDurationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Elige al menos 1 minuto (o más) para la sesión.")
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func confirmDuration(for mode: MeditationMode) {
        let total = sheetHours * 3600 + sheetMinutes * 60
        if total < 60 {
            showZeroDurationAlert = true
            HapticManager.notification(type: .error)
            return
        }
        selectedMode = mode
        confirmedTotalSeconds = total
        manager.configure(mode: mode, duration: TimeInterval(total))
        durationSheetMode = nil
        HapticManager.notification(type: .success)
    }

    private var backToDashboardButton: some View {
        Button {
            HapticManager.impact(style: .light)
            onBack()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4))
                .overlay(Circle().stroke(Color.black.opacity(0.06), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Volver al dashboard")
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: "1A1A1A"), .black],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
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
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.06), lineWidth: 1))
            .shadow(color: .black.opacity(0.12), radius: 30, x: 0, y: 18)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.86), value: showCompletionModal)
    }

    private var headerBlock: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.white).frame(width: 88, height: 88)
                    .shadow(color: .black.opacity(0.04), radius: 20, x: 0, y: 10)
                Circle()
                    .fill(LinearGradient(colors: [.black, Color(hex: "2D2D2D")],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 70, height: 70)
                Image(systemName: "leaf.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.white)
            }
            VStack(spacing: 6) {
                Text("Meditación")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .tracking(-0.6)
                Text("Elige un modo, confirma la duración y pulsa Iniciar")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var modePicker: some View {
        HStack(spacing: 12) {
            ForEach(MeditationMode.allCases) { mode in
                modeChip(mode)
            }
        }
    }

    private func modeChip(_ mode: MeditationMode) -> some View {
        let selected = selectedMode == mode
        return Button {
            guard !sessionLocksCards else { return }
            sheetHours = 0
            sheetMinutes = 15
            durationSheetMode = mode
            HapticManager.impact(style: .light)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: mode.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(selected ? .white : mode.accent)
                    .frame(width: 44, height: 44)
                    .background(selected ? mode.accent.opacity(0.35) : mode.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(selected ? .white : .primary)
                    Text(mode.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(selected ? .white.opacity(0.85) : .secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                Group {
                    if selected {
                        LinearGradient(colors: [Color(hex: "1A1A1A"), .black],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else {
                        Color.white
                    }
                }
            )
            .cornerRadius(22)
            .overlay(RoundedRectangle(cornerRadius: 22)
                .stroke(selected ? Color.clear : Color.black.opacity(0.06), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(sessionLocksCards)
        .opacity(sessionLocksCards && !selected ? 0.5 : 1)
    }

    private var timerCard: some View {
        let accent = selectedMode?.accent ?? Color(hex: "C7C7CC")
        return VStack(spacing: 20) {
            Text(timerCardTitle)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)

            ZStack {
                Circle()
                    .stroke(Color(hex: "F2F2F7"), lineWidth: 14)
                    .frame(width: 220, height: 220)

                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        LinearGradient(colors: [accent, accent.opacity(0.5)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.25), value: ringProgress)

                countdownLabel
            }

            Text(timerStatusLabel)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(28)
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.black.opacity(0.05), lineWidth: 1))
    }

    private var timerCardTitle: String {
        guard let m = selectedMode else { return "Sin modo" }
        return m == .deepSleep ? "Sueño profundo" : "Manejo de ansiedad"
    }

    @ViewBuilder
    private var countdownLabel: some View {
        let hasConfig = selectedMode != nil && (confirmedTotalSeconds ?? 0) > 0
        Text(hasConfig || isRunning ? formattedCountdown(displayRemaining) : "--:--")
            .font(.system(size: 44, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundColor(hasConfig || isRunning ? .primary : Color(.systemGray3))
    }

    private var timerStatusLabel: String {
        if isRunning { return "En curso" }
        if totalDuration > 0, displayRemaining > 0, displayRemaining < totalDuration - 0.25 {
            return "Pausado"
        }
        if totalDuration > 0, displayRemaining <= 0.05 {
            return "Tiempo completado"
        }
        if confirmedTotalSeconds != nil {
            return "Listo para comenzar"
        }
        return "Configura modo y duración"
    }

    private var controlButtons: some View {
        HStack(spacing: 12) {
            if isRunning {
                Button(action: pause) {
                    controlLabel(title: "Pausar", icon: "pause.fill", filled: false)
                }
            } else if canShowResume {
                Button(action: resume) {
                    controlLabel(title: "Continuar", icon: "play.fill", filled: true)
                }
            } else {
                Button(action: start) {
                    controlLabel(title: "Iniciar", icon: "play.fill", filled: true)
                }
            }

            Button(action: reset) {
                controlLabel(title: "Reiniciar", icon: "arrow.counterclockwise", filled: false)
            }
            .disabled(!canReset)
            .opacity(canReset ? 1 : 0.45)
        }
    }

    private var canShowResume: Bool {
        !isRunning && displayRemaining > 0
            && totalDuration > 0 && displayRemaining < totalDuration - 0.25
    }

    private func controlLabel(title: String, icon: String, filled: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 15, weight: .bold))
            Text(title).font(.system(size: 16, weight: .bold))
        }
        .foregroundColor(filled ? .white : .black)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            Group {
                if filled {
                    RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.black)
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.black.opacity(0.1), lineWidth: 1))
                }
            }
        )
    }

    private var hintText: some View {
        Text(hintForMode)
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }

    private var hintForMode: String {
        guard let m = selectedMode else {
            return "Selecciona Sueño profundo o Ansiedad para abrir la duración."
        }
        switch m {
        case .deepSleep: return "Afloja la mandíbula, inhala lento por la nariz y exhala por la boca."
        case .anxiety:   return "4 segundos inhalar, 4 sostener, 6 exhalar. Repite a tu ritmo."
        }
    }

    private var canReset: Bool {
        isRunning
            || (totalDuration > 0 && displayRemaining < totalDuration - 0.25)
            || (totalDuration > 0 && displayRemaining <= 0.05)
    }

    private func formattedCountdown(_ t: TimeInterval) -> String {
        let secs = max(0, Int(t.rounded(.down)))
        let h = secs / 3600
        let m = (secs % 3600) / 60
        let s = secs % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Controles (delegan en el manager)
    private func start() {
        guard let mode = selectedMode,
              let t = confirmedTotalSeconds, t >= 60 else {
            showPlayConfigAlert = true
            HapticManager.notification(type: .error)
            return
        }
        if manager.totalDuration == 0 {
            manager.configure(mode: mode, duration: TimeInterval(t))
        }
        manager.start()
        HapticManager.impact(style: .medium)
    }

    private func pause() {
        manager.pause()
        HapticManager.impact(style: .light)
    }

    private func resume() {
        manager.resume()
        HapticManager.impact(style: .medium)
    }

    private func reset() {
        guard canReset else { return }
        manager.reset()
        HapticManager.notification(type: .success)
    }

    private func showCompletion(for mode: MeditationMode?) {
        completionTitle = "¡Excelente trabajo!"
        switch mode {
        case .deepSleep:
            completionSubtitle = "Has completado tu descanso de sueño profundo. Tómate un momento para sentir cómo tu cuerpo se relaja y tu mente se calma."
        case .anxiety:
            completionSubtitle = "Has completado tu sesión de meditación para el manejo de la ansiedad. Respira suave: lo estás haciendo muy bien."
        case .none:
            completionSubtitle = "Has completado tu sesión. Respira y date un momento para volver con calma."
        }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            showCompletionModal = true
        }

        // Limpiar para empezar de nuevo.
        selectedMode = nil
        confirmedTotalSeconds = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeOut(duration: 0.2)) {
                showCompletionModal = false
            }
        }
    }

    private func startSequence() {
        for i in 0..<appearances.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                    appearances[i] = true
                }
            }
        }
    }
}

struct MeditationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            MeditationView(onBack: {})
                .environmentObject(SessionManager.shared)

            VStack {
                Spacer()
                CustomTabBarView(selectedTab: .constant(1), onAction: {})
            }
            .zIndex(100)
        }
    }
}
