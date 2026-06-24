import SwiftUI

@main
struct SecureVaultApp: App {
    @State private var isUnlocked = false
    @Environment(\.scenePhase) var scenePhase
    @State private var backgroundTime: Date? = nil

    init() {
        setupCrashLogging()
    }

    var body: some Scene {
        WindowGroup {
            if isUnlocked {
                VaultView(onLock: {
                    isUnlocked = false
                })
            } else {
                CalculatorView(onUnlock: {
                    isUnlocked = true
                })
            }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background, .inactive:
                backgroundTime = Date()
            case .active:
                if let bg = backgroundTime {
                    let elapsed = Date().timeIntervalSince(bg)
                    let timeout = SettingsStore.shared.autoLockTimeout
                    if timeout > 0 && elapsed >= Double(timeout) && isUnlocked {
                        isUnlocked = false
                    }
                }
                backgroundTime = nil
            default:
                break
            }
        }
    }

    private func setupCrashLogging() {
        NSSetUncaughtExceptionHandler { exception in
            let log = """
            CRASH: \(exception.name.rawValue)
            Reason: \(exception.reason ?? "unknown")
            Stack: \(exception.callStackSymbols.joined(separator: "\n"))
            """
            let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
            if let cachePath = paths.first {
                let logPath = cachePath + "/crash.log"
                try? log.write(toFile: logPath, atomically: true, encoding: .utf8)
            }
        }
    }
}
