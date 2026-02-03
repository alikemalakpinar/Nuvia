import SwiftUI

// MARK: - Layer Sheet
// Photoshop-style layer management panel for the canvas
// Supports reordering, visibility, locking, and selection

struct LayerSheet: View {
    @ObservedObject var viewModel: CanvasViewModel
    @Binding var isPresented: Bool
    @State private var draggedItem: UUID?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            layerHeader

            Divider()
                .background(Color.nuviaTertiaryText.opacity(0.2))

            // Layer list
            if viewModel.elements.isEmpty {
                emptyState
            } else {
                layerList
            }

            Divider()
                .background(Color.nuviaTertiaryText.opacity(0.2))

            // Quick actions
            quickActions
        }
        .background(Color.nuviaSurface)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.xl, style: .continuous))
        .elevation(.overlay)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.bottom, DesignTokens.Spacing.lg)
    }

    // MARK: - Header

    private var layerHeader: some View {
        HStack {
            Text("Layers")
                .font(DSTypography.heading(.h4))
                .foregroundColor(.nuviaPrimaryText)

            Spacer()

            Text("\(viewModel.elements.count)")
                .font(DSTypography.label(.regular))
                .foregroundColor(.nuviaTertiaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.nuviaTertiaryBackground)
                )

            Button {
                withAnimation(DesignTokens.Animation.snappy) {
                    isPresented = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.nuviaTertiaryText)
            }
        }
        .padding(DesignTokens.Spacing.md)
    }

    // MARK: - Layer List

    private var layerList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                // Show layers in reverse order (top layer first)
                ForEach(viewModel.sortedElements.reversed()) { element in
                    LayerRow(
                        element: element,
                        isSelected: viewModel.selectedElementId == element.id,
                        isDragging: draggedItem == element.id,
                        onSelect: {
                            viewModel.selectElement(id: element.id)
                            HapticEngine.shared.selection()
                        },
                        onDelete: {
                            withAnimation(DesignTokens.Animation.snappy) {
                                viewModel.removeElement(id: element.id)
                            }
                            HapticEngine.shared.notify(.warning)
                        },
                        onMoveUp: {
                            moveLayer(element.id, direction: .up)
                        },
                        onMoveDown: {
                            moveLayer(element.id, direction: .down)
                        }
                    )
                }
            }
            .padding(.vertical, DesignTokens.Spacing.xs)
        }
        .frame(maxHeight: 300)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 40))
                .foregroundColor(.nuviaTertiaryText)

            Text("No Layers Yet")
                .font(DSTypography.heading(.h4))
                .foregroundColor(.nuviaPrimaryText)

            Text("Add text, images, or shapes\nto build your invitation")
                .font(DSTypography.body(.small))
                .foregroundColor(.nuviaSecondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(DesignTokens.Spacing.xl)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        HStack(spacing: DesignTokens.Spacing.lg) {
            // Select All
            ActionButton(
                icon: "checkmark.square.fill",
                label: "Select All"
            ) {
                // Select first element
                if let first = viewModel.sortedElements.first {
                    viewModel.selectElement(id: first.id)
                }
                HapticEngine.shared.impact(.light)
            }

            // Flatten/Merge (Premium)
            ActionButton(
                icon: "square.on.square.squareshape.controlhandles",
                label: "Flatten",
                isPremium: true
            ) {
                // Premium feature
                HapticEngine.shared.notify(.warning)
            }

            // Clear All
            ActionButton(
                icon: "trash",
                label: "Clear All",
                isDestructive: true
            ) {
                withAnimation(DesignTokens.Animation.smooth) {
                    viewModel.clearCanvas()
                }
                HapticEngine.shared.notify(.error)
            }
        }
        .padding(DesignTokens.Spacing.md)
    }

    // MARK: - Helpers

    private func moveLayer(_ id: UUID, direction: MoveDirection) {
        withAnimation(DesignTokens.Animation.snappy) {
            viewModel.moveLayer(id, direction: direction)
        }
        HapticEngine.shared.impact(.light)
    }
}

// MARK: - Layer Row

struct LayerRow: View {
    let element: StudioElement
    let isSelected: Bool
    let isDragging: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Main row
            HStack(spacing: DesignTokens.Spacing.sm) {
                // Drag handle
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.nuviaTertiaryText)
                    .frame(width: 20)

                // Layer type icon
                layerIcon
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(layerIconBackground)
                    )

                // Layer info
                VStack(alignment: .leading, spacing: 2) {
                    Text(layerName)
                        .font(DSTypography.body(.regular))
                        .foregroundColor(.nuviaPrimaryText)
                        .lineLimit(1)

                    Text(layerSubtitle)
                        .font(DSTypography.caption)
                        .foregroundColor(.nuviaTertiaryText)
                        .lineLimit(1)
                }

                Spacer()

                // Z-Index badge
                Text("z\(element.transform.zIndex)")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.nuviaTertiaryText)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.nuviaTertiaryBackground)
                    )

                // Expand button
                Button {
                    withAnimation(DesignTokens.Animation.snappy) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.nuviaTertiaryText)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? Color.nuviaChampagne.opacity(0.15) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isSelected ? Color.nuviaChampagne : Color.clear, lineWidth: 1.5)
            )
            .contentShape(Rectangle())
            .onTapGesture(perform: onSelect)

            // Expanded actions
            if isExpanded {
                expandedActions
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.xs)
        .opacity(isDragging ? 0.5 : 1.0)
    }

    // MARK: - Computed Properties

    private var layerName: String {
        switch element {
        case .text(_, let content, _, _, _):
            return content.isEmpty ? "Text Layer" : content
        case .image:
            return "Image"
        case .shape(_, let type, _, _, _, _):
            return type.rawValue.capitalized
        case .sticker(_, let assetName, _, _):
            if assetName.hasPrefix("system:") {
                return String(assetName.dropFirst(7)).capitalized
            }
            return assetName
        }
    }

    private var layerSubtitle: String {
        let scale = Int(element.transform.scale * 100)
        let rotation = Int(element.transform.rotation.degrees)
        return "Scale: \(scale)%  Rotation: \(rotation)°"
    }

    @ViewBuilder
    private var layerIcon: some View {
        switch element {
        case .text:
            Image(systemName: "textformat")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.nuviaChampagne)

        case .image:
            Image(systemName: "photo")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.nuviaDustyBlue)

        case .shape(_, let type, _, _, _, _):
            Image(systemName: shapeIconName(for: type))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.nuviaSage)

        case .sticker:
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.nuviaRoseDust)
        }
    }

    private var layerIconBackground: Color {
        switch element {
        case .text:     return Color.nuviaChampagne.opacity(0.15)
        case .image:    return Color.nuviaDustyBlue.opacity(0.15)
        case .shape:    return Color.nuviaSage.opacity(0.15)
        case .sticker:  return Color.nuviaRoseDust.opacity(0.15)
        }
    }

    private func shapeIconName(for type: StudioShapeType) -> String {
        switch type {
        case .rectangle: return "rectangle"
        case .circle:    return "circle"
        case .ellipse:   return "oval"
        case .line:      return "minus"
        case .divider:   return "minus"
        case .heart:     return "heart"
        case .star:      return "star"
        case .diamond:   return "diamond"
        }
    }

    // MARK: - Expanded Actions

    private var expandedActions: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Move up
            SmallActionButton(icon: "arrow.up", label: "Up") {
                onMoveUp()
            }

            // Move down
            SmallActionButton(icon: "arrow.down", label: "Down") {
                onMoveDown()
            }

            // Duplicate
            SmallActionButton(icon: "plus.square.on.square", label: "Copy") {
                // TODO: Implement duplicate
                HapticEngine.shared.impact(.light)
            }

            Spacer()

            // Delete
            SmallActionButton(icon: "trash", label: "Delete", isDestructive: true) {
                onDelete()
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(Color.nuviaTertiaryBackground.opacity(0.5))
    }
}

// MARK: - Move Direction

enum MoveDirection {
    case up, down
}

// MARK: - Action Button

struct ActionButton: View {
    let icon: String
    let label: String
    var isPremium: Bool = false
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(buttonColor)

                    if isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.nuviaChampagne)
                            .offset(x: 4, y: -4)
                    }
                }

                Text(label)
                    .font(DSTypography.label(.small))
                    .foregroundColor(.nuviaSecondaryText)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var buttonColor: Color {
        if isDestructive {
            return Color(hex: "C97A7A")
        }
        return .nuviaPrimaryText
    }
}

// MARK: - Small Action Button

struct SmallActionButton: View {
    let icon: String
    let label: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))

                Text(label)
                    .font(DSTypography.label(.small))
            }
            .foregroundColor(isDestructive ? Color(hex: "C97A7A") : .nuviaSecondaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isDestructive ? Color(hex: "C97A7A").opacity(0.1) : Color.nuviaTertiaryBackground)
            )
        }
    }
}

// MARK: - ViewModel Extension for Layer Management

extension CanvasViewModel {
    func moveLayer(_ id: UUID, direction: MoveDirection) {
        guard let index = elements.firstIndex(where: { $0.id == id }) else { return }

        switch direction {
        case .up:
            // Increase z-index (move forward)
            if let maxZ = elements.map({ $0.transform.zIndex }).max() {
                updateElementZIndex(id: id, zIndex: maxZ + 1)
            }
        case .down:
            // Decrease z-index (move backward)
            if let minZ = elements.map({ $0.transform.zIndex }).min(), minZ > 0 {
                updateElementZIndex(id: id, zIndex: minZ - 1)
            }
        }
    }

    func clearCanvas() {
        saveToHistory()
        elements.removeAll()
        selectedElementId = nil
    }

    private func updateElementZIndex(id: UUID, zIndex: Int) {
        saveToHistory()
        guard let index = elements.firstIndex(where: { $0.id == id }) else { return }

        var element = elements[index]
        var transform = element.transform
        transform.zIndex = zIndex
        element = element.withStudioTransform(transform)
        elements[index] = element
    }
}

// MARK: - StudioElement Extension

extension StudioElement {
    func withStudioTransform(_ newTransform: StudioTransform) -> StudioElement {
        switch self {
        case .text(let id, let content, let color, let style, _):
            return .text(id: id, content: content, color: color, style: style, transform: newTransform)
        case .image(let id, let data, let filter, _):
            return .image(id: id, imageData: data, filter: filter, transform: newTransform)
        case .shape(let id, let type, let fill, let stroke, let strokeWidth, _):
            return .shape(id: id, type: type, fillColor: fill, strokeColor: stroke, strokeWidth: strokeWidth, transform: newTransform)
        case .sticker(let id, let asset, let premium, _):
            return .sticker(id: id, assetName: asset, isPremiumSticker: premium, transform: newTransform)
        }
    }
}

// MARK: - Preview

#Preview("Layer Sheet") {
    @Previewable @State var isPresented = true

    let viewModel = CanvasViewModel(canvasSize: CGSize(width: 375, height: 500))

    // Add sample elements
    let _ = {
        viewModel.addElement(.text(
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
            transform: StudioTransform(zIndex: 2)
        ))
        viewModel.addElement(.shape(
            id: UUID(),
            type: .heart,
            fillColor: HexColor(hex: "C9A9A6"),
            strokeColor: nil,
            strokeWidth: 0,
            transform: StudioTransform(zIndex: 1)
        ))
        viewModel.addElement(.text(
            id: UUID(),
            content: "June 15, 2025",
            color: HexColor(hex: "6B6B6B"),
            style: StudioTextStyle(
                fontFamily: "Manrope-Regular",
                fontSize: 16,
                fontWeight: .regular,
                letterSpacing: 2,
                lineHeight: 1.4,
                alignment: .center
            ),
            transform: StudioTransform(zIndex: 3)
        ))
    }()

    return ZStack {
        Color.nuviaBackground.ignoresSafeArea()

        VStack {
            Spacer()
            LayerSheet(viewModel: viewModel, isPresented: $isPresented)
        }
    }
}
