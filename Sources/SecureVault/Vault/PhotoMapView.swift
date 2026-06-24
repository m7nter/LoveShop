import SwiftUI
import MapKit

struct PhotoPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let url: URL
    let date: Date
}

struct PhotoMapView: View {
    @Environment(\.dismiss) var dismiss
    @State private var pins: [PhotoPin] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.75, longitude: 37.62),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedPin: PhotoPin?

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: pins) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
                    Button {
                        selectedPin = pin
                    } label: {
                        VStack(spacing: 2) {
                            if let data = try? Data(contentsOf: pin.url),
                               let img = UIImage(data: data) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.orange, lineWidth: 2)
                                    )
                            } else {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.orange)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            Image(systemName: "triangle.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.orange)
                                .rotationEffect(.degrees(180))
                        }
                    }
                }
            }
            .ignoresSafeArea()

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding()
                    Spacer()
                    Text("Карта меток")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                    Spacer()
                    // Кнопка центрировать на текущей позиции
                    Button {
                        if let loc = LocationManager.shared.location {
                            region.center = loc.coordinate
                        }
                    } label: {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                .padding(.top, 50)

                Spacer()

                // Счётчик меток
                Text("\(pins.count) фото на карте")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    .padding(.bottom, 32)
            }

            // Превью выбранного фото
            if let pin = selectedPin {
                VStack {
                    Spacer()
                    HStack {
                        if let data = try? Data(contentsOf: pin.url),
                           let img = UIImage(data: data) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: "%.6f, %.6f",
                                        pin.coordinate.latitude,
                                        pin.coordinate.longitude))
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white)
                            Text(formatDate(pin.date))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button {
                            selectedPin = nil
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.gray.opacity(0.4))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.85))
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear { loadPins() }
    }

    private func loadPins() {
        let items = FileStorageManager.shared.loadAllWithMeta()
        var result: [PhotoPin] = []
        for (url, meta) in items {
            if let m = meta {
                result.append(PhotoPin(
                    coordinate: CLLocationCoordinate2D(
                        latitude: m.latitude,
                        longitude: m.longitude
                    ),
                    url: url,
                    date: m.date
                ))
            }
        }
        pins = result

        // Центрируем карту на первом пине
        if let first = result.first {
            region.center = first.coordinate
        } else if let loc = LocationManager.shared.location {
            region.center = loc.coordinate
        }
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMMM yyyy, HH:mm"
        return f.string(from: date)
    }
}
