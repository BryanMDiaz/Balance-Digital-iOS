//
//  MeditationSessionManager.swift
//  Balance-Digital
//
//  Controlador único de la sesión de meditación: posee el cronómetro Y el audio.
//  Tenerlos en el mismo objeto garantiza que el tiempo restante y la música
//  estén SIEMPRE sincronizados, y que la sesión siga corriendo en segundo plano
//  (mientras el audio suena con "Background Audio" activado, iOS no suspende la app).
//

import Foundation
import AVFoundation
import SwiftUI

// MARK: - Modo de meditación

enum MeditationMode: String, CaseIterable, Identifiable {
    case deepSleep = "Sueño profundo"
    case anxiety   = "Ansiedad"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .deepSleep: return "Relaja el cuerpo y prepara el descanso"
        case .anxiety:   return "Respira y recupera el centro"
        }
    }

    var icon: String {
        switch self {
        case .deepSleep: return "moon.stars.fill"
        case .anxiety:   return "wind"
        }
    }

    var accent: Color {
        switch self {
        case .deepSleep: return Color(hex: "5B7CFF")
        case .anxiety:   return Color(hex: "34C759")
        }
    }

    /// Nombre del archivo de audio en el bundle (sin extensión).
    /// Debes añadir `deepsleep.mp3` y `anxiety.mp3` (o .m4a) al target.
    var audioFileName: String {
        switch self {
        case .deepSleep: return "deepsleep"
        case .anxiety:   return "anxiety"
        }
    }
}

// MARK: - Controlador de la sesión

final class MeditationSessionManager: ObservableObject {

    /// ¿El cronómetro está corriendo?
    @Published private(set) var isRunning = false
    /// Segundos restantes (se actualiza ~5 veces por segundo).
    @Published private(set) var remaining: TimeInterval = 0
    /// Duración total configurada.
    @Published private(set) var totalDuration: TimeInterval = 0
    /// Modo actualmente configurado.
    @Published private(set) var currentMode: MeditationMode?

    /// Se incrementa cada vez que una sesión termina (señal para la vista).
    @Published private(set) var completionSignal = 0
    private(set) var lastCompletedMode: MeditationMode?
    private(set) var lastCompletedDuration: TimeInterval = 0

    private var player: AVAudioPlayer?
    private var ticker: Timer?
    private var endDate: Date?

    init() {
        configureAudioSession()
    }

    // MARK: - Sesión de audio (permite sonar en background y en silencio)
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            // .playback = sigue sonando en background y aunque el switch de silencio esté activo.
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("⚠️ Error configurando AVAudioSession: \(error)")
        }
    }

    // MARK: - Configurar (al confirmar modo + duración)
    func configure(mode: MeditationMode, duration: TimeInterval) {
        stopEverything()
        currentMode = mode
        totalDuration = duration
        remaining = duration
    }

    // MARK: - Iniciar
    func start() {
        guard let mode = currentMode else { return }
        if remaining <= 0.05 { remaining = totalDuration }
        guard remaining > 0 else { return }

        playAudio(for: mode)
        endDate = Date().addingTimeInterval(remaining)
        isRunning = true
        startTicker()
    }

    // MARK: - Pausar
    func pause() {
        guard isRunning else { return }
        if let endDate { remaining = max(0, endDate.timeIntervalSinceNow) }
        player?.pause()
        stopTicker()
        endDate = nil
        isRunning = false
    }

    // MARK: - Continuar
    func resume() {
        guard !isRunning, remaining > 0 else { return }
        player?.play()
        endDate = Date().addingTimeInterval(remaining)
        isRunning = true
        startTicker()
    }

    // MARK: - Reiniciar
    func reset() {
        let mode = currentMode
        let total = totalDuration
        stopEverything()
        currentMode = mode
        totalDuration = total
        remaining = total
    }

    // MARK: - Cronómetro
    private func startTicker() {
        stopTicker()
        // RunLoop .common: el timer sigue activo durante scroll. Junto con el audio
        // en background, el run loop permanece vivo y el timer dispara aunque la app
        // esté minimizada.
        let timer = Timer(timeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer, forMode: .common)
        ticker = timer
    }

    private func stopTicker() {
        ticker?.invalidate()
        ticker = nil
    }

    private func tick() {
        guard isRunning, let endDate else { return }
        let left = endDate.timeIntervalSinceNow
        if left <= 0.05 {
            remaining = 0
            finish()
        } else {
            remaining = left
        }
    }

    // MARK: - Finalizar (cronómetro a 0)
    private func finish() {
        let mode = currentMode
        let total = totalDuration
        stopEverything()
        remaining = 0

        lastCompletedMode = mode
        lastCompletedDuration = total
        completionSignal &+= 1   // avisa a la vista para mostrar el modal y registrar
    }

    private func stopEverything() {
        stopTicker()
        player?.stop()
        player = nil
        endDate = nil
        isRunning = false
    }

    // MARK: - Audio
    private func playAudio(for mode: MeditationMode) {
        // Si ya hay player cargado (p. ej. tras reanudar), solo reanuda.
        if let player {
            player.play()
            return
        }
        let url = Bundle.main.url(forResource: mode.audioFileName, withExtension: "mp3")
            ?? Bundle.main.url(forResource: mode.audioFileName, withExtension: "m4a")

        guard let url else {
            print("⚠️ No se encontró el audio '\(mode.audioFileName)'. El cronómetro funcionará sin sonido.")
            return
        }
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.numberOfLoops = -1   // bucle infinito = reproducción continua
            newPlayer.prepareToPlay()
            newPlayer.play()
            player = newPlayer
        } catch {
            print("⚠️ Error reproduciendo el audio: \(error)")
        }
    }
}
