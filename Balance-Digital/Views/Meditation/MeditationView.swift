//
//  MeditationView.swift
//  Balance Digital
//
//  Created by Bryan Programer on 7/4/26.
//

import SwiftUI

// MARK: - Modo de sesión

private enum MeditationMode: String, CaseIterable, Identifiable {
    case deepSleep = "Sueño profundo"
    case anxiety = "Ansiedad"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .deepSleep:
            return "Relaja el cuerpo y prepara el descanso"
        case .anxiety:
            return "Respira y recupera el centro"
        }
    }

    var icon: String {
        switch self {
        case .deepSleep: return "moon.stars.fill"
        case .anxiety: return "wind"
        }
    }

    var accent: Color {
        switch self {
        case .deepSleep: return Color(hex: "5B7CFF")
        case .anxiety: return Color(hex: "34C759")
        }
    }
}

// MARK: - Vista

struct MeditationView: View {
    var onBack: () -> Void = {}

    @State private var selectedMode: MeditationMode?
    @State private var confirmedTotalSeconds: Int?
    /// Tiempo restante cuando no corre el reloj (listo o en pausa).
    @State private var frozenRemaining: TimeInterval = 0
    @State private var countdownEnd: Date?
    @State private var isRunning = false

    @State private var appearances = Array(repeating: false, count: 5)

    @State private var durationSheetMode: MeditationMode?
    @State private var sheetHours = 0
    @State private var sheetMinutes = 15

    @State private var showPlayConfigAlert = false
    @State private var showZeroDurationAlert = false
    @State private var hasCompletedCountdown = false
    @State private var showCompletionModal = false
    @State private var completionTitle = ""
    @State private var completionSubtitle = ""
    @State private var selectedTab = -1

    private var totalDuration: TimeInterval {
        Double(confirmedTotalSeconds ?? 0)
    }

    private var displayRemaining: TimeInterval {
        if isRunning, let end = countdownEnd {
            return max(0, end.timeIntervalSinceNow)
        }
        return frozenRemaining
    }

    /// No se puede cambiar de tarjeta mientras corre o si ya hubo avance en la cuenta atrás.
    private var sessionLocksCards: Bool {
        guard let total = confirmedTotalSeconds else { return isRunning }
        if isRunning { return true }
        return frozenRemaining < Double(total) - 0.25
    }

    private var ringProgress: CGFloat {
        let total = totalDuration
        guard total > 0 else { return 0 }
        let left = displayRemaining
        return CGFloat(max(0, min(1, 1 - left / total)))
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
                        ForEach(0..<24, id: \.self) { h in
                            Text("\(h) h").tag(h)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)

                    Picker("Minutos", selection: $sheetMinutes) {
                        ForEach(0..<60, id: \.self) { m in
                            Text("\(m) min").tag(m)
                        }
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
                    Button("Confirmar") {
                        confirmDuration(for: mode)
                    }
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
        frozenRemaining = TimeInterval(total)
        countdownEnd = nil
        isRunning = false
        hasCompletedCountdown = false
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
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                )
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Volver al dashboard")
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { /* no-op: se cierra sola */ }

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

    private var headerBlock: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 88, height: 88)
                    .shadow(color: .black.opacity(0.04), radius: 20, x: 0, y: 10)
                Circle()
                    .fill(LinearGradient(
                        colors: [.black, Color(hex: "2D2D2D")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
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
                        LinearGradient(
                            colors: [Color(hex: "1A1A1A"), .black],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.white
                    }
                }
            )
            .cornerRadius(22)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(selected ? Color.clear : Color.black.opacity(0.06), lineWidth: 1)
            )
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
                        LinearGradient(
                            colors: [accent, accent.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.35), value: ringProgress)

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
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }

    private var timerCardTitle: String {
        guard let m = selectedMode else { return "Sin modo" }
        return m == .deepSleep ? "Sueño profundo" : "Manejo de ansiedad"
    }

    @ViewBuilder
    private var countdownLabel: some View {
        let hasConfig = selectedMode != nil && (confirmedTotalSeconds ?? 0) > 0
        if isRunning, let end = countdownEnd {
            TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { context in
                let left = max(0, end.timeIntervalSince(context.date))
                Text(formattedCountdown(left))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.primary)
                    .onChange(of: left) { newValue in
                        if newValue <= 0.05 {
                            completeCountdownIfNeeded()
                        }
                    }
            }
        } else {
            Text(hasConfig ? formattedCountdown(displayRemaining) : "--:--")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(hasConfig ? .primary : Color(.systemGray3))
        }
    }

    private func completeCountdownIfNeeded() {
        guard isRunning, !hasCompletedCountdown else { return }
        hasCompletedCountdown = true
        finishCountdown()
    }

    private var timerStatusLabel: String {
        if isRunning { return "En curso" }
        if let t = confirmedTotalSeconds, frozenRemaining > 0, frozenRemaining < Double(t) - 0.25 {
            return "Pausado"
        }
        if let t = confirmedTotalSeconds, frozenRemaining <= 0.05, t > 0, !isRunning {
            return "Tiempo completado"
        }
        if confirmedTotalSeconds != nil {
            return "Listo para comenzar"
        }
        return "Configura modo y duración"
    }

    private var controlButtons: some View {
        VStack(spacing: 12) {
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
    }

    private var canShowResume: Bool {
        guard let t = confirmedTotalSeconds else { return false }
        return !isRunning && frozenRemaining > 0 && frozenRemaining < Double(t) - 0.25
    }

    private func controlLabel(title: String, icon: String, filled: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
            Text(title)
                .font(.system(size: 16, weight: .bold))
        }
        .foregroundColor(filled ? .white : .black)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            Group {
                if filled {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.black)
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
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
        case .deepSleep:
            return "Afloja la mandíbula, inhala lento por la nariz y exhala por la boca."
        case .anxiety:
            return "4 segundos inhalar, 4 sostener, 6 exhalar. Repite a tu ritmo."
        }
    }

    private var canReset: Bool {
        isRunning
            || (confirmedTotalSeconds != nil
                && frozenRemaining < Double(confirmedTotalSeconds!) - 0.25)
            || (confirmedTotalSeconds != nil && frozenRemaining <= 0.05)
    }

    private func formattedCountdown(_ t: TimeInterval) -> String {
        let secs = max(0, Int(t.rounded(.down)))
        let h = secs / 3600
        let m = (secs % 3600) / 60
        let s = secs % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    private func start() {
        if selectedMode == nil || confirmedTotalSeconds == nil || confirmedTotalSeconds! < 60 {
            showPlayConfigAlert = true
            HapticManager.notification(type: .error)
            return
        }
        if frozenRemaining <= 0.05 {
            frozenRemaining = Double(confirmedTotalSeconds!)
        }
        hasCompletedCountdown = false
        countdownEnd = Date().addingTimeInterval(frozenRemaining)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            isRunning = true
        }
        HapticManager.impact(style: .medium)
    }

    private func pause() {
        guard isRunning, let end = countdownEnd else { return }
        frozenRemaining = max(0, end.timeIntervalSinceNow)
        countdownEnd = nil
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            isRunning = false
        }
        HapticManager.impact(style: .light)
    }

    private func resume() {
        guard frozenRemaining > 0 else { return }
        countdownEnd = Date().addingTimeInterval(frozenRemaining)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            isRunning = true
        }
        HapticManager.impact(style: .medium)
    }

    private func reset() {
        guard canReset else { return }
        countdownEnd = nil
        hasCompletedCountdown = false
        if let t = confirmedTotalSeconds {
            frozenRemaining = Double(t)
        } else {
            frozenRemaining = 0
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            isRunning = false
        }
        HapticManager.notification(type: .success)
    }

    private func finishCountdown() {
        guard isRunning else { return }
        let completedMode = selectedMode
        countdownEnd = nil
        frozenRemaining = 0
        isRunning = false

        HapticManager.notification(type: .success)
        showCompletion(for: completedMode)
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

        // Deseleccionar tarjetas y limpiar duración para empezar de nuevo.
        selectedMode = nil
        confirmedTotalSeconds = nil
        frozenRemaining = 0
        hasCompletedCountdown = false

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
            
            VStack {
                Spacer()
                CustomTabBarView(selectedTab: .constant(1), onAction: {})
            }
            .zIndex(100)
        }
    }
}
