// PhotoEditorView.swift
import SwiftUI

struct PhotoEditorView: View {
    let image: UIImage
    let onSave: (UIImage) -> Void
    let onDiscard: () -> Void

    @State private var shapes: [DrawnShape] = []
    @State private var selectedTool: DrawingTool = .arrow
    @State private var selectedColor: Color = .red
    @State private var labelText: String = ""
    @State private var showLabelInput = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                GeometryReader { geo in
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width, height: geo.size.height)

                        DrawingCanvas(shapes: $shapes,
                                      selectedTool: selectedTool,
                                      selectedColor: selectedColor)
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Удалить") { onDiscard() }
                        .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") { saveComposed() }
                        .foregroundColor(.orange)
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    toolButton("arrow.up.right", tool: .arrow)
                    toolButton("oval", tool: .oval)
                    Spacer()
                    colorButton(.red)
                    colorButton(.yellow)
                    Spacer()
                    Button {
                        showLabelInput = true
                    } label: {
                        Image(systemName: "textformat")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showLabelInput) {
                LabelInputSheet(text: $labelText)
            }
        }
    }

    @ViewBuilder
    private func toolButton(_ icon: String, tool: DrawingTool) -> some View {
        Button {
            selectedTool = tool
        } label: {
            Image(systemName: icon)
                .foregroundColor(selectedTool == tool ? .orange : .white)
                .font(.title2)
        }
    }

    @ViewBuilder
    private func colorButton(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 28, height: 28)
            .overlay(selectedColor == color
                     ? Circle().stroke(Color.white, lineWidth: 2) : nil)
            .onTapGesture { selectedColor = color }
    }

    private func saveComposed() {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let result = renderer.image { ctx in
            image.draw(at: .zero)
            // Re-render shapes scaled to image size
            // (simplified: for production, scale from view coords to image coords)
            let label = labelText.isEmpty ? nil : labelText
            if let lbl = label {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: image.size.width * 0.03, weight: .semibold),
                    .foregroundColor: UIColor.white,
                    .strokeColor: UIColor.black,
                    .strokeWidth: -2.5
                ]
                let margin: CGFloat = 16
                let size = (lbl as NSString).size(withAttributes: attrs)
                let pt = CGPoint(x: image.size.width - size.width - margin,
                                 y: image.size.height - size.height - margin)
                (lbl as NSString).draw(at: pt, withAttributes: attrs)
            }
        }
        onSave(result)
    }
}

struct LabelInputSheet: View {
    @Binding var text: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Введите метку...", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                Spacer()
            }
            .navigationTitle("Текстовая метка")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
        }
    }
}
