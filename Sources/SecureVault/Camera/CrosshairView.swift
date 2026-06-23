import SwiftUI

struct CrosshairView: View {
    let color: String

    private var uiColor: Color {
        switch color {
        case "red": return .red
        case "green": return .green
        case "yellow": return .yellow
        default: return .white
        }
    }

    var body: some View {
        ZStack {
            // Горизонтальная линия
            Rectangle()
                .fill(uiColor.opacity(0.8))
                .frame(width: 60, height: 1)

            // Вертикальная линия
            Rectangle()
                .fill(uiColor.opacity(0.8))
                .frame(width: 1, height: 60)

            // Центральная точка
            Circle()
                .fill(uiColor.opacity(0.8))
                .frame(width: 4, height: 4)

            // Угловые метки
            CrosshairCorners(color: uiColor)
        }
    }
}

struct CrosshairCorners: View {
    let color: Color

    var body: some View {
        ZStack {
            // Верхний левый
            corner().offset(x: -15, y: -15).rotationEffect(.degrees(0))
            // Верхний правый
            corner().offset(x: 15, y: -15).rotationEffect(.degrees(90))
            // Нижний правый
            corner().offset(x: 15, y: 15).rotationEffect(.degrees(180))
            // Нижний левый
            corner().offset(x: -15, y: 15).rotationEffect(.degrees(270))
        }
    }

    private func corner() -> some View {
        ZStack {
            Rectangle()
                .fill(color.opacity(0.8))
                .frame(width: 10, height: 1)
                .offset(x: 5, y: 0)
            Rectangle()
                .fill(color.opacity(0.8))
                .frame(width: 1, height: 10)
                .offset(x: 0, y: 5)
        }
    }
}
