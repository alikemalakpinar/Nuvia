import SwiftUI

// MARK: - Movable Element View
// Complete drag/drop/rotate/scale implementation for canvas elements
// This is the heart of the Invitation Studio editor

struct MovableElementView<Content: View>: View {
    @ObservedObject var viewModel: CanvasViewModel
    let element: StudioElement
    @ViewBuilder let content: () -> Content

    // Gesture tracking
    @State private var gestureStartTransform: StudioTransform?
    @State private var isDragging = false
    @State private var isScaling = false
    @State private var isRotating = false

    // Computed
    private var isSelected: Bool {
        viewModel.selectedElementId == element.id
    }

    private var transform: StudioTransform {
        element.transform
    }

    var body: some View {
        content()
            .frame(width: elementSize.width, height: elementSize.height)
            .rotationEffect(transform.rotation)
            .scaleEffect(transform.scale)
            .position(elementPosition)
            .overlay(selectionOverlay)
            .gesture(tapGesture)
            .gesture(isSelected ? combinedGesture : nil)
            .animation(DesignTokens.Animation.snappy, value: transform)
            .onChange(of: isSelected) { _, selected in
                if selected {
                    HapticEngine.shared.selection()
                }
            }
    }

    // MARK: - Computed Properties

    private var elementSize: CGSize {
        // Default sizes based on element type
        switch element {
        case .text:
            return CGSize(width: 200, height: 60)
        case .image:
            return CGSize(width: 200, height: 200)
        case .shape(_, let type, _, _, _, _):
            switch type {
            case .line, .divider:
                return CGSize(width: 200, height: 20)
            default:
                return CGSize(width: 100, height: 100)
            }
        case .sticker:
            return CGSize(width: 80, height: 80)
        }
    }

    private var elementPosition: CGPoint {
        CGPoint(
            x: viewModel.canvasSize.width / 2 + transform.offset.width,
            y: viewModel.canvasSize.height / 2 + transform.offset.height
        )
    }

    // MARK: - Selection Overlay

    @ViewBuilder
    private var selectionOverlay: some View {
        if isSelected {
            GeometryReader { geo in
                let size = geo.size

                // Selection border
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.nuviaChampagne, Color.nuviaRoseGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 2, dash: isScaling || isRotating ? [6, 4] : [])
                    )
                    .padding(-8)

                // Resize handles (corners)
                ForEach(HandlePosition.corners, id: \.self) { position in
                    ResizeHandle(position: position)
                        .position(position.point(for: size))
                        .gesture(resizeGesture(for: position))
                }

                // Rotation handle (top center, above element)
                RotationHandle()
                    .position(x: size.width / 2, y: -30)
                    .gesture(rotationHandleGesture)

                // Delete button (top-right corner)
                DeleteHandle {
                    withAnimation(DesignTokens.Animation.snappy) {
                        viewModel.removeElement(element.id)
                    }
                    HapticEngine.shared.notify(.warning)
                }
                .position(x: size.width + 16, y: -16)
            }
        }
    }

    // MARK: - Gestures

    private var tapGesture: some Gesture {
        TapGesture()
            .onEnded { _ in
                viewModel.selectElement(element.id)
            }
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
                if gestureStartTransform == nil {
                    beginGesture(.drag)
                }
                viewModel.applyDrag(to: element.id, translation: value.translation)
            }
            .onEnded { _ in
                endGesture()
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if gestureStartTransform == nil {
                    beginGesture(.scale)
                }
                isScaling = true
                viewModel.applyScale(to: element.id, scale: value)
            }
            .onEnded { _ in
                isScaling = false
                endGesture()
            }
    }

    private var rotationGesture: some Gesture {
        RotationGesture()
            .onChanged { value in
                if gestureStartTransform == nil {
                    beginGesture(.rotate)
                }
                isRotating = true
                viewModel.applyRotation(to: element.id, angle: value)
            }
            .onEnded { _ in
                isRotating = false
                endGesture()
            }
    }

    private var rotationHandleGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if gestureStartTransform == nil {
                    beginGesture(.rotate)
                }
                isRotating = true
                // Calculate rotation from drag
                let center = elementPosition
                let startVector = CGVector(dx: 0, dy: -50) // Initial handle position
                let currentVector = CGVector(
                    dx: value.location.x - center.x,
                    dy: value.location.y - center.y
                )
                let angle = atan2(currentVector.dy, currentVector.dx) - atan2(startVector.dy, startVector.dx)
                viewModel.applyRotation(to: element.id, angle: Angle(radians: Double(angle)))
            }
            .onEnded { _ in
                isRotating = false
                endGesture()
            }
    }

    private func resizeGesture(for position: HandlePosition) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if gestureStartTransform == nil {
                    beginGesture(.scale)
                }
                isScaling = true
                // Calculate scale based on drag distance
                let scaleFactor = 1 + (value.translation.width + value.translation.height) / 200
                let clampedScale = max(0.5, min(3.0, scaleFactor))
                viewModel.applyScale(to: element.id, scale: clampedScale)
            }
            .onEnded { _ in
                isScaling = false
                endGesture()
            }
    }

    // MARK: - Gesture Helpers

    private func beginGesture(_ type: GestureType) {
        gestureStartTransform = transform
        isDragging = type == .drag

        viewModel.beginGesture(for: element.id, type: type)

        switch type {
        case .drag:
            HapticEngine.shared.impact(.light)
        case .scale, .rotate:
            HapticEngine.shared.impact(.medium)
        default:
            break
        }
    }

    private func endGesture() {
        gestureStartTransform = nil
        isDragging = false
        viewModel.endGesture(for: element.id)
    }
}

// MARK: - Handle Position

enum HandlePosition: CaseIterable {
    case topLeft, topRight, bottomLeft, bottomRight

    static var corners: [HandlePosition] {
        [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }

    func point(for size: CGSize) -> CGPoint {
        switch self {
        case .topLeft:     return CGPoint(x: -8, y: -8)
        case .topRight:    return CGPoint(x: size.width + 8, y: -8)
        case .bottomLeft:  return CGPoint(x: -8, y: size.height + 8)
        case .bottomRight: return CGPoint(x: size.width + 8, y: size.height + 8)
        }
    }
}

// MARK: - Resize Handle

struct ResizeHandle: View {
    let position: HandlePosition
    @State private var isPressed = false

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(Color.nuviaChampagne.opacity(0.3))
                .frame(width: 24, height: 24)
                .blur(radius: 4)
                .opacity(isPressed ? 1 : 0)

            // Handle
            Circle()
                .fill(Color.white)
                .frame(width: 14, height: 14)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.nuviaChampagne, Color.nuviaRoseGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .scaleEffect(isPressed ? 1.2 : 1.0)
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
        }
        .animation(DesignTokens.Animation.snappy, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Rotation Handle

struct RotationHandle: View {
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 0) {
            // Rotation icon
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)

                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.nuviaChampagne)
            }
            .scaleEffect(isPressed ? 1.2 : 1.0)

            // Connection line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.nuviaChampagne, Color.nuviaChampagne.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1, height: 20)
        }
        .animation(DesignTokens.Animation.snappy, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Delete Handle

struct DeleteHandle: View {
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(hex: "FF4444"))
                    .frame(width: 24, height: 24)
                    .shadow(color: Color(hex: "FF4444").opacity(0.4), radius: 4, x: 0, y: 2)

                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(DesignTokens.Animation.snappy, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Movable Element ViewModifier

struct MovableElementModifier: ViewModifier {
    @ObservedObject var viewModel: CanvasViewModel
    let element: StudioElement

    func body(content: Content) -> some View {
        MovableElementView(viewModel: viewModel, element: element) {
            content
        }
    }
}

extension View {
    func movableElement(
        viewModel: CanvasViewModel,
        element: StudioElement
    ) -> some View {
        self.modifier(MovableElementModifier(viewModel: viewModel, element: element))
    }
}

// MARK: - Canvas Element Content View

struct StudioElementContentView: View {
    let element: StudioElement

    var body: some View {
        Group {
            switch element {
            case .text(_, let content, let color, let style, _):
                textView(content: content, color: color, style: style)

            case .image(_, let imageData, let filter, _):
                imageView(data: imageData, filter: filter)

            case .shape(_, let type, let fill, let stroke, let strokeWidth, _):
                shapeView(type: type, fill: fill, stroke: stroke, strokeWidth: strokeWidth)

            case .sticker(_, let assetName, _, _):
                stickerView(assetName: assetName)
            }
        }
    }

    @ViewBuilder
    private func textView(content: String, color: HexColor, style: StudioTextStyle) -> some View {
        Text(content)
            .font(.system(size: style.fontSize, weight: style.fontWeight.swiftUIWeight))
            .foregroundColor(color.color)
            .multilineTextAlignment(style.alignment.swiftUIAlignment)
            .tracking(style.letterSpacing)
            .lineSpacing(style.fontSize * (style.lineHeight - 1))
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.white.opacity(0.01)) // Invisible but tappable
            )
    }

    @ViewBuilder
    private func imageView(data: Data, filter: StudioPhotoFilter) -> some View {
        if let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .applyStudioFilter(filter)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            placeholder
        }
    }

    @ViewBuilder
    private func shapeView(type: StudioShapeType, fill: HexColor, stroke: HexColor?, strokeWidth: CGFloat) -> some View {
        switch type {
        case .rectangle:
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(fill.color)
                .overlay(
                    stroke.map { strokeColor in
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(strokeColor.color, lineWidth: strokeWidth)
                    }
                )

        case .circle:
            Circle()
                .fill(fill.color)
                .overlay(
                    stroke.map { strokeColor in
                        Circle().stroke(strokeColor.color, lineWidth: strokeWidth)
                    }
                )

        case .ellipse:
            Ellipse()
                .fill(fill.color)
                .overlay(
                    stroke.map { strokeColor in
                        Ellipse().stroke(strokeColor.color, lineWidth: strokeWidth)
                    }
                )

        case .line:
            Capsule()
                .fill(fill.color)
                .frame(height: max(2, strokeWidth))

        case .divider:
            HStack(spacing: 12) {
                Capsule().fill(fill.color).frame(height: 1)
                Image(systemName: "heart.fill")
                    .font(.system(size: 10))
                    .foregroundColor(fill.color)
                Capsule().fill(fill.color).frame(height: 1)
            }

        case .heart:
            Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundColor(fill.color)

        case .star:
            Image(systemName: "star.fill")
                .font(.system(size: 48))
                .foregroundColor(fill.color)

        case .diamond:
            Image(systemName: "diamond.fill")
                .font(.system(size: 48))
                .foregroundColor(fill.color)
        }
    }

    @ViewBuilder
    private func stickerView(assetName: String) -> some View {
        if assetName.hasPrefix("system:") {
            let iconName = String(assetName.dropFirst(7))
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundColor(Color.nuviaChampagne)
        } else {
            Image(assetName)
                .resizable()
                .scaledToFit()
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color.gray.opacity(0.2))
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 32))
                    .foregroundColor(.gray.opacity(0.5))
            )
    }
}

// MARK: - Preview

#Preview("Movable Element") {
    let viewModel = CanvasViewModel(canvasSize: CGSize(width: 375, height: 500))

    return ZStack {
        Color.nuviaBackground

        // Sample text element
        MovableElementView(
            viewModel: viewModel,
            element: .text(
                id: UUID(),
                content: "Emma & James",
                color: HexColor(hex: "2C2C2C"),
                style: StudioTextStyle(
                    fontFamily: "PlayfairDisplay-Bold",
                    fontSize: 32,
                    fontWeight: .bold,
                    letterSpacing: 1,
                    lineHeight: 1.2,
                    alignment: .center
                ),
                transform: StudioTransform()
            )
        ) {
            Text("Emma & James")
                .font(DSTypography.display(.medium))
                .foregroundColor(.nuviaPrimaryText)
        }
    }
    .frame(width: 375, height: 500)
}
