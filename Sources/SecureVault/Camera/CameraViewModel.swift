import AVFoundation
import UIKit
import Combine

final class CameraViewModel: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var error: String?
    @Published var isTorchOn: Bool = false
    @Published var quickMode: Bool = false

    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var completion: ((UIImage) -> Void)?

    override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        session.beginConfiguration()
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            error = "Camera unavailable"
            return
        }
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }
        session.commitConfiguration()
    }

    func startSession() {
        if !session.isRunning { session.startRunning() }
    }

    func stopSession() {
        if session.isRunning { session.stopRunning() }
    }

    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        try? device.lockForConfiguration()
        isTorchOn.toggle()
        device.torchMode = isTorchOn ? .on : .off
        device.unlockForConfiguration()
    }

    func capturePhoto(completion: @escaping (UIImage) -> Void) {
        self.completion = completion
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let img = UIImage(data: data) else { return }

        let loc = LocationManager.shared.location
        let hdg = LocationManager.shared.heading
        let watermarked = WatermarkRenderer.apply(to: img, location: loc, heading: hdg)
        DispatchQueue.main.async { self.completion?(watermarked) }
    }
}
