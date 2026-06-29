import Foundation

struct Note: Codable, Identifiable {
    let id: UUID
    var title: String
    var content: String
    var createdDate: Date
    var modifiedDate: Date
}

final class NotesManager {
    static let shared = NotesManager()
    private let fileURL: URL

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = docs.appendingPathComponent("VaultNotes")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        fileURL = folder.appendingPathComponent("notes.json")
    }

    func loadAll() -> [Note] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([Note].self, from: data)) ?? []
    }

    private func saveAll(_ notes: [Note]) {
        guard let data = try? JSONEncoder().encode(notes) else { return }
        try? data.write(to: fileURL)
    }

    func add(title: String, content: String) {
        var notes = loadAll()
        let note = Note(id: UUID(), title: title, content: content,
                         createdDate: Date(), modifiedDate: Date())
        notes.insert(note, at: 0)
        saveAll(notes)
    }

    func update(_ note: Note) {
        var notes = loadAll()
        if let idx = notes.firstIndex(where: { $0.id == note.id }) {
            var updated = note
            updated.modifiedDate = Date()
            notes[idx] = updated
            saveAll(notes)
        }
    }

    func delete(_ note: Note) {
        var notes = loadAll()
        notes.removeAll { $0.id == note.id }
        saveAll(notes)
    }
}
