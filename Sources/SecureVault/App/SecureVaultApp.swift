import SwiftUI

@main
struct SecureVaultApp: App {
    @State private var isUnlocked = false

    init() {
        setupCrashLogging()
    }

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
