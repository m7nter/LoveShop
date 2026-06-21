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

        let padding: CGFloat = 20
        let font = UIFont.monospacedSystemFont(ofSize: max(size.width * 0.022, 14), weight: .semibold)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
            .strokeColor: UIColor.black,
            .strokeWidth: -3.0
        ]
        let lineHeight = font.lineHeight + 4

        // ── ЛЕВЫЙ ВЕРХНИЙ УГОЛ: координаты + азимут ──
        var topLines: [String] = []
        if let loc = location {
            topLines.append(String(format: "%.6f, %.6f",
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
            topLines.append("LAT: N/A   LON: N/A")
        }

        // Фон под текст сверху
        let topBlockW = size.width * 0.55
        let topBlockH = lineHeight * CGFloat(topLines.count) + padding
        let topBgRect = CGRect(x: padding / 2, y: padding / 2,
                               width: topBlockW, height: topBlockH)
        UIColor.black.withAlphaComponent(0.5).setFill()
        UIBezierPath(roundedRect: topBgRect, cornerRadius: 6).fill()

        for (i, line) in topLines.enumerated() {
            let y = padding / 2 + padding / 4 + CGFloat(i) * lineHeight
            let rect = CGRect(x: padding, y: y,
                              width: topBlockW - padding / 2, height: lineHeight)
            (line as NSString).draw(in: rect, withAttributes: attrs)
        }

        // ── ЛЕВЫЙ НИЖНИЙ УГОЛ: подпись ──
        if let label = labelText, !label.isEmpty {
            let labelFont = UIFont.systemFont(ofSize: max(size.width * 0.025, 16), weight: .semibold)
            let labelAttrs: [NSAttributedString.Key: Any] = [
                .font: labelFont,
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -3.0
            ]
            let labelSize = (label as NSString).size(withAttributes: labelAttrs)
            let labelBgRect = CGRect(
                x: padding / 2,
                y: size.height - labelSize.height - padding * 1.5,
                width: labelSize.width + padding,
                height: labelSize.height + padding / 2
            )
            UIColor.black.withAlphaComponent(0.5).setFill()
            UIBezierPath(roundedRect: labelBgRect, cornerRadius: 6).fill()

            let labelPt = CGPoint(
                x: padding,
                y: size.height - labelSize.height - padding * 1.25
            )
            (label as NSString).draw(at: labelPt, withAttributes: labelAttrs)
        }

        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
}
