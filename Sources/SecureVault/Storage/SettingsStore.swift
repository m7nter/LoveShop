import SwiftUI

class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    @Published var avatarImage: UIImage? {
        didSet { saveAvatar() }
    }

    private let avatarKey = "userAvatar"

    init() {
        loadAvatar()
    }

    private func saveAvatar() {
        guard let img = avatarImage,
              let data = img.jpegData(compressionQuality: 0.8) else { return }
        UserDefaults.standard.set(data, forKey: avatarKey)
    }

    private func loadAvatar() {
        guard let data = UserDefaults.standard.data(forKey: avatarKey),
              let img = UIImage(data: data) else { return }
        avatarImage = img
    }
}
