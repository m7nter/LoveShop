import SwiftUI
import PhotosUI

struct SettingsView: View {
    @ObservedObject private var store = SettingsStore.shared
    @Environment(\.dismiss) var dismiss
    @State private var showPicker = false
    @State private var pickerItem: PhotosPickerItem?

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
                            PhotosPicker(selection: $pickerItem,
                                         matching: .images) {
                                Text("Выбрать фото")
                                    .foregroundColor(.orange)
                            }
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
        .onChange(of: pickerItem) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    await MainActor.run { store.avatarImage = img }
                }
            }
        }
    }
}
