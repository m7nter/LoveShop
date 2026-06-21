// WatermarkRenderer.swift
import UIKit
import CoreLocation
import CoreMotion

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
        var lines: [String] = []

        if let loc = location {
            let lat = String(format: "%.6f°", loc.coordinate.latitude)
            let lon = String(format: "%.6f°", loc.coordinate.longitude)
            lines.append("LAT: \(lat)")
            lines.append("LON: \(lon)")
        } else {
            lines.append("LAT: N/A")
            lines.append("LON: N/A")
        }

        if let h = heading {
            let dir = LocationManager.shared.compassDirection(from: h.magneticHeading)
            lines.append("AZM: \(Int(h.magneticHeading))° \(dir)")
        }

        if let label = labelText, !label.isEmpty {
            lines.append(label)
        }

        let font = UIFont.monospacedSystemFont(ofSize: max(size.width * 0.022, 14), weight: .semibold)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
            .strokeColor: UIColor.black,
            .strokeWidth: -3.0
        ]

        let lineHeight = font.lineHeight + 4
        let blockHeight = lineHeight * CGFloat(lines.count) + padding * 2
        let blockY = size.height - blockHeight - padding

        // Semi-transparent background
        let bgRect = CGRect(x: padding, y: blockY,
                            width: size.width - padding * 2, height: blockHeight)
        UIColor.black.withAlphaComponent(0.45).setFill()
        UIBezierPath(roundedRect: bgRect, cornerRadius: 8).fill()

        // Draw text lines
        for (i, line) in lines.enumerated() {
            let y = blockY + padding + CGFloat(i) * lineHeight
            let rect = CGRect(x: padding * 2, y: y,
                              width: size.width - padding * 4, height: lineHeight)
            (line as NSString).draw(in: rect, withAttributes: attrs)
        }

        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
}
