import SwiftUI
import AVFoundation

struct VaultView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var showEditor = false
    @State private var showGallery = false
    @State private var showVaultLock = false
    @State private var showMap = false
    @StateObject private var cameraVM = CameraViewModel()

    var onLock: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1C1C1E").ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.orange)

                    Text("Secure Vault")
                        .font(.title.bold())
                        .foregroundColor(.white)

                    HStack(spacing: 16) {
                        VaultActionButton(icon: "camera.fill", label: "Камера") {
                            showCamera = true
                        }
                        VaultActionButton(icon: "photo.on.rectangle", label: "Галерея") {
                            let store = SettingsStore.shared
                            if store.vaultCodeEnabled && !store.vaultCode.isEmpty {
                                showVaultLock = true
                            } else {
                                showGallery = true
                            }
                        }
                    }

                    HStack(spacing: 16) {
                        VaultActionButton(icon: "map.fill", label: "Карта меток") {
                            showMap = true
                        }
                    }

                    // Кнопка назад в калькулятор
                    Button {
                        onLock()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("Калькулятор")
                        }
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            locationManager.requestAndStart()
            cameraVM.startSession()
        }
        .onDisappear { cameraVM.stopSession() }
        .fullScreenCover(isPresented: $showCamera) {
            CameraScreen(cameraVM: cameraVM) { img in
                capturedImage = img
                showCamera = false
                if cameraVM.quickMode {
                    _ = FileStorageManager.shared.save(
                        image: img,
                        location: LocationManager.shared.location
                    )
                } else {
                    showEditor = true
                }
            }
        }
        .fullScreenCover(isPresented: $showEditor) {
            if let img = capturedImage {
                PhotoEditorView(image: img) { edited in
                    _ = FileStorageManager.shared.save(
                        image: edited,
                        location: LocationManager.shared.location
                    )
                    showEditor = false
                } onDiscard: {
                    showEditor = false
                }
            }
        }
        .fullScreenCover(isPresented: $showGallery) {
            GalleryView()
        }
        .fullScreenCover(isPresented: $showVaultLock) {
            VaultLockView {
                showVaultLock = false
                showGallery = true
            } onCancel: {
                showVaultLock = false
            }
        }
        .fullScreenCover(isPresented: $showMap) {
            PhotoMapView()
        }
    }
}

struct VaultActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(width: 130, height: 100)
            .background(Color(hex: "#2C2C2E"))
            .cornerRadius(16)
        }
    }
}
