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

        let padding: CGFloat = size.width * 0.03
        let font = UIFont.monospacedSystemFont(ofSize: max(size.width * 0.028, 16), weight: .semibold)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white
        ]
        let lineHeight = font.lineHeight + 4

        // ── ВЕРХНЯЯ ПОЛОСА: координаты ──
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
        let topBarRect = CGRect(x: 0, y: 0, width: size.width, height: topBarH)
        UIColor.black.withAlphaComponent(0.55).setFill()
        UIRectFill(topBarRect)

        // Иконка геолокации
        let pinConfig = UIImage.SymbolConfiguration(pointSize: max(size.width * 0.025, 14))
        if let pinImg = UIImage(systemName: "mappin", withConfiguration: pinConfig)?
            .withTintColor(.white, renderingMode: .alwaysOriginal) {
            let iconSize = pinImg.size
            let iconY = (topBarH - iconSize.height) / 2
            pinImg.draw(at: CGPoint(x: padding, y: iconY))

            // Координаты рядом с иконкой
            let coordRect = CGRect(x: padding + iconSize.width + 6,
                                   y: (topBarH - lineHeight) / 2,
                                   width: size.width * 0.65,
                                   height: lineHeight)
            (topText as NSString).draw(in: coordRect, withAttributes: attrs)
        }

        // Точность справа
        if !accuracyText.isEmpty {
            let accSize = (accuracyText as NSString).size(withAttributes: attrs)
            let accRect = CGRect(x: size.width - accSize.width - padding - 20,
                                 y: (topBarH - lineHeight) / 2,
                                 width: accSize.width + 20,
                                 height: lineHeight)
            (accuracyText as NSString).draw(in: accRect, withAttributes: attrs)

            // Зелёная точка
            let dotSize: CGFloat = max(size.width * 0.018, 12)
            let dotX = size.width - dotSize - padding / 2
            let dotY = (topBarH - dotSize) / 2
            let dotColor = location != nil && (location!.horizontalAccuracy < 15)
                ? UIColor.green : UIColor.yellow
            dotColor.setFill()
            UIBezierPath(ovalIn: CGRect(x: dotX, y: dotY,
                                        width: dotSize, height: dotSize)).fill()
        }

        // ── НИЖНЯЯ ЧАСТЬ: подпись + аватар ──
        let hasLabel = !(labelText ?? "").isEmpty
        let avatarImg = SettingsStore.shared.avatarImage
        let avatarSize: CGFloat = size.width * 0.22

        if hasLabel || avatarImg != nil {
            let bottomBarH = avatarSize + padding * 2
            let bottomBarRect = CGRect(x: 0,
                                       y: size.height - bottomBarH,
                                       width: size.width,
                                       height: bottomBarH)
            UIColor.black.withAlphaComponent(0.55).setFill()
            UIRectFill(bottomBarRect)

            // Подпись слева снизу
            if let label = labelText, !label.isEmpty {
                let labelFont = UIFont.systemFont(ofSize: max(size.width * 0.03, 18), weight: .bold)
                let labelAttrs: [NSAttributedString.Key: Any] = [
                    .font: labelFont,
                    .foregroundColor: UIColor.white
                ]
                let labelRect = CGRect(
                    x: padding,
                    y: size.height - bottomBarH + (bottomBarH - lineHeight * 2) / 2,
                    width: size.width - avatarSize - padding * 3,
                    height: bottomBarH - padding
                )
                (label as NSString).draw(in: labelRect, withAttributes: labelAttrs)
            }

            // Аватар справа снизу
            if let avatar = avatarImg {
                let avatarRect = CGRect(
                    x: size.width - avatarSize - padding,
                    y: size.height - avatarSize - padding,
                    width: avatarSize,
                    height: avatarSize
                )
                let path = UIBezierPath(roundedRect: avatarRect, cornerRadius: 8)
                path.addClip()
                avatar.draw(in: avatarRect)
            }
        }

        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
}
