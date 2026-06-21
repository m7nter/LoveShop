// CameraScreen.swift
import SwiftUI

struct CameraScreen: View {
    @ObservedObject var cameraVM: CameraViewModel
    let onCapture: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            CameraView(session: cameraVM.session)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
                Spacer()
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
                .padding(.bottom, 40)
            }
        }
    }
}
