import UIKit
import CoreLocation

struct PhotoMeta: Codable {
    let latitude: Double
    let longitude: Double
    let date: Date
}

final class FileStorageManager {
    static let shared = FileStorageManager()
    private let folderName = "VaultPhotos"

    private var vaultDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(folderName)
    }

    private init() {
        try? FileManager.default.createDirectory(at: vaultDirectory,
                                                  withIntermediateDirectories: true)
    }

    func save(image: UIImage, location: CLLocation? = nil) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.92) else { return nil }
        let name = UUID().uuidString
        let url = vaultDirectory.appendingPathComponent("\(name).jpg")
        try? data.write(to: url)

        if let loc = location {
            let meta = PhotoMeta(
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude,
                date: Date()
            )
            if let metaData = try? JSONEncoder().encode(meta) {
                let metaURL = vaultDirectory.appendingPathComponent("\(name).json")
                try? metaData.write(to: metaURL)
            }
        }

        return url
    }

    func loadAll() -> [URL] {
        let files = try? FileManager.default.contentsOfDirectory(
            at: vaultDirectory,
            includingPropertiesForKeys: [.creationDateKey],
            options: .skipsHiddenFiles
        )
        return (files ?? [])
            .filter { $0.pathExtension == "jpg" }
            .sorted {
                let d1 = (try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                let d2 = (try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                return d1 > d2
            }
    }

    func loadMeta(for url: URL) -> PhotoMeta? {
        let name = url.deletingPathExtension().lastPathComponent
        let metaURL = vaultDirectory.appendingPathComponent("\(name).json")
        guard let data = try? Data(contentsOf: metaURL) else { return nil }
        return try? JSONDecoder().decode(PhotoMeta.self, from: data)
    }

    func loadAllWithMeta() -> [(URL, PhotoMeta?)] {
        return loadAll().map { ($0, loadMeta(for: $0)) }
    }

    func lastPhotoLocation() -> CLLocation? {
        guard let (_, meta) = loadAllWithMeta().first, let m = meta else { return nil }
        return CLLocation(latitude: m.latitude, longitude: m.longitude)
    }

    func delete(url: URL) {
        try? FileManager.default.removeItem(at: url)
        let name = url.deletingPathExtension().lastPathComponent
        let metaURL = vaultDirectory.appendingPathComponent("\(name).json")
        try? FileManager.default.removeItem(at: metaURL)
    }
}
