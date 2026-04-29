//
//  ProgrammedApproach.swift
//  BalanceDigitalApp
//
//  Created by Bryan_Dev on 13/4/26.
//

import SwiftUI

struct ProgrammedApproach: View {
    private struct AppOption: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let assetName: String
    }

    private struct ScheduleRule: Identifiable {
        var id = UUID()
        var title: String
        var days: [String]
        var start: Date
        var end: Date
        var apps: [String]
        var enabled: Bool
    }

    @State private var isProgrammedEnabled = true
    @State private var selectedDays: Set<String> = []
    @State private var startTime = ProgrammedApproach.makeTime(hour: 21, minute: 0)
    @State private var endTime = ProgrammedApproach.makeTime(hour: 22, minute: 30)
    @State private var selectedApps: Set<String> = []
    @State private var showingSaveRuleModal = false
    @State private var newRuleName = ""
    @State private var editingRuleId: UUID? = nil
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    @State private var rules: [ScheduleRule] = [
        .init(
            title: "Noches de enfoque",
            days: ["L", "M", "X", "J", "V"],
            start: ProgrammedApproach.makeTime(hour: 21, minute: 0),
            end: ProgrammedApproach.makeTime(hour: 22, minute: 30),
            apps: ["TikTok", "Instagram", "YouTube"],
            enabled: true
        ),
        .init(
            title: "Sábado sin scroll",
            days: ["S"],
            start: ProgrammedApproach.makeTime(hour: 10, minute: 0),
            end: ProgrammedApproach.makeTime(hour: 12, minute: 0),
            apps: ["Facebook", "X"],
            enabled: false
        )
    ]

    private let dayOrder = ["L", "M", "X", "J", "V", "S", "D"]

    private let appOptions: [AppOption] = [
        .init(name: "TikTok", assetName: "tiktok"),
        .init(name: "Instagram", assetName: "instagram"),
        .init(name: "YouTube", assetName: "youtube"),
        .init(name: "WhatsApp", assetName: "whatsapp"),
        .init(name: "Telegram", assetName: "telegram"),
        .init(name: "Safari", assetName: "safari-2"),
        .init(name: "Facebook", assetName: "facebook"),
        .init(name: "Spotify", assetName: "spotify"),
        .init(name: "ChatGPT", assetName: "chatgpt")
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemGray6), Color(.systemGray5).opacity(0.35), .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.black.opacity(0.05))
                .frame(width: 280)
                .offset(x: 170, y: -220)
                .blur(radius: 70)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    headerCard
                    scheduleCard
                    appSelectionCard
                    saveButton
                    rulesCard
                    Spacer().frame(height: 18)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Bloqueos Programados")
        .alert("Guardar regla", isPresented: $showingSaveRuleModal) {
            TextField("Nombre de la regla", text: $newRuleName)
            Button("Cancelar", role: .cancel) { }
            Button("Guardar") {
                saveNewRule()
            }
        } message: {
            Text("Ingresa un nombre para tu nueva regla de bloqueo programado.")
        }
        .alert("Datos incompletos", isPresented: $showErrorAlert) {
            Button("Entendido", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Programacion inteligente")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text("Configura horarios fijos para bloquear distracciones automáticamente.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            HStack {
                Text("Activar bloqueo programado")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Toggle("", isOn: $isProgrammedEnabled)
                    .labelsHidden()
                    .tint(.black)
            }
            .padding(12)
            .background(Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
    }

    private var scheduleCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Horario")
                .font(.system(size: 18, weight: .bold, design: .rounded))

            HStack(spacing: 10) {
                ForEach(dayOrder, id: \.self) { day in
                    let selected = selectedDays.contains(day)
                    Button {
                        toggleDay(day)
                    } label: {
                        Text(day)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(selected ? .white : .black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 34)
                            .background(selected ? Color.black : Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Inicio")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Fin")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            Text(nextBlockSummary)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.top, 2)
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var appSelectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Apps a bloquear")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                Text("\(selectedApps.count) seleccionadas")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 94), spacing: 10)], spacing: 10) {
                ForEach(appOptions) { app in
                    let selected = selectedApps.contains(app.name)
                    Button {
                        toggleApp(app.name)
                    } label: {
                        VStack(spacing: 8) {
                            Image(app.assetName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                            Text(app.name)
                                .font(.system(size: 12, weight: .semibold))
                                .lineLimit(1)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 78)
                        .background(selected ? Color.black.opacity(0.08) : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(selected ? Color.black.opacity(0.18) : Color.black.opacity(0.05), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var rulesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Reglas guardadas")
                .font(.system(size: 18, weight: .bold, design: .rounded))

            ForEach(Array(rules.enumerated()), id: \.element.id) { index, rule in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(rule.title)
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { rules[index].enabled },
                            set: { rules[index].enabled = $0 }
                        ))
                        .labelsHidden()
                        .tint(.black)
                        
                        Menu {
                            Button {
                                loadRule(at: index)
                            } label: {
                                Label("Modificar", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                deleteRule(at: index)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(.systemGray3))
                                .padding(.leading, 6)
                        }
                    }

                    Text("\(rule.days.joined(separator: " "))  |  \(timeString(rule.start)) - \(timeString(rule.end))")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)

                    Text("Apps: \(rule.apps.joined(separator: ", "))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var isFormValid: Bool {
        let cal = Calendar.current
        let startComps = cal.dateComponents([.hour, .minute], from: startTime)
        let endComps = cal.dateComponents([.hour, .minute], from: endTime)
        let hasSameTime = (startComps.hour == endComps.hour) && (startComps.minute == endComps.minute)
        return !selectedDays.isEmpty && !selectedApps.isEmpty && !hasSameTime
    }

    private var saveButton: some View {
        VStack(spacing: 12) {
            Button {
                validateAndProceed()
            } label: {
                HStack {
                    Image(systemName: editingRuleId == nil ? "square.and.arrow.down" : "checkmark.circle")
                    Text(editingRuleId == nil ? "Guardar como nueva regla" : "Guardar cambios")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(isFormValid ? .white : Color(.systemGray))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(isFormValid ? Color.black : Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: isFormValid ? .black.opacity(0.15) : .clear, radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isFormValid ? Color.clear : Color(.systemGray4), lineWidth: 1)
                )
            }
            
            if editingRuleId != nil {
                Button {
                    editingRuleId = nil
                    newRuleName = ""
                } label: {
                    Text("Cancelar edición")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.red)
                }
            }
        }
    }

    private func validateAndProceed() {
        if selectedDays.isEmpty {
            errorMessage = "Por favor selecciona al menos un día para el bloqueo."
            showErrorAlert = true
            return
        }
        
        let cal = Calendar.current
        let startComps = cal.dateComponents([.hour, .minute], from: startTime)
        let endComps = cal.dateComponents([.hour, .minute], from: endTime)
        if startComps.hour == endComps.hour && startComps.minute == endComps.minute {
            errorMessage = "La hora de inicio y fin no pueden ser la misma."
            showErrorAlert = true
            return
        }
        
        if selectedApps.isEmpty {
            errorMessage = "Debes seleccionar al menos una aplicación para bloquear."
            showErrorAlert = true
            return
        }
        
        if editingRuleId == nil {
            newRuleName = ""
        }
        showingSaveRuleModal = true
    }

    private func saveNewRule() {
        let titleToSave = newRuleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Nueva regla" : newRuleName
        
        if let editingId = editingRuleId, let index = rules.firstIndex(where: { $0.id == editingId }) {
            rules[index].title = titleToSave
            rules[index].days = selectedDays.sorted(by: daySort)
            rules[index].start = startTime
            rules[index].end = endTime
            rules[index].apps = Array(selectedApps)
            editingRuleId = nil
            self.newRuleName = ""
        } else {
            let newRule = ScheduleRule(
                title: titleToSave,
                days: selectedDays.sorted(by: daySort),
                start: startTime,
                end: endTime,
                apps: Array(selectedApps),
                enabled: true
            )
            rules.append(newRule)
        }
    }

    private func loadRule(at index: Int) {
        let rule = rules[index]
        selectedDays = Set(rule.days)
        startTime = rule.start
        endTime = rule.end
        selectedApps = Set(rule.apps)
        editingRuleId = rule.id
        newRuleName = rule.title
    }

    private func deleteRule(at index: Int) {
        let ruleId = rules[index].id
        withAnimation {
            rules.remove(at: index)
            if editingRuleId == ruleId {
                editingRuleId = nil
            }
        }
    }

    private var nextBlockSummary: String {
        if !isProgrammedEnabled {
            return "La programación está desactivada."
        }
        let days = selectedDays.sorted(by: daySort)
        let dayText = days.isEmpty ? "sin días" : days.joined(separator: " ")
        return "Próximo bloqueo: \(dayText)  |  \(timeString(startTime)) - \(timeString(endTime))"
    }

    private func toggleDay(_ day: String) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }

    private func toggleApp(_ appName: String) {
        if selectedApps.contains(appName) {
            selectedApps.remove(appName)
        } else {
            selectedApps.insert(appName)
        }
    }

    private func daySort(_ lhs: String, _ rhs: String) -> Bool {
        (dayOrder.firstIndex(of: lhs) ?? 0) < (dayOrder.firstIndex(of: rhs) ?? 0)
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private static func makeTime(hour: Int, minute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
}

struct ProgrammedApproach_Previews: PreviewProvider {
    static var previews: some View {
        ProgrammedApproach()
    }
}
