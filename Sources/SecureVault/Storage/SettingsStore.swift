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

    @Published var crosshairOnPhoto: Bool {
        didSet { UserDefaults.standard.set(crosshairOnPhoto, forKey: "crosshairOnPhoto") }
    }

    private let avatarKey = "userAvatar"

    init() {
        showCrosshair = UserDefaults.standard.bool(forKey: "showCrosshair")
        crosshairColor = UserDefaults.standard.string(forKey: "crosshairColor") ?? "white"
        crosshairOnPhoto = UserDefaults.standard.bool(forKey: "crosshairOnPhoto")
        loadAvatar()
    }

    var mainCode: String {
        get { UserDefaults.standard.string(forKey: "mainCode") ?? "2026" }
        set { UserDefaults.standard.set(newValue, forKey: "mainCode") }
    }

    var vaultCode: String {
        get { UserDefaults.standard.string(forKey: "vaultCode") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "vaultCode") }
    }

    var kamikazeCode: String {
        get { UserDefaults.standard.string(forKey: "kamikazeCode") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "kamikazeCode") }
    }

    var vaultCodeEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "vaultCodeEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "vaultCodeEnabled") }
    }

    var kamikazeCodeEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "kamikazeCodeEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "kamikazeCodeEnabled") }
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
