import SwiftUI

struct PhotoDetailView: View {
    let url: URL
    let onDelete: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var showEditor = false
    @State private var currentImage: UIImage?
    @State private var editedImage: UIImage?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let img = currentImage {
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
                        Button {
                            showEditor = true
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
        .onChange(of: showEditor) { isShowing in
            if !isShowing, let edited = editedImage {
                currentImage = edited
                editedImage = nil
            }
        }
        .fullScreenCover(isPresented: $showEditor) {
            if let img = currentImage {
                PhotoEditorView(image: img) { edited in
                    // Сохраняем файл
                    if let data = edited.jpegData(compressionQuality: 0.92) {
                        try? data.write(to: url)
                    }
                    editedImage = edited
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
