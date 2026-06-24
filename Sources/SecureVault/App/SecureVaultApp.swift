import SwiftUI

@main
struct SecureVaultApp: App {
    @State private var isUnlocked = false
    @State private var lastActiveTime = Date()
    @Environment(\.scenePhase) var scenePhase

    init() {
        setupCrashLogging()
    }

    var body: some Scene {
        WindowGroup {
            if isUnlocked {
                VaultView(onLock: {
                    isUnlocked = false
                })
                .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.userDidTakeScreenshotNotification)
                ) { _ in
                    lastActiveTime = Date()
                }
            } else {
                CalculatorView(onUnlock: {
                    isUnlocked = true
                    lastActiveTime = Date()
                })
            }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                checkAutoLock()
            case .background, .inactive:
                lastActiveTime = Date()
            default:
                break
            }
        }
    }

    private func checkAutoLock() {
        let timeout = SettingsStore.shared.autoLockTimeout
        guard timeout > 0, isUnlocked else { return }
        let elapsed = Date().timeIntervalSince(lastActiveTime)
        if elapsed >= Double(timeout) {
            isUnlocked = false
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
