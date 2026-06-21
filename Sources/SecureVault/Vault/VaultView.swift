import SwiftUI
import AVFoundation

struct VaultView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var showEditor = false
    @State private var showGallery = false
    @StateObject private var cameraVM = CameraViewModel()

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
                            showGallery = true
                        }
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
                    // Быстрый режим — сразу сохраняем без редактора
                    _ = FileStorageManager.shared.save(image: img)
                } else {
                    showEditor = true
                }
            }
        }
        .fullScreenCover(isPresented: $showEditor) {
            if let img = capturedImage {
                PhotoEditorView(image: img) { edited in
                    _ = FileStorageManager.shared.save(image: edited)
                    showEditor = false
                } onDiscard: {
                    showEditor = false
                }
            }
        }
        .fullScreenCover(isPresented: $showGallery) {
            GalleryView()
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
