import SwiftUI

struct CalculatorView: View {
    @StateObject private var vm = CalculatorViewModel()
    var onUnlock: () -> Void

    // Современная раскладка iOS калькулятора
    private let buttons: [[String]] = [
        ["⌫", "AC", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["+/−", "0", ",", "="]
    ]

    var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 8
            let btnSize = (geo.size.width - spacing * 5) / 4

            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Дисплей
                    Text(vm.display)
                        .font(.system(size: 80, weight: .thin))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)

                    // Кнопки
                    VStack(spacing: spacing) {
                        ForEach(buttons, id: \.self) { row in
                            HStack(spacing: spacing) {
                                ForEach(row, id: \.self) { btn in
                                    CalculatorButton(
                                        title: btn,
                                        vm: vm,
                                        size: btnSize,
                                        spacing: spacing
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, spacing)
                    .padding(.bottom, geo.safeAreaInsets.bottom + spacing)
                }
            }
        }
        .ignoresSafeArea()
        .onChange(of: vm.shouldUnlock) { val in
            if val { onUnlock() }
        }
    }
}

struct CalculatorButton: View {
    let title: String
    @ObservedObject var vm: CalculatorViewModel
    let size: CGFloat
    let spacing: CGFloat

    private var bgColor: Color {
        switch title {
        case "⌫", "AC", "%", "+/−":
            return Color(red: 0.33, green: 0.33, blue: 0.33)
        case "÷", "×", "−", "+", "=":
            return Color(red: 1.0, green: 0.62, blue: 0.04)
        default:
            return Color(red: 0.18, green: 0.18, blue: 0.18)
        }
    }

    private var textColor: Color {
        switch title {
        case "⌫", "AC", "%", "+/−":
            return .white
        default:
            return .white
        }
    }

    private var label: some View {
        Group {
            switch title {
            case "⌫":
                Image(systemName: "delete.left")
                    .font(.system(size: size * 0.32, weight: .regular))
                    .foregroundColor(textColor)
            case "÷":
                Text("÷")
                    .font(.system(size: size * 0.42, weight: .regular))
                    .foregroundColor(textColor)
            case "×":
                Text("×")
                    .font(.system(size: size * 0.42, weight: .regular))
                    .foregroundColor(textColor)
            case "−":
                Text("−")
                    .font(.system(size: size * 0.5, weight: .regular))
                    .foregroundColor(textColor)
            case "+":
                Text("+")
                    .font(.system(size: size * 0.42, weight: .regular))
                    .foregroundColor(textColor)
            case "=":
                Text("=")
                    .font(.system(size: size * 0.42, weight: .bold))
                    .foregroundColor(textColor)
            default:
                Text(title)
                    .font(.system(size: size * 0.36, weight: .regular))
                    .foregroundColor(textColor)
            }
        }
    }

    var body: some View {
        Button {
            vm.tap(title)
        } label: {
            label
                .frame(width: size, height: size)
                .background(bgColor)
                .clipShape(Circle())
        }
    }
}
