import UIKit
import CoreLocation

struct WatermarkRenderer {
    static func apply(to image: UIImage,
                      location: CLLocation?,
                      heading: CLHeading?,
                      labelText: String? = nil) -> UIImage {

        // Фиксируем ориентацию
        let fixedImage = image.fixedOrientation()
        let size = fixedImage.size
        let scale = fixedImage.scale

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        fixedImage.draw(at: .zero)

        let padding: CGFloat = size.width * 0.03
        let font = UIFont.monospacedSystemFont(ofSize: max(size.width * 0.028, 16), weight: .semibold)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white
        ]
        let lineHeight = font.lineHeight + 4

        // ── ВЕРХНЯЯ ПОЛОСА ──
        var topText = "LAT: N/A   LON: N/A"
        var accuracyText = ""
        if let loc = location {
            topText = String(format: "%.6f, %.6f",
                             loc.coordinate.latitude,
                             loc.coordinate.longitude)
            if loc.horizontalAccuracy > 0 {
                accuracyText = "±\(Int(loc.horizontalAccuracy)) m"
            }
        }

        let topBarH = lineHeight + padding * 2
        UIColor.black.withAlphaComponent(0.55).setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: topBarH))

        let pinConfig = UIImage.SymbolConfiguration(pointSize: max(size.width * 0.025, 14))
        if let pinImg = UIImage(systemName: "mappin", withConfiguration: pinConfig)?
            .withTintColor(.white, renderingMode: .alwaysOriginal) {
            let iconSize = pinImg.size
            let iconY = (topBarH - iconSize.height) / 2
            pinImg.draw(at: CGPoint(x: padding, y: iconY))
            let coordRect = CGRect(x: padding + iconSize.width + 6,
                                   y: (topBarH - lineHeight) / 2,
                                   width: size.width * 0.65,
                                   height: lineHeight)
            (topText as NSString).draw(in: coordRect, withAttributes: attrs)
        }

        if !accuracyText.isEmpty {
            let dotSize: CGFloat = max(size.width * 0.018, 12)
            let dotX = size.width - dotSize - padding / 2
            let dotY = (topBarH - dotSize) / 2
            let isAccurate = location != nil && location!.horizontalAccuracy < 15
            (isAccurate ? UIColor.green : UIColor.yellow).setFill()
            UIBezierPath(ovalIn: CGRect(x: dotX, y: dotY,
                                        width: dotSize, height: dotSize)).fill()
            let accSize = (accuracyText as NSString).size(withAttributes: attrs)
            let accRect = CGRect(x: dotX - accSize.width - 8,
                                 y: (topBarH - lineHeight) / 2,
                                 width: accSize.width,
                                 height: lineHeight)
            (accuracyText as NSString).draw(in: accRect, withAttributes: attrs)
        }

        // ── НИЖНЯЯ ЧАСТЬ ──
        let hasLabel = !(labelText ?? "").isEmpty
        let avatarImg = SettingsStore.shared.avatarImage
        let avatarSize: CGFloat = size.width * 0.22

        if hasLabel || avatarImg != nil {
            let bottomBarH = avatarSize + padding * 2
            UIColor.black.withAlphaComponent(0.55).setFill()
            UIRectFill(CGRect(x: 0,
                              y: size.height - bottomBarH,
                              width: size.width,
                              height: bottomBarH))

            if let label = labelText, !label.isEmpty {
                let labelFont = UIFont.systemFont(ofSize: max(size.width * 0.03, 18), weight: .bold)
                let labelAttrs: [NSAttributedString.Key: Any] = [
                    .font: labelFont,
                    .foregroundColor: UIColor.white
                ]
                let labelRect = CGRect(
                    x: padding,
                    y: size.height - bottomBarH + padding,
                    width: size.width - avatarSize - padding * 3,
                    height: bottomBarH - padding * 2
                )
                (label as NSString).draw(in: labelRect, withAttributes: labelAttrs)
            }

            if let avatar = avatarImg {
                let avatarRect = CGRect(
                    x: size.width - avatarSize - padding,
                    y: size.height - avatarSize - padding,
                    width: avatarSize,
                    height: avatarSize
                )
                let path = UIBezierPath(roundedRect: avatarRect, cornerRadius: avatarSize * 0.1)
                path.addClip()
                avatar.draw(in: avatarRect)
            }
        }

        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
}

extension UIImage {
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let result = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return result
    }
}
