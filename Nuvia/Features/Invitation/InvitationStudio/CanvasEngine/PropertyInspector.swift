import SwiftUI

// MARK: - Property Inspector
// Dynamic property editor for canvas elements
// Shows different controls based on element type

struct PropertyInspector: View {
    @ObservedObject var viewModel: CanvasViewModel
    @Binding var isPresented: Bool

    @State private var selectedSection: InspectorSection = .style

    private var selectedElement: CanvasElement? {
        guard let id = viewModel.selectedElementId else { return nil }
        return viewModel.elements.first { $0.id == id }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            inspectorHeader

            if let element = selectedElement {
                // Section tabs
                sectionTabs

                Divider()
                    .background(Color.nuviaTertiaryText.opacity(0.2))

                // Content based on section and element type
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignTokens.Spacing.lg) {
                        inspectorContent(for: element)
                    }
                    .padding(DesignTokens.Spacing.md)
                }
                .frame(maxHeight: 400)
            } else {
                noSelectionView
            }
        }
        .background(Color.nuviaSurface)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.xl, style: .continuous))
        .elevation(.overlay)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.bottom, DesignTokens.Spacing.lg)
    }

    // MARK: - Header

    private var inspectorHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Properties")
                    .font(DSTypography.heading(.h4))
                    .foregroundColor(.nuviaPrimaryText)

                if let element = selectedElement {
                    Text(elementTypeName(for: element))
                        .font(DSTypography.caption)
                        .foregroundColor(.nuviaTertiaryText)
                }
            }

            Spacer()

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

    // MARK: - Section Tabs

    private var sectionTabs: some View {
        HStack(spacing: 0) {
            ForEach(InspectorSection.allCases, id: \.self) { section in
                Button {
                    withAnimation(DesignTokens.Animation.snappy) {
                        selectedSection = section
                    }
                    HapticEngine.shared.selection()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: section.icon)
                            .font(.system(size: 16, weight: .medium))

                        Text(section.title)
                            .font(DSTypography.label(.small))
                    }
                    .foregroundColor(selectedSection == section ? .nuviaChampagne : .nuviaTertiaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .background(
                        Rectangle()
                            .fill(selectedSection == section ? Color.nuviaChampagne.opacity(0.1) : Color.clear)
                    )
                }
            }
        }
    }

    // MARK: - Inspector Content

    @ViewBuilder
    private func inspectorContent(for element: CanvasElement) -> some View {
        switch selectedSection {
        case .style:
            styleSection(for: element)
        case .transform:
            transformSection(for: element)
        case .effects:
            effectsSection(for: element)
        }
    }

    // MARK: - Style Section

    @ViewBuilder
    private func styleSection(for element: CanvasElement) -> some View {
        switch element {
        case .text(let id, let content, let color, let style, _):
            TextStyleInspector(
                elementId: id,
                content: content,
                color: color,
                style: style,
                viewModel: viewModel
            )

        case .image(let id, _, let filter, _):
            ImageStyleInspector(
                elementId: id,
                filter: filter,
                viewModel: viewModel
            )

        case .shape(let id, let type, let fillColor, let strokeColor, let strokeWidth, _):
            ShapeStyleInspector(
                elementId: id,
                shapeType: type,
                fillColor: fillColor,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                viewModel: viewModel
            )

        case .sticker(let id, let assetName, let isPremium, _):
            StickerStyleInspector(
                elementId: id,
                assetName: assetName,
                isPremium: isPremium,
                viewModel: viewModel
            )
        }
    }

    // MARK: - Transform Section

    @ViewBuilder
    private func transformSection(for element: CanvasElement) -> some View {
        TransformInspector(
            elementId: element.id,
            transform: element.transform,
            viewModel: viewModel
        )
    }

    // MARK: - Effects Section

    @ViewBuilder
    private func effectsSection(for element: CanvasElement) -> some View {
        EffectsInspector(
            elementId: element.id,
            viewModel: viewModel
        )
    }

    // MARK: - No Selection View

    private var noSelectionView: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "hand.tap")
                .font(.system(size: 40))
                .foregroundColor(.nuviaTertiaryText)

            Text("No Selection")
                .font(DSTypography.heading(.h4))
                .foregroundColor(.nuviaPrimaryText)

            Text("Tap an element on the canvas\nto edit its properties")
                .font(DSTypography.body(.small))
                .foregroundColor(.nuviaSecondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(DesignTokens.Spacing.xl)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private func elementTypeName(for element: CanvasElement) -> String {
        switch element {
        case .text:    return "Text Element"
        case .image:   return "Image Element"
        case .shape:   return "Shape Element"
        case .sticker: return "Sticker Element"
        }
    }
}

// MARK: - Inspector Section

enum InspectorSection: CaseIterable {
    case style, transform, effects

    var title: String {
        switch self {
        case .style:     return "Style"
        case .transform: return "Transform"
        case .effects:   return "Effects"
        }
    }

    var icon: String {
        switch self {
        case .style:     return "paintpalette"
        case .transform: return "arrow.up.left.and.arrow.down.right"
        case .effects:   return "sparkles"
        }
    }
}

// MARK: - Text Style Inspector

struct TextStyleInspector: View {
    let elementId: UUID
    let content: String
    let color: HexColor
    let style: CanvasTextStyle
    @ObservedObject var viewModel: CanvasViewModel

    @State private var editedContent: String = ""
    @State private var selectedFontSize: CGFloat = 24
    @State private var selectedWeight: CanvasFontWeight = .regular
    @State private var selectedAlignment: CanvasTextAlignment = .center

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Text content
            PropertySection(title: "Content") {
                TextField("Enter text", text: $editedContent)
                    .font(DSTypography.body(.regular))
                    .textFieldStyle(.plain)
                    .padding(DesignTokens.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.nuviaTertiaryBackground)
                    )
                    .onChange(of: editedContent) { _, newValue in
                        updateTextContent(newValue)
                    }
            }

            // Font family (Premium fonts locked)
            PropertySection(title: "Font Family") {
                FontPicker(
                    selectedFont: style.fontFamily,
                    onSelect: { fontFamily in
                        updateFontFamily(fontFamily)
                    }
                )
            }

            // Font size
            PropertySection(title: "Size") {
                HStack(spacing: DesignTokens.Spacing.md) {
                    Slider(value: $selectedFontSize, in: 12...72, step: 1)
                        .tint(Color.nuviaChampagne)
                        .onChange(of: selectedFontSize) { _, newValue in
                            updateFontSize(newValue)
                        }

                    Text("\(Int(selectedFontSize))pt")
                        .font(DSTypography.label(.regular))
                        .foregroundColor(.nuviaPrimaryText)
                        .frame(width: 50)
                }
            }

            // Font weight
            PropertySection(title: "Weight") {
                FontWeightPicker(
                    selected: selectedWeight,
                    onSelect: { weight in
                        selectedWeight = weight
                        updateFontWeight(weight)
                    }
                )
            }

            // Text color
            PropertySection(title: "Color") {
                ColorSwatchPicker(
                    selectedColor: color.hex,
                    onSelect: { hex in
                        updateTextColor(hex)
                    }
                )
            }

            // Alignment
            PropertySection(title: "Alignment") {
                AlignmentPicker(
                    selected: selectedAlignment,
                    onSelect: { alignment in
                        selectedAlignment = alignment
                        updateAlignment(alignment)
                    }
                )
            }
        }
        .onAppear {
            editedContent = content
            selectedFontSize = style.fontSize
            selectedWeight = style.fontWeight
            selectedAlignment = style.alignment
        }
    }

    // MARK: - Update Methods

    private func updateTextContent(_ newContent: String) {
        viewModel.updateTextElement(id: elementId, content: newContent)
    }

    private func updateFontFamily(_ family: String) {
        viewModel.updateTextStyle(id: elementId) { style in
            var newStyle = style
            newStyle.fontFamily = family
            return newStyle
        }
        HapticEngine.shared.selection()
    }

    private func updateFontSize(_ size: CGFloat) {
        viewModel.updateTextStyle(id: elementId) { style in
            var newStyle = style
            newStyle.fontSize = size
            return newStyle
        }
    }

    private func updateFontWeight(_ weight: CanvasFontWeight) {
        viewModel.updateTextStyle(id: elementId) { style in
            var newStyle = style
            newStyle.fontWeight = weight
            return newStyle
        }
        HapticEngine.shared.selection()
    }

    private func updateTextColor(_ hex: String) {
        viewModel.updateTextColor(id: elementId, color: HexColor(hex: hex))
        HapticEngine.shared.selection()
    }

    private func updateAlignment(_ alignment: CanvasTextAlignment) {
        viewModel.updateTextStyle(id: elementId) { style in
            var newStyle = style
            newStyle.alignment = alignment
            return newStyle
        }
        HapticEngine.shared.selection()
    }
}

// MARK: - Image Style Inspector

struct ImageStyleInspector: View {
    let elementId: UUID
    let filter: PhotoFilter
    @ObservedObject var viewModel: CanvasViewModel

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            PropertySection(title: "Filter") {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignTokens.Spacing.sm) {
                    ForEach(PhotoFilter.allCases, id: \.self) { filterOption in
                        FilterButton(
                            filter: filterOption,
                            isSelected: filter == filterOption,
                            isPremium: filterOption.isPremium
                        ) {
                            updateFilter(filterOption)
                        }
                    }
                }
            }
        }
    }

    private func updateFilter(_ newFilter: PhotoFilter) {
        viewModel.updateImageFilter(id: elementId, filter: newFilter)
        HapticEngine.shared.selection()
    }
}

// MARK: - Shape Style Inspector

struct ShapeStyleInspector: View {
    let elementId: UUID
    let shapeType: ShapeType
    let fillColor: HexColor
    let strokeColor: HexColor?
    let strokeWidth: CGFloat
    @ObservedObject var viewModel: CanvasViewModel

    @State private var currentStrokeWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Fill color
            PropertySection(title: "Fill Color") {
                ColorSwatchPicker(
                    selectedColor: fillColor.hex,
                    onSelect: { hex in
                        updateFillColor(hex)
                    }
                )
            }

            // Stroke color
            PropertySection(title: "Stroke Color") {
                ColorSwatchPicker(
                    selectedColor: strokeColor?.hex ?? "TRANSPARENT",
                    onSelect: { hex in
                        updateStrokeColor(hex)
                    },
                    includeTransparent: true
                )
            }

            // Stroke width
            PropertySection(title: "Stroke Width") {
                HStack(spacing: DesignTokens.Spacing.md) {
                    Slider(value: $currentStrokeWidth, in: 0...10, step: 0.5)
                        .tint(Color.nuviaChampagne)
                        .onChange(of: currentStrokeWidth) { _, newValue in
                            updateStrokeWidth(newValue)
                        }

                    Text("\(String(format: "%.1f", currentStrokeWidth))pt")
                        .font(DSTypography.label(.regular))
                        .foregroundColor(.nuviaPrimaryText)
                        .frame(width: 50)
                }
            }
        }
        .onAppear {
            currentStrokeWidth = strokeWidth
        }
    }

    private func updateFillColor(_ hex: String) {
        viewModel.updateShapeColors(id: elementId, fillColor: HexColor(hex: hex), strokeColor: strokeColor)
        HapticEngine.shared.selection()
    }

    private func updateStrokeColor(_ hex: String) {
        let newStrokeColor = hex == "TRANSPARENT" ? nil : HexColor(hex: hex)
        viewModel.updateShapeColors(id: elementId, fillColor: fillColor, strokeColor: newStrokeColor)
        HapticEngine.shared.selection()
    }

    private func updateStrokeWidth(_ width: CGFloat) {
        viewModel.updateShapeStrokeWidth(id: elementId, width: width)
    }
}

// MARK: - Sticker Style Inspector

struct StickerStyleInspector: View {
    let elementId: UUID
    let assetName: String
    let isPremium: Bool
    @ObservedObject var viewModel: CanvasViewModel

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            PropertySection(title: "Sticker") {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    if assetName.hasPrefix("system:") {
                        Image(systemName: String(assetName.dropFirst(7)))
                            .font(.system(size: 48))
                            .foregroundColor(Color.nuviaChampagne)
                    }

                    if isPremium {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12))
                            Text("Premium Sticker")
                                .font(DSTypography.label(.small))
                        }
                        .foregroundColor(.nuviaChampagne)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(DesignTokens.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.nuviaTertiaryBackground)
                )
            }
        }
    }
}

// MARK: - Transform Inspector

struct TransformInspector: View {
    let elementId: UUID
    let transform: Transform
    @ObservedObject var viewModel: CanvasViewModel

    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Scale
            PropertySection(title: "Scale") {
                HStack(spacing: DesignTokens.Spacing.md) {
                    Slider(value: $scale, in: 0.25...3.0, step: 0.05)
                        .tint(Color.nuviaChampagne)
                        .onChange(of: scale) { _, newValue in
                            updateScale(newValue)
                        }

                    Text("\(Int(scale * 100))%")
                        .font(DSTypography.label(.regular))
                        .foregroundColor(.nuviaPrimaryText)
                        .frame(width: 50)
                }
            }

            // Rotation
            PropertySection(title: "Rotation") {
                HStack(spacing: DesignTokens.Spacing.md) {
                    Slider(value: $rotation, in: -180...180, step: 1)
                        .tint(Color.nuviaChampagne)
                        .onChange(of: rotation) { _, newValue in
                            updateRotation(newValue)
                        }

                    Text("\(Int(rotation))°")
                        .font(DSTypography.label(.regular))
                        .foregroundColor(.nuviaPrimaryText)
                        .frame(width: 50)
                }
            }

            // Quick rotation buttons
            PropertySection(title: "Quick Rotate") {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    QuickRotateButton(degrees: -90) {
                        rotation = (rotation - 90).truncatingRemainder(dividingBy: 360)
                        updateRotation(rotation)
                    }
                    QuickRotateButton(degrees: -45) {
                        rotation = (rotation - 45).truncatingRemainder(dividingBy: 360)
                        updateRotation(rotation)
                    }
                    QuickRotateButton(degrees: 0, label: "Reset") {
                        rotation = 0
                        updateRotation(0)
                    }
                    QuickRotateButton(degrees: 45) {
                        rotation = (rotation + 45).truncatingRemainder(dividingBy: 360)
                        updateRotation(rotation)
                    }
                    QuickRotateButton(degrees: 90) {
                        rotation = (rotation + 90).truncatingRemainder(dividingBy: 360)
                        updateRotation(rotation)
                    }
                }
            }

            // Position info
            PropertySection(title: "Position") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("X: \(Int(transform.offset.width))")
                        Text("Y: \(Int(transform.offset.height))")
                    }
                    .font(DSTypography.label(.regular))
                    .foregroundColor(.nuviaSecondaryText)

                    Spacer()

                    Button {
                        centerElement()
                    } label: {
                        Text("Center")
                            .font(DSTypography.label(.regular))
                            .foregroundColor(.nuviaChampagne)
                    }
                }
            }
        }
        .onAppear {
            scale = transform.scale
            rotation = transform.rotation.degrees
        }
    }

    private func updateScale(_ newScale: CGFloat) {
        viewModel.updateElementScale(id: elementId, scale: newScale)
    }

    private func updateRotation(_ degrees: Double) {
        viewModel.updateElementRotation(id: elementId, rotation: Angle(degrees: degrees))
        HapticEngine.shared.impact(.light)
    }

    private func centerElement() {
        viewModel.centerElement(id: elementId)
        HapticEngine.shared.impact(.medium)
    }
}

// MARK: - Effects Inspector

struct EffectsInspector: View {
    let elementId: UUID
    @ObservedObject var viewModel: CanvasViewModel

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Shadow (Premium)
            PropertySection(title: "Shadow", isPremium: true) {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    Text("Unlock Premium to add shadows")
                        .font(DSTypography.body(.small))
                        .foregroundColor(.nuviaSecondaryText)
                        .frame(maxWidth: .infinity)

                    Button {
                        // Show premium paywall
                        HapticEngine.shared.notify(.warning)
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                            Text("Upgrade to Premium")
                        }
                        .font(DSTypography.label(.regular))
                        .foregroundColor(.white)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .padding(.vertical, DesignTokens.Spacing.sm)
                        .background(
                            LinearGradient(
                                colors: [Color.nuviaChampagne, Color.nuviaRoseGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                    }
                }
                .padding(DesignTokens.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.nuviaTertiaryBackground)
                )
            }

            // Opacity
            PropertySection(title: "Opacity") {
                Text("Coming Soon")
                    .font(DSTypography.body(.small))
                    .foregroundColor(.nuviaTertiaryText)
                    .frame(maxWidth: .infinity)
                    .padding(DesignTokens.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.nuviaTertiaryText.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    )
            }
        }
    }
}

// MARK: - Property Section

struct PropertySection<Content: View>: View {
    let title: String
    var isPremium: Bool = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Text(title)
                    .font(DSTypography.label(.large))
                    .foregroundColor(.nuviaSecondaryText)

                if isPremium {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.nuviaChampagne)
                }
            }

            content()
        }
    }
}

// MARK: - Font Picker

struct FontPicker: View {
    let selectedFont: String
    let onSelect: (String) -> Void

    private let fonts: [(name: String, display: String, isPremium: Bool)] = [
        ("PlayfairDisplay-Regular", "Playfair Display", false),
        ("PlayfairDisplay-Bold", "Playfair Bold", false),
        ("Manrope-Regular", "Manrope", false),
        ("Manrope-Bold", "Manrope Bold", false),
        ("Georgia", "Georgia", false),
        ("Didot", "Didot", true),
        ("Baskerville", "Baskerville", true),
        ("Bodoni 72", "Bodoni", true)
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(fonts, id: \.name) { font in
                    FontChip(
                        name: font.name,
                        displayName: font.display,
                        isSelected: selectedFont == font.name,
                        isPremium: font.isPremium
                    ) {
                        if !font.isPremium {
                            onSelect(font.name)
                        } else {
                            HapticEngine.shared.notify(.warning)
                        }
                    }
                }
            }
        }
    }
}

struct FontChip: View {
    let name: String
    let displayName: String
    let isSelected: Bool
    let isPremium: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(displayName)
                    .font(.custom(name, size: 14))
                    .lineLimit(1)

                if isPremium {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                }
            }
            .foregroundColor(isSelected ? .white : (isPremium ? .nuviaTertiaryText : .nuviaPrimaryText))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.nuviaChampagne : (isPremium ? Color.nuviaTertiaryBackground.opacity(0.5) : Color.nuviaTertiaryBackground))
            )
        }
    }
}

// MARK: - Font Weight Picker

struct FontWeightPicker: View {
    let selected: CanvasFontWeight
    let onSelect: (CanvasFontWeight) -> Void

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            ForEach(CanvasFontWeight.allCases, id: \.self) { weight in
                Button {
                    onSelect(weight)
                } label: {
                    Text(weight.rawValue)
                        .font(.system(size: 12, weight: weight.swiftUIWeight))
                        .foregroundColor(selected == weight ? .white : .nuviaPrimaryText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(selected == weight ? Color.nuviaChampagne : Color.nuviaTertiaryBackground)
                        )
                }
            }
        }
    }
}

// MARK: - Color Swatch Picker

struct ColorSwatchPicker: View {
    let selectedColor: String
    let onSelect: (String) -> Void
    var includeTransparent: Bool = false

    private let colors: [String] = [
        "2C2C2C", "6B6B6B", "9A9A9A", "FFFFFF",
        "D4AF37", "C9A9A6", "9CAF88", "A3B5C4",
        "E8D5D5", "B5A3C4", "C4A389", "8B4557"
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
            if includeTransparent {
                ColorSwatch(
                    hex: "TRANSPARENT",
                    isSelected: selectedColor == "TRANSPARENT",
                    isTransparent: true
                ) {
                    onSelect("TRANSPARENT")
                }
            }

            ForEach(colors, id: \.self) { hex in
                ColorSwatch(
                    hex: hex,
                    isSelected: selectedColor == hex
                ) {
                    onSelect(hex)
                }
            }
        }
    }
}

struct ColorSwatch: View {
    let hex: String
    let isSelected: Bool
    var isTransparent: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isTransparent {
                    // Checkerboard pattern for transparent
                    Image(systemName: "slash.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.nuviaTertiaryText)
                } else {
                    Circle()
                        .fill(Color(hex: hex))
                }

                if isSelected {
                    Circle()
                        .stroke(Color.nuviaChampagne, lineWidth: 3)

                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(hex == "FFFFFF" || hex == "D4AF37" ? .black : .white)
                }
            }
            .frame(width: 40, height: 40)
        }
    }
}

// MARK: - Alignment Picker

struct AlignmentPicker: View {
    let selected: CanvasTextAlignment
    let onSelect: (CanvasTextAlignment) -> Void

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(CanvasTextAlignment.allCases, id: \.self) { alignment in
                Button {
                    onSelect(alignment)
                } label: {
                    Image(systemName: alignment.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selected == alignment ? .white : .nuviaPrimaryText)
                        .frame(width: 44, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(selected == alignment ? Color.nuviaChampagne : Color.nuviaTertiaryBackground)
                        )
                }
            }
        }
    }
}

// MARK: - Filter Button

struct FilterButton: View {
    let filter: PhotoFilter
    let isSelected: Bool
    let isPremium: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 50)
                        .overlay(
                            Text(filter.rawValue.prefix(3).uppercased())
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        )

                    if isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.nuviaChampagne)
                            .padding(4)
                    }
                }

                Text(filter.rawValue)
                    .font(DSTypography.label(.small))
                    .foregroundColor(isSelected ? .nuviaChampagne : .nuviaSecondaryText)
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? Color.nuviaChampagne : Color.clear, lineWidth: 2)
            )
        }
        .opacity(isPremium ? 0.6 : 1.0)
    }
}

// MARK: - Quick Rotate Button

struct QuickRotateButton: View {
    let degrees: Double
    var label: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label ?? "\(Int(degrees))°")
                .font(DSTypography.label(.small))
                .foregroundColor(.nuviaPrimaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.nuviaTertiaryBackground)
                )
        }
    }
}

// MARK: - CanvasTextAlignment Extension

extension CanvasTextAlignment {
    var icon: String {
        switch self {
        case .leading:  return "text.alignleft"
        case .center:   return "text.aligncenter"
        case .trailing: return "text.alignright"
        }
    }
}

// MARK: - PhotoFilter Extension

extension PhotoFilter {
    var isPremium: Bool {
        switch self {
        case .none, .sepia, .mono:
            return false
        default:
            return true
        }
    }
}

// MARK: - ViewModel Extensions for Property Updates

extension CanvasViewModel {
    func updateTextElement(id: UUID, content: String) {
        guard let index = elements.firstIndex(where: { $0.id == id }),
              case .text(let elementId, _, let color, let style, let transform) = elements[index] else { return }

        saveToHistory()
        elements[index] = .text(id: elementId, content: content, color: color, style: style, transform: transform)
    }

    func updateTextStyle(id: UUID, modifier: (CanvasTextStyle) -> CanvasTextStyle) {
        guard let index = elements.firstIndex(where: { $0.id == id }),
              case .text(let elementId, let content, let color, let style, let transform) = elements[index] else { return }

        saveToHistory()
        let newStyle = modifier(style)
        elements[index] = .text(id: elementId, content: content, color: color, style: newStyle, transform: transform)
    }

    func updateTextColor(id: UUID, color: HexColor) {
        guard let index = elements.firstIndex(where: { $0.id == id }),
              case .text(let elementId, let content, _, let style, let transform) = elements[index] else { return }

        saveToHistory()
        elements[index] = .text(id: elementId, content: content, color: color, style: style, transform: transform)
    }

    func updateImageFilter(id: UUID, filter: PhotoFilter) {
        guard let index = elements.firstIndex(where: { $0.id == id }),
              case .image(let elementId, let data, _, let transform) = elements[index] else { return }

        saveToHistory()
        elements[index] = .image(id: elementId, imageData: data, filter: filter, transform: transform)
    }

    func updateShapeColors(id: UUID, fillColor: HexColor, strokeColor: HexColor?) {
        guard let index = elements.firstIndex(where: { $0.id == id }),
              case .shape(let elementId, let type, _, _, let strokeWidth, let transform) = elements[index] else { return }

        saveToHistory()
        elements[index] = .shape(id: elementId, type: type, fillColor: fillColor, strokeColor: strokeColor, strokeWidth: strokeWidth, transform: transform)
    }

    func updateShapeStrokeWidth(id: UUID, width: CGFloat) {
        guard let index = elements.firstIndex(where: { $0.id == id }),
              case .shape(let elementId, let type, let fill, let stroke, _, let transform) = elements[index] else { return }

        saveToHistory()
        elements[index] = .shape(id: elementId, type: type, fillColor: fill, strokeColor: stroke, strokeWidth: width, transform: transform)
    }

    func updateElementScale(id: UUID, scale: CGFloat) {
        guard let index = elements.firstIndex(where: { $0.id == id }) else { return }

        saveToHistory()
        var element = elements[index]
        var transform = element.transform
        transform.scale = scale
        elements[index] = element.withTransform(transform)
    }

    func updateElementRotation(id: UUID, rotation: Angle) {
        guard let index = elements.firstIndex(where: { $0.id == id }) else { return }

        saveToHistory()
        var element = elements[index]
        var transform = element.transform
        transform.rotation = rotation
        elements[index] = element.withTransform(transform)
    }

    func centerElement(id: UUID) {
        guard let index = elements.firstIndex(where: { $0.id == id }) else { return }

        saveToHistory()
        var element = elements[index]
        var transform = element.transform
        transform.offset = .zero
        elements[index] = element.withTransform(transform)
    }
}

// MARK: - Preview

#Preview("Property Inspector") {
    @Previewable @State var isPresented = true

    let viewModel = CanvasViewModel(canvasSize: CGSize(width: 375, height: 500))

    let _ = {
        let element = CanvasElement.text(
            id: UUID(),
            content: "Emma & James",
            color: HexColor(hex: "2C2C2C"),
            style: CanvasTextStyle(
                fontFamily: "PlayfairDisplay-Bold",
                fontSize: 32,
                fontWeight: .bold,
                letterSpacing: 1,
                lineHeight: 1.2,
                alignment: .center
            ),
            transform: Transform()
        )
        viewModel.addElement(element)
        viewModel.selectElement(element.id)
    }()

    return ZStack {
        Color.nuviaBackground.ignoresSafeArea()

        VStack {
            Spacer()
            PropertyInspector(viewModel: viewModel, isPresented: $isPresented)
        }
    }
}
