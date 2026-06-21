import SwiftUI

struct GalleryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var photoURLs: [URL] = []
    @State private var selectedURL: URL?
    @State private var showSettings = false
    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 2)]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(photoURLs, id: \.self) { url in
                        ThumbnailCell(url: url)
                            .onTapGesture { selectedURL = url }
                    }
                }
            }
            .background(Color.black)
            .navigationTitle("Галерея")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(.orange)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .onAppear { reload() }
        .sheet(item: $selectedURL) { url in
            PhotoDetailView(url: url) { delete(url: url) }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private func reload() { photoURLs = FileStorageManager.shared.loadAll() }
    private func delete(url: URL) {
        FileStorageManager.shared.delete(url: url)
        reload()
    }
}

extension URL: Identifiable { public var id: String { absoluteString } }

struct ThumbnailCell: View {
    let url: URL
    var body: some View {
        if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
                .frame(width: 110, height: 110)
                .clipped()
        }
    }
}
