import SwiftUI

struct PhotoDetailView: View {
    let url: URL
    let onDelete: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                GeometryReader { geo in
                    let imageSize = img.size
                    let scaleX = geo.size.width / imageSize.width
                    let scaleY = geo.size.height / imageSize.height
                    let scale = min(scaleX, scaleY)
                    let displayedH = imageSize.height * scale
                    let displayedW = imageSize.width * scale
                    let offsetX = (geo.size.width - displayedW) / 2
                    let offsetY = (geo.size.height - displayedH) / 2

                    ZStack(alignment: .topLeading) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width, height: geo.size.height)

                        // Подпись в левом нижнем углу фото
                        let label = LabelTemplatesStore().selected
                        if !label.isEmpty {
                            Text(label)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.55))
                                .cornerRadius(6)
                                .offset(x: offsetX + 12,
                                        y: offsetY + displayedH - 44)
                        }

                        // Аватар в правом нижнем углу фото
                        if let avatar = SettingsStore.shared.avatarImage {
                            Image(uiImage: avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 72, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .offset(x: offsetX + displayedW - 84,
                                        y: offsetY + displayedH - 84)
                        }
                    }
                }
            }

            VStack {
                HStack {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                    Spacer()
                    Button {
                        onDelete()
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 60)
                Spacer()
            }
        }
    }
}
