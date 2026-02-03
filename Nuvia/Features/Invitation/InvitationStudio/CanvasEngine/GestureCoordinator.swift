import SwiftUI

// MARK: - Gesture Coordinator
// Handles simultaneous Pan, Pinch, and Rotation gestures

struct GestureCoordinator: ViewModifier {
    @ObservedObject var viewModel: CanvasViewModel
    let elementId: UUID

    // Gesture state
    @State private var currentScale: CGFloat = 1.0
    @State private var currentRotation: Angle = .zero
    @State private var currentOffset: CGSize = .zero
    @State private var isGestureActive = false

    func body(content: Content) -> some View {
        content
            .gesture(combinedGesture)
    }

    private var combinedGesture: some Gesture {
        SimultaneousGesture(
            SimultaneousGesture(dragGesture, magnificationGesture),
            rotationGesture
        )
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isGestureActive {
                    startGesture()
                }
                currentOffset = value.translation
                viewModel.applyDrag(to: elementId, translation: value.translation)
            }
            .onEnded { _ in
                endGesture()
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if !isGestureActive {
                    startGesture()
                }
                currentScale = value
                viewModel.applyScale(to: elementId, scale: value)
            }
            .onEnded { _ in
                endGesture()
            }
    }

    private var rotationGesture: some Gesture {
        RotationGesture()
            .onChanged { value in
                if !isGestureActive {
                    startGesture()
                }
                currentRotation = value
                viewModel.applyRotation(to: elementId, angle: value)
            }
            .onEnded { _ in
                endGesture()
            }
    }

    private func startGesture() {
        isGestureActive = true
        viewModel.beginGesture(for: elementId, type: .combined)
        HapticEngine.shared.impact(.light)
    }

    private func endGesture() {
        guard isGestureActive else { return }
        isGestureActive = false
        currentScale = 1.0
        currentRotation = .zero
        currentOffset = .zero
        viewModel.endGesture(for: elementId)
    }
}

// MARK: - Gesture State Container
struct CanvasGestureState {
    var translation: CGSize = .zero
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero

    var isActive: Bool {
        translation != .zero || scale != 1.0 || rotation != .zero
    }
}

// MARK: - High Performance Gesture View
struct HighPerformanceGestureView<Content: View>: View {
    @ObservedObject var viewModel: CanvasViewModel
    let elementId: UUID
    let content: () -> Content

    @SwiftUI.GestureState private var gestureState = CanvasGestureState()
    @State private var hasStartedGesture = false

    init(
        viewModel: CanvasViewModel,
        elementId: UUID,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.viewModel = viewModel
        self.elementId = elementId
        self.content = content
    }

    var body: some View {
        content()
            .gesture(
                simultaneousGestures
                    .onEnded { _ in
                        viewModel.endGesture(for: elementId)
                        hasStartedGesture = false
                    }
            )
            .onChange(of: gestureState.isActive) { _, isActive in
                if isActive && !hasStartedGesture {
                    viewModel.beginGesture(for: elementId, type: .combined)
                    hasStartedGesture = true
                }
            }
    }

    private var simultaneousGestures: some Gesture {
        DragGesture()
            .simultaneously(with: MagnificationGesture())
            .simultaneously(with: RotationGesture())
            .updating($gestureState) { value, state, _ in
                // Extract values from nested simultaneous gestures
                if let drag = value.first?.first {
                    state.translation = drag.translation
                }
                if let magnification = value.first?.second {
                    state.scale = magnification
                }
                if let rotation = value.second {
                    state.rotation = rotation
                }
            }
            .onChanged { value in
                if !hasStartedGesture {
                    viewModel.beginGesture(for: elementId, type: .combined)
                    hasStartedGesture = true
                }

                var translation: CGSize = .zero
                var scale: CGFloat = 1.0
                var rotation: Angle = .zero

                if let drag = value.first?.first {
                    translation = drag.translation
                }
                if let mag = value.first?.second {
                    scale = mag
                }
                if let rot = value.second {
                    rotation = rot
                }

                viewModel.applyCombinedGesture(
                    to: elementId,
                    translation: translation,
                    scale: scale,
                    rotation: rotation
                )
            }
    }
}

// MARK: - Selection Handle
struct SelectionHandle: View {
    enum Position {
        case topLeft, topRight, bottomLeft, bottomRight
        case topCenter, bottomCenter, leftCenter, rightCenter
    }

    let position: Position
    let size: CGFloat
    var onDrag: ((CGSize) -> Void)?

    @State private var isDragging = false

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color.nuviaChampagne, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            .scaleEffect(isDragging ? 1.2 : 1.0)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        onDrag?(value.translation)
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
            .animation(DesignTokens.Animation.snappy, value: isDragging)
    }
}

// MARK: - Bounding Box View
struct BoundingBox: View {
    let size: CGSize
    let isSelected: Bool
    var onResize: ((SelectionHandle.Position, CGSize) -> Void)?

    private let handleSize: CGFloat = 12
    private let borderWidth: CGFloat = 1.5

    var body: some View {
        ZStack {
            // Border
            Rectangle()
                .stroke(
                    isSelected ? Color.nuviaChampagne : Color.clear,
                    style: StrokeStyle(lineWidth: borderWidth, dash: [4, 4])
                )
                .frame(width: size.width + 8, height: size.height + 8)

            // Corner handles
            if isSelected {
                Group {
                    // Corners
                    handleView(.topLeft)
                        .position(x: -size.width/2 - 4, y: -size.height/2 - 4)

                    handleView(.topRight)
                        .position(x: size.width/2 + 4, y: -size.height/2 - 4)

                    handleView(.bottomLeft)
                        .position(x: -size.width/2 - 4, y: size.height/2 + 4)

                    handleView(.bottomRight)
                        .position(x: size.width/2 + 4, y: size.height/2 + 4)
                }
            }
        }
        .frame(width: size.width + handleSize, height: size.height + handleSize)
    }

    private func handleView(_ position: SelectionHandle.Position) -> some View {
        SelectionHandle(position: position, size: handleSize) { translation in
            onResize?(position, translation)
        }
    }
}

// MARK: - Touch Indicator
struct TouchIndicator: View {
    let isActive: Bool

    var body: some View {
        Circle()
            .fill(Color.nuviaChampagne.opacity(0.3))
            .frame(width: 60, height: 60)
            .scaleEffect(isActive ? 1.5 : 0)
            .opacity(isActive ? 0 : 1)
            .animation(
                .easeOut(duration: 0.3),
                value: isActive
            )
    }
}

// MARK: - View Extension
extension View {
    func canvasGestures(
        viewModel: CanvasViewModel,
        elementId: UUID
    ) -> some View {
        self.modifier(GestureCoordinator(viewModel: viewModel, elementId: elementId))
    }
}
