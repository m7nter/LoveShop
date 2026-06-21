import SwiftUI

@main
struct SecureVaultApp: App {
    @State private var isUnlocked = false

    var body: some Scene {
        WindowGroup {
            if isUnlocked {
                VaultView()
            } else {
                CalculatorView(onUnlock: {
                    isUnlocked = true
                })
            }
        }
    }
}
