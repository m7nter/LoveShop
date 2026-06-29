import SwiftUI

struct NotesListView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notes: [Note] = []
    @State private var searchText = ""
    @State private var showEditor = false
    @State private var editingNote: Note?
    @State private var noteToDelete: Note?
    @State private var showDeleteConfirm = false

    private var filteredNotes: [Note] {
        guard !searchText.isEmpty else { return notes }
        return notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            List {
                if filteredNotes.isEmpty {
                    Text(searchText.isEmpty ? "Нет заметок" : "Ничего не найдено")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(filteredNotes) { note in
                        Button {
                            editingNote = note
                            showEditor = true
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title.isEmpty ? "Без названия" : note.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                if !note.content.isEmpty {
                                    Text(note.content)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                Text(formatDate(note.modifiedDate))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                noteToDelete = note
                                showDeleteConfirm = true
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Поиск по заметкам")
            .navigationTitle("Дневник")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(.orange)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        editingNote = nil
                        showEditor = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .onAppear { reload() }
        .sheet(isPresented: $showEditor, onDismiss: reload) {
            NoteEditorView(note: editingNote)
        }
        .alert("Удалить заметку?", isPresented: $showDeleteConfirm) {
            Button("Удалить", role: .destructive) {
                if let note = noteToDelete {
                    NotesManager.shared.delete(note)
                    reload()
                }
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Это действие нельзя отменить.")
        }
    }

    private func reload() {
        notes = NotesManager.shared.loadAll().sorted { $0.modifiedDate > $1.modifiedDate }
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMMM yyyy, HH:mm"
        return f.string(from: date)
    }
}

struct NoteEditorView: View {
    let note: Note?
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var content: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Заголовок") {
                    TextField("Например: Пароли от Wi-Fi", text: $title)
                }
                Section("Текст") {
                    TextEditor(text: $content)
                        .frame(minHeight: 250)
                }
            }
            .navigationTitle(note == nil ? "Новая заметка" : "Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") { save() }
                        .foregroundColor(.orange)
                        .disabled(
                            title.trimmingCharacters(in: .whitespaces).isEmpty &&
                            content.trimmingCharacters(in: .whitespaces).isEmpty
                        )
                }
            }
        }
        .onAppear {
            if let note = note {
                title = note.title
                content = note.content
            }
        }
    }

    private func save() {
        if let existing = note {
            var updated = existing
            updated.title = title
            updated.content = content
            NotesManager.shared.update(updated)
        } else {
            NotesManager.shared.add(title: title, content: content)
        }
        dismiss()
    }
}
