import UIKit
import CoreLocation

struct PhotoMeta: Codable {
    let latitude: Double
    let longitude: Double
    let date: Date
    var note: String? = nil

    enum CodingKeys: String, CodingKey {
        case latitude, longitude, date, note
    }

    init(latitude: Double, longitude: Double, date: Date, note: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.date = date
        self.note = note
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        date = try container.decode(Date.self, forKey: .date)
        note = try container.decodeIfPresent(String.self, forKey: .note)
    }
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

        // Сохраняем метаданные рядом
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

    func updateNote(for url: URL, note: String) {
        let name = url.deletingPathExtension().lastPathComponent
        let metaURL = vaultDirectory.appendingPathComponent("\(name).json")

        var meta = loadMeta(for: url) ?? PhotoMeta(latitude: 0, longitude: 0, date: Date())
        meta.note = note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note

        if let data = try? JSONEncoder().encode(meta) {
            try? data.write(to: metaURL)
        }
    }

    func delete(url: URL) {
        try? FileManager.default.removeItem(at: url)
        // Удаляем метаданные
        let name = url.deletingPathExtension().lastPathComponent
        let metaURL = vaultDirectory.appendingPathComponent("\(name).json")
        try? FileManager.default.removeItem(at: metaURL)
    }
}
