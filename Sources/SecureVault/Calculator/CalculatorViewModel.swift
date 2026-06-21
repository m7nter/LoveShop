// CalculatorViewModel.swift
import Foundation
import Combine

class CalculatorViewModel: ObservableObject {
    @Published var display: String = "0"
    @Published var shouldUnlock: Bool = false

    private var currentInput: String = ""
    private var storedValue: Double = 0
    private var currentOperator: String? = nil
    private var shouldResetDisplay = false
    private let secretCode = "2026"

    func tap(_ symbol: String) {
        switch symbol {
        case "0"..."9", ".":
            handleDigit(symbol)
        case "+", "−", "×", "÷":
            handleOperator(symbol)
        case "=":
            handleEquals()
        case "AC":
            reset()
        case "+/−":
            toggleSign()
        case "%":
            handlePercent()
        default:
            break
        }
    }

    private func handleDigit(_ d: String) {
        if d == "." && currentInput.contains(".") { return }
        if shouldResetDisplay {
            currentInput = d == "." ? "0." : d
            shouldResetDisplay = false
        } else {
            if currentInput == "0" && d != "." {
                currentInput = d
            } else {
                if currentInput.count < 9 { currentInput += d }
            }
        }
        display = currentInput
    }

    private func handleOperator(_ op: String) {
        if !currentInput.isEmpty {
            storedValue = Double(currentInput) ?? 0
        }
        currentOperator = op
        shouldResetDisplay = true
        currentInput = ""
    }

    private func handleEquals() {
        // Check secret code BEFORE computing
        if currentInput == secretCode || display == secretCode {
            shouldUnlock = true
            reset()
            return
        }

        guard let op = currentOperator,
              let rhs = Double(currentInput) else { return }

        let result: Double
        switch op {
        case "+": result = storedValue + rhs
        case "−": result = storedValue - rhs
        case "×": result = storedValue * rhs
        case "÷": result = rhs != 0 ? storedValue / rhs : 0
        default: return
        }

        storedValue = result
        currentInput = formatResult(result)
        display = currentInput
        currentOperator = nil
        shouldResetDisplay = true
    }

    private func formatResult(_ v: Double) -> String {
        if v.truncatingRemainder(dividingBy: 1) == 0 && abs(v) < 1e9 {
            return String(Int(v))
        }
        return String(format: "%.6g", v)
    }

    private func reset() {
        display = "0"
        currentInput = ""
        storedValue = 0
        currentOperator = nil
        shouldResetDisplay = false
    }

    private func toggleSign() {
        if let v = Double(currentInput) {
            let toggled = -v
            currentInput = formatResult(toggled)
            display = currentInput
        }
    }

    private func handlePercent() {
        if let v = Double(currentInput) {
            let pct = v / 100
            currentInput = formatResult(pct)
            display = currentInput
        }
    }
}
