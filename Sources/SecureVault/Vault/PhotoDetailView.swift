import SwiftUI

struct PhotoDetailView: View {
    let url: URL
    let onDelete: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var showEditor = false
    @State private var currentImage: UIImage?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let img = currentImage ?? loadImage() {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            VStack {
                HStack {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                    Spacer()
                    HStack(spacing: 12) {
                        // Кнопка редактирования
                        Button {
                            if let img = currentImage ?? loadImage() {
                                currentImage = img
                                showEditor = true
                            }
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }

                        Button {
                            onDelete()
                            dismiss()
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .padding(10)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 60)
                Spacer()
            }
        }
        .onAppear {
            currentImage = loadImage()
        }
        .fullScreenCover(isPresented: $showEditor) {
            if let img = currentImage {
                PhotoEditorView(image: img) { edited in
                    // Перезаписываем файл
                    if let data = edited.jpegData(compressionQuality: 0.95) {
                        try? data.write(to: url)
                    }
                    currentImage = edited
                    showEditor = false
                } onDiscard: {
                    showEditor = false
                }
            }
        }
    }

    private func loadImage() -> UIImage? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
