import SwiftUI

struct GalleryEditorView: View {
    let image: UIImage
    let url: URL
    let onSaved: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss

    @State private var shapes: [DrawnShape] = []
    @State private var selectedTool: DrawingTool = .arrow
    @State private var selectedColor: Color = .red
    @State private var canvasSize: CGSize = .zero

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
                    .onAppear { canvasSize = geo.size }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        // Просто закрываем без рендеринга
                        onSaved(image)
                        dismiss()
                    }
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
                        if !shapes.isEmpty { shapes.removeLast() }
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(shapes.isEmpty ? .gray : .white)
                    }
                    .disabled(shapes.isEmpty)
                }
            }
        }
    }

    @ViewBuilder
    private func toolButton(_ icon: String, tool: DrawingTool) -> some View {
        Button { selectedTool = tool } label: {
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
}
