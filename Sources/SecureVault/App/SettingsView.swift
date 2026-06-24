import SwiftUI

struct SettingsView: View {
    @ObservedObject private var store = SettingsStore.shared
    @Environment(\.dismiss) var dismiss
    @State private var showPicker = false

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

                    if store.showCrosshair {
                        HStack {
                            Text("Цвет")
                            Spacer()
                            ForEach(["white", "red", "green", "yellow"], id: \.self) { colorName in
                                Circle()
                                    .fill(color(for: colorName))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: store.crosshairColor == colorName ? 2 : 0)
                                    )
                                    .onTapGesture { store.crosshairColor = colorName }
                            }
                        }
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
        .sheet(isPresented: $showPicker) {
            ImagePicker { img in store.avatarImage = img }
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
