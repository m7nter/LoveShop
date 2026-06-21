import UIKit
import CoreLocation

struct WatermarkRenderer {
    static func apply(to image: UIImage,
                      location: CLLocation?,
                      heading: CLHeading?,
                      labelText: String? = nil) -> UIImage {
        let size = image.size
        let scale = image.scale

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        image.draw(at: .zero)

        let padding: CGFloat = 16
        let font = UIFont.monospacedSystemFont(ofSize: max(size.width * 0.022, 14), weight: .semibold)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
            .strokeColor: UIColor.black,
            .strokeWidth: -3.0
        ]
        let lineHeight = font.lineHeight + 4

        // ── ВЕРХНИЙ блок: координаты + азимут ──
        var topLines: [String] = []
        if let loc = location {
            topLines.append(String(format: "%.6f,  %.6f",
                                   loc.coordinate.latitude,
                                   loc.coordinate.longitude))
            if let h = heading {
                let dir = LocationManager.shared.compassDirection(from: h.magneticHeading)
                topLines.append("AZM: \(Int(h.magneticHeading))° \(dir)")
            }
            if loc.horizontalAccuracy > 0 {
                topLines.append("±\(Int(loc.horizontalAccuracy)) м")
            }
        } else {
            topLines.append("LAT: N/A")
            topLines.append("LON: N/A")
        }

        let topBlockH = lineHeight * CGFloat(topLines.count) + padding * 2
        let topBgRect = CGRect(x: 0, y: 0, width: size.width, height: topBlockH)
        UIColor.black.withAlphaComponent(0.45).setFill()
        UIRectFill(topBgRect)

        for (i, line) in topLines.enumerated() {
            let y = padding + CGFloat(i) * lineHeight
            let rect = CGRect(x: padding, y: y,
                              width: size.width - padding * 2, height: lineHeight)
            (line as NSString).draw(in: rect, withAttributes: attrs)
        }

        // ── НИЖНИЙ блок: подпись (если есть) ──
        if let label = labelText, !label.isEmpty {
            let bottomLines = [label]
            let bottomBlockH = lineHeight * CGFloat(bottomLines.count) + padding * 2
            let bottomBgRect = CGRect(x: 0,
                                      y: size.height - bottomBlockH,
                                      width: size.width,
                                      height: bottomBlockH)
            UIColor.black.withAlphaComponent(0.45).setFill()
            UIRectFill(bottomBgRect)

            for (i, line) in bottomLines.enumerated() {
                let y = size.height - bottomBlockH + padding + CGFloat(i) * lineHeight
                let rect = CGRect(x: padding, y: y,
                                  width: size.width - padding * 2, height: lineHeight)
                (line as NSString).draw(in: rect, withAttributes: attrs)
            }
        }

        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
}
