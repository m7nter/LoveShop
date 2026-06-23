import SwiftUI

struct SettingsView: View {
    @ObservedObject private var store = SettingsStore.shared
    @Environment(\.dismiss) var dismiss
    @State private var showPicker = false
    @State private var crashLog: String = ""

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
                            Button("Выбрать фото") {
                                showPicker = true
                            }
                            .foregroundColor(.orange)

                            if store.avatarImage != nil {
                                Button("Удалить") {
                                    store.avatarImage = nil
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Диагностика") {
                    Button("Копировать лог краша") {
                        UIPasteboard.general.string = crashLog.isEmpty ? "Логов нет" : crashLog
                    }
                    .foregroundColor(.orange)

                    if !crashLog.isEmpty {
                        Text(crashLog)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }

                Section("Подсказка") {
                    Text("Фото отображается в правом нижнем углу каждого снимка")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") { dismiss() }
                        .foregroundColor(.orange)
                }
            }
        }
        .onAppear {
            loadCrashLog()
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker { img in
                store.avatarImage = img
            }
        }
    }

    private func loadCrashLog() {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        if let cachePath = paths.first {
            let logPath = cachePath + "/crash.log"
            crashLog = (try? String(contentsOfFile: logPath)) ?? "Логов нет"
        }
    }
}
