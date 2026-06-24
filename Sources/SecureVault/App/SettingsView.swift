import SwiftUI

struct SettingsView: View {
    @ObservedObject private var store = SettingsStore.shared
    @Environment(\.dismiss) var dismiss
    @State private var showPicker = false
    @State private var showChangeMain = false
    @State private var showChangeVault = false
    @State private var showChangeKamikaze = false

    var body: some View {
        NavigationView {
            List {
                Section("Фото на снимках") {
                    HStack(spacing: 16) {
                        if let img = store.avatarImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                )
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Button("Выбрать фото") { showPicker = true }
                                .foregroundColor(.orange)
                            if store.avatarImage != nil {
                                Button("Удалить") { store.avatarImage = nil }
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Прицел") {
                    Toggle("Показывать перекрестие", isOn: $store.showCrosshair)
                        .tint(.orange)
                    Toggle("Перекрестие на фото", isOn: $store.crosshairOnPhoto)
                        .tint(.orange)
                    if store.showCrosshair {
                        HStack {
                            Text("Цвет")
                            Spacer()
                            ForEach(["white", "red", "green", "yellow"], id: \.self) { colorName in
                                Circle()
                                    .fill(color(for: colorName))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle().stroke(Color.white,
                                                        lineWidth: store.crosshairColor == colorName ? 2 : 0)
                                    )
                                    .onTapGesture { store.crosshairColor = colorName }
                            }
                        }
                    }
                }

                Section("Безопасность") {
                    Button("Изменить основной пароль") { showChangeMain = true }
                        .foregroundColor(.orange)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Пароль хранилища")
                            Text(store.vaultCodeEnabled ? "Включён" : "Выключен")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { store.vaultCodeEnabled },
                            set: {
                                if $0 && store.vaultCode.isEmpty { showChangeVault = true }
                                else { store.vaultCodeEnabled = $0 }
                            }
                        )).tint(.orange).labelsHidden()
                    }
                    if store.vaultCodeEnabled {
                        Button("Изменить пароль хранилища") { showChangeVault = true }
                            .foregroundColor(.orange)
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Пароль-камикадзе")
                            Text(store.kamikazeCodeEnabled ? "При вводе удалит все фото" : "Выключен")
                                .font(.caption)
                                .foregroundColor(store.kamikazeCodeEnabled ? .red : .secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { store.kamikazeCodeEnabled },
                            set: {
                                if $0 && store.kamikazeCode.isEmpty { showChangeKamikaze = true }
                                else { store.kamikazeCodeEnabled = $0 }
                            }
                        )).tint(.red).labelsHidden()
                    }
                    if store.kamikazeCodeEnabled {
                        Button("Изменить пароль-камикадзе") { showChangeKamikaze = true }
                            .foregroundColor(.red)
                    }
                }

                Section("Автоблокировка") {
                    Picker("Блокировать через", selection: $store.autoLockTimeout) {
                        Text("Выключено").tag(0)
                        Text("1 минуту").tag(60)
                        Text("5 минут").tag(300)
                        Text("15 минут").tag(900)
                        Text("30 минут").tag(1800)
                    }
                }

                Section("Подсказка") {
                    Text("Фото отображается в правом нижнем углу каждого снимка")
                        .font(.caption).foregroundColor(.secondary)
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") { dismiss() }.foregroundColor(.orange)
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker { img in store.avatarImage = img }
        }
        .sheet(isPresented: $showChangeMain) {
            ChangeCodeView(title: "Основной пароль", currentCode: store.mainCode, requireCurrent: true) {
                store.mainCode = $0
            }
        }
        .sheet(isPresented: $showChangeVault) {
            ChangeCodeView(title: "Пароль хранилища", currentCode: store.vaultCode, requireCurrent: !store.vaultCode.isEmpty) {
                store.vaultCode = $0
                store.vaultCodeEnabled = true
            }
        }
        .sheet(isPresented: $showChangeKamikaze) {
            ChangeCodeView(title: "Пароль-камикадзе", currentCode: store.kamikazeCode, requireCurrent: !store.kamikazeCode.isEmpty) {
                store.kamikazeCode = $0
                store.kamikazeCodeEnabled = true
            }
        }
    }

    private func color(for name: String) -> Color {
        switch name {
        case "red": return .red
        case "green": return .green
        case "yellow": return .yellow
        default: return .white
        }
    }
}

struct ChangeCodeView: View {
    let title: String
    let currentCode: String
    let requireCurrent: Bool
    let onSave: (String) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var oldCode = ""
    @State private var newCode = ""
    @State private var confirmCode = ""
    @State private var error = ""

    var body: some View {
        NavigationView {
            Form {
                if requireCurrent {
                    Section("Текущий пароль") {
                        SecureField("Введите текущий пароль", text: $oldCode)
                            .keyboardType(.numberPad)
                    }
                }
                Section("Новый пароль") {
                    SecureField("Введите новый пароль", text: $newCode)
                        .keyboardType(.numberPad)
                    SecureField("Повторите новый пароль", text: $confirmCode)
                        .keyboardType(.numberPad)
                }
                if !error.isEmpty {
                    Section {
                        Text(error).foregroundColor(.red).font(.caption)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }.foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") { save() }.foregroundColor(.orange)
                }
            }
        }
    }

    private func save() {
        if requireCurrent && oldCode != currentCode {
            error = "Неверный текущий пароль"; return
        }
        if newCode.count < 4 {
            error = "Пароль должен быть не менее 4 символов"; return
        }
        if newCode != confirmCode {
            error = "Пароли не совпадают"; return
        }
        onSave(newCode)
        dismiss()
    }
}
