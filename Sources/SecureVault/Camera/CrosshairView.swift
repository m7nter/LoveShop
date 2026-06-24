import SwiftUI

struct CrosshairView: View {
    let color: String

    private var lineColor: Color {
        switch color {
        case "red": return .red
        case "green": return .green
        case "yellow": return .yellow
        default: return .white
        }
    }

    var body: some View {
        ZStack {
            // Горизонтальная линия на весь экран
            Rectangle()
                .fill(lineColor)
                .frame(height: 2)

            // Вертикальная линия на весь экран
            Rectangle()
                .fill(lineColor)
                .frame(width: 2)
        }
        .ignoresSafeArea()
    }
}
