import SwiftUI

struct PhotoDetailView: View {
    let urls: [URL]
    let initialIndex: Int
    let onDelete: (URL) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var currentIndex: Int
    @State private var showEditor = false
    @State private var currentImage: UIImage?
    @State private var showDeleteConfirm = false
    @State private var dragOffset: CGFloat = 0

    init(urls: [URL], initialIndex: Int, onDelete: @escaping (URL) -> Void) {
        self.urls = urls
        self.initialIndex = initialIndex
        self.onDelete = onDelete
        self._currentIndex = State(initialValue: initialIndex)
    }

    private var currentURL: URL {
        urls[min(max(currentIndex, 0), urls.count - 1)]
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let img = currentImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(x: dragOffset)
                    .animation(.interactiveSpring(), value: dragOffset)
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
                    if urls.count > 1 {
                        Text("\(currentIndex + 1) из \(urls.count)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                    }
                    Spacer()
                    HStack(spacing: 12) {
                        Button { showEditor = true } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        Button {
                            showDeleteConfirm = true
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
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    let threshold: CGFloat = 80
                    if value.translation.width < -threshold, currentIndex < urls.count - 1 {
                        currentIndex += 1
                        loadImage()
                    } else if value.translation.width > threshold, currentIndex > 0 {
                        currentIndex -= 1
                        loadImage()
                    }
                    dragOffset = 0
                }
        )
        .onAppear { loadImage() }
        .sheet(isPresented: $showEditor) {
            if let img = currentImage {
                GalleryEditorView(image: img, url: currentURL) { edited in
                    currentImage = edited
                }
            }
        }
        .alert("Удалить фото?", isPresented: $showDeleteConfirm) {
            Button("Удалить", role: .destructive) {
                let deletingURL = currentURL
                onDelete(deletingURL)
                dismiss()
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Это действие нельзя отменить.")
        }
    }

    private func loadImage() {
        guard let data = try? Data(contentsOf: currentURL) else {
            currentImage = nil
            return
        }
        currentImage = UIImage(data: data)
    }
}
