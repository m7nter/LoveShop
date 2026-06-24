import SwiftUI

struct GalleryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var groupedPhotos: [(String, [URL])] = []
    @State private var selectedURL: URL?
    @State private var showSettings = false
    @State private var sharingItems: [Any] = []
    @State private var showShareSheet = false
    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 2)]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                    ForEach(groupedPhotos, id: \.0) { day, urls in
                        Section {
                            LazyVGrid(columns: columns, spacing: 2) {
                                ForEach(urls, id: \.self) { url in
                                    ThumbnailCell(url: url)
                                        .onTapGesture { selectedURL = url }
                                }
                            }
                            .padding(.bottom, 8)
                        } header: {
                            HStack {
                                Text(day)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                                Button {
                                    shareDay(urls: urls)
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(.orange)
                                        .font(.system(size: 16))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.85))
                        }
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
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: sharingItems)
        }
    }

    private func shareDay(urls: [URL]) {
        guard !urls.isEmpty else { return }
        sharingItems = urls
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showShareSheet = true
        }
    }

    private func reload() {
        let urls = FileStorageManager.shared.loadAll()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"

        var dict: [String: [URL]] = [:]
        var order: [String] = []

        for url in urls {
            let date = (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date()
            let key = formatter.string(from: date)
            if dict[key] == nil {
                dict[key] = []
                order.append(key)
            }
            dict[key]?.append(url)
        }

        groupedPhotos = order.map { ($0, dict[$0] ?? []) }
    }

    private func delete(url: URL) {
        FileStorageManager.shared.delete(url: url)
        reload()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
