// PhotoDetailView.swift
import SwiftUI

struct PhotoDetailView: View {
    let url: URL
    let onDelete: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
            }
            VStack {
                HStack {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                    Button {
                        onDelete()
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}
