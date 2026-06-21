import SwiftUI

struct CalculatorView: View {
    @StateObject private var vm = CalculatorViewModel()
    var onUnlock: () -> Void

    private let buttons: [[String]] = [
        ["AC", "+/−", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]

    var body: some View {
        ZStack {
            Color(hex: "#1C1C1E").ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer()

                Text(vm.display)
                    .font(.system(size: 72, weight: .light))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 24)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)

                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { btn in
                            CalculatorButton(title: btn, vm: vm)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
        }
        .onChange(of: vm.shouldUnlock) { val in
            if val { onUnlock() }
        }
    }
}

struct CalculatorButton: View {
    let title: String
    @ObservedObject var vm: CalculatorViewModel

    private var isWide: Bool { title == "0" }
    private var bgColor: Color {
        switch title {
        case "AC", "+/−", "%": return Color(hex: "#A5A5A5")
        case "÷", "×", "−", "+", "=": return Color(hex: "#FF9F0A")
        default: return Color(hex: "#333333")
        }
    }

    var body: some View {
        Button {
            vm.tap(title)
        } label: {
            Text(title)
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(.white)
                .frame(
                    width: isWide ? 171 : 80,
                    height: 80
                )
                .background(bgColor)
                .clipShape(Capsule())
        }
    }
}
