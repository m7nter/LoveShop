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
            ImagePicker { img in
                store.avatarImage = img
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    let onSelect: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onSelect: (UIImage) -> Void

        init(onSelect: @escaping (UIImage) -> Void) {
            self.onSelect = onSelect
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let img = info[.originalImage] as? UIImage {
                onSelect(img)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
