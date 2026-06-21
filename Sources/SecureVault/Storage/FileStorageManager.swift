// FileStorageManager.swift
import UIKit

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

    func save(image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.92) else { return nil }
        let filename = "\(UUID().uuidString).jpg"
        let url = vaultDirectory.appendingPathComponent(filename)
        try? data.write(to: url)
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

    func delete(url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}
