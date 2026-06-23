import SwiftUI
import CoreLocation

struct CameraScreen: View {
    @ObservedObject var cameraVM: CameraViewModel
    let onCapture: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var locationManager = LocationManager.shared
    @ObservedObject private var settings = SettingsStore.shared

    var body: some View {
        ZStack {
            CameraView(session: cameraVM.session)
                .ignoresSafeArea()

            // Перекрестие
            if settings.showCrosshair {
                CrosshairView(color: settings.crosshairColor)
            }

            VStack(spacing: 0) {
                // Верхняя панель — координаты
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        if let loc = locationManager.location {
                            Text(String(format: "%.6f, %.6f",
                                        loc.coordinate.latitude,
                                        loc.coordinate.longitude))
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white)
                        } else {
                            Text("Определение координат...")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        if let hdg = locationManager.heading {
                            let dir = locationManager.compassDirection(from: hdg.magneticHeading)
                            Text(String(format: "AZM: %d° %@", Int(hdg.magneticHeading), dir))
                                .font(.system(size: 12, weight: .regular, design: .monospaced))
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                    Spacer()
                    if let loc = locationManager.location {
                        HStack(spacing: 4) {
                            Text("±\(Int(loc.horizontalAccuracy))м")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white)
                            Circle()
                                .fill(loc.horizontalAccuracy < 10 ? Color.green : Color.yellow)
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.5))

                Spacer()

                VStack(spacing: 16) {
                    HStack(spacing: 40) {
                        Button {
                            cameraVM.toggleTorch()
                        } label: {
                            Image(systemName: cameraVM.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .font(.system(size: 24))
                                .foregroundColor(cameraVM.isTorchOn ? .yellow : .white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }

                        Button {
                            cameraVM.capturePhoto { img in
                                onCapture(img)
                            }
                        } label: {
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 72, height: 72)
                                .overlay(Circle().fill(.white).frame(width: 60, height: 60))
                        }

                        Button {
                            cameraVM.quickMode.toggle()
                        } label: {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 24))
                                .foregroundColor(cameraVM.quickMode ? .orange : .white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                    }

                    HStack {
                        Button("Отмена") { dismiss() }
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        if cameraVM.quickMode {
                            Text("Быстрый режим")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
                .background(Color.black.opacity(0.5))
            }
        }
    }
}
