import SwiftUI

class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    @Published var avatarImage: UIImage? {
        didSet { saveAvatar() }
    }

    @Published var showCrosshair: Bool {
        didSet { UserDefaults.standard.set(showCrosshair, forKey: "showCrosshair") }
    }

    @Published var crosshairColor: String {
        didSet { UserDefaults.standard.set(crosshairColor, forKey: "crosshairColor") }
    }

    @Published var shareAsAlbum: Bool {
        didSet { UserDefaults.standard.set(shareAsAlbum, forKey: "shareAsAlbum") }
    }

    private let avatarKey = "userAvatar"

    init() {
        showCrosshair = UserDefaults.standard.bool(forKey: "showCrosshair")
        crosshairColor = UserDefaults.standard.string(forKey: "crosshairColor") ?? "white"
        shareAsAlbum = UserDefaults.standard.bool(forKey: "shareAsAlbum")
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
