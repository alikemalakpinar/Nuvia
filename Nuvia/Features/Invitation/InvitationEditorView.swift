import SwiftUI
import SwiftData

// MARK: - Invitation Studio (Canva-like Editor)
// The killer feature - premium revenue driver

struct InvitationEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    @State private var selectedTemplate: InvitationTemplate = .minimal
    @State private var canvasElements: [CanvasElement] = []
    @State private var selectedElementId: UUID?
    @State private var showTemplateGallery = true
    @State private var showTextEditor = false
    @State private var showStickerPicker = false
    @State private var showBackgroundPicker = false
    @State private var showPaywall = false
    @State private var canvasScale: CGFloat = 1.0
    @State private var backgroundColor: Color = .white

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.nuviaBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Canvas Area
                    GeometryReader { geometry in
                        ScrollView([.horizontal, .vertical], showsIndicators: false) {
                            InvitationCanvas(
                                elements: $canvasElements,
                                selectedElementId: $selectedElementId,
                                backgroundColor: backgroundColor,
                                template: selectedTemplate,
                                project: currentProject
                            )
                            .scaleEffect(canvasScale)
                            .frame(
                                width: max(geometry.size.width, 375),
                                height: max(geometry.size.height, 600)
                            )
                        }
                    }
                    .background(Color.nuviaTertiaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Toolbar
                    EditorToolbar(
                        onAddText: { showTextEditor = true },
                        onAddSticker: { showStickerPicker = true },
                        onChangeBackground: { showBackgroundPicker = true },
                        onZoomIn: { withAnimation(.etherealSpring) { canvasScale = min(canvasScale + 0.2, 2.0) } },
                        onZoomOut: { withAnimation(.etherealSpring) { canvasScale = max(canvasScale - 0.2, 0.5) } }
                    )
                    .padding(.vertical, 16)

                    // Bottom Action Bar
                    HStack(spacing: 16) {
                        NuviaPrimaryButton("Preview", icon: "eye", style: .outlined) {
                            // Show preview
                        }

                        NuviaPrimaryButton("Export", icon: "square.and.arrow.up") {
                            checkPremiumAndExport()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Invitation Studio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.nuviaPrimaryText)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showTemplateGallery = true
                    } label: {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.nuviaChampagne)
                    }
                }
            }
            .sheet(isPresented: $showTemplateGallery) {
                TemplateGalleryView(
                    selectedTemplate: $selectedTemplate,
                    onSelect: { template in
                        selectedTemplate = template
                        loadTemplateElements(template)
                        showTemplateGallery = false
                    }
                )
            }
            .sheet(isPresented: $showTextEditor) {
                TextElementEditor { textElement in
                    canvasElements.append(textElement)
                    showTextEditor = false
                }
            }
            .sheet(isPresented: $showStickerPicker) {
                StickerPicker(
                    onSelect: { sticker in
                        let element = CanvasElement(
                            type: .sticker(sticker),
                            position: CGPoint(x: 187, y: 300),
                            size: CGSize(width: 80, height: 80),
                            rotation: 0,
                            isPremium: sticker.isPremium
                        )
                        canvasElements.append(element)
                        showStickerPicker = false
                    },
                    onPremiumRequired: {
                        showStickerPicker = false
                        showPaywall = true
                    }
                )
            }
            .sheet(isPresented: $showBackgroundPicker) {
                BackgroundPicker(
                    selectedColor: $backgroundColor,
                    onSelectPremium: {
                        showBackgroundPicker = false
                        showPaywall = true
                    }
                )
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .onAppear {
            if canvasElements.isEmpty {
                loadTemplateElements(selectedTemplate)
            }
        }
    }

    private func loadTemplateElements(_ template: InvitationTemplate) {
        guard let project = currentProject else { return }

        canvasElements = [
            // Header text
            CanvasElement(
                type: .text(TextStyle(
                    content: "You're Invited",
                    font: .displaySmall,
                    color: template.accentColor
                )),
                position: CGPoint(x: 187, y: 80),
                size: CGSize(width: 300, height: 50),
                rotation: 0,
                isPremium: false
            ),
            // Names
            CanvasElement(
                type: .text(TextStyle(
                    content: "\(project.partnerName1)\n&\n\(project.partnerName2)",
                    font: .displayMedium,
                    color: .nuviaPrimaryText
                )),
                position: CGPoint(x: 187, y: 200),
                size: CGSize(width: 320, height: 150),
                rotation: 0,
                isPremium: false
            ),
            // Date
            CanvasElement(
                type: .text(TextStyle(
                    content: project.weddingDate.formatted(date: .complete, time: .omitted),
                    font: .body,
                    color: .nuviaSecondaryText
                )),
                position: CGPoint(x: 187, y: 350),
                size: CGSize(width: 280, height: 30),
                rotation: 0,
                isPremium: false
            )
        ]
    }

    private func checkPremiumAndExport() {
        let hasPremiumElements = canvasElements.contains { $0.isPremium }

        if hasPremiumElements && !appState.isPremium {
            showPaywall = true
        } else {
            exportInvitation()
        }
    }

    private func exportInvitation() {
        // Use ImageRenderer to export canvas
        HapticManager.shared.success()
    }
}

// MARK: - Canvas Element Model

struct CanvasElement: Identifiable {
    let id = UUID()
    var type: ElementType
    var position: CGPoint
    var size: CGSize
    var rotation: Double
    var isPremium: Bool

    enum ElementType {
        case text(TextStyle)
        case sticker(StickerAsset)
        case shape(ShapeType)
        case image(String)
    }
}

struct TextStyle {
    var content: String
    var font: NuviaTextStyle
    var color: Color
    var alignment: TextAlignment = .center
}

struct StickerAsset: Identifiable {
    let id = UUID()
    let name: String
    let systemIcon: String
    let isPremium: Bool
    let category: StickerCategory

    enum StickerCategory: String, CaseIterable {
        case floral = "Floral"
        case geometric = "Geometric"
        case romantic = "Romantic"
        case classic = "Classic"
    }
}

enum ShapeType {
    case rectangle, circle, line, divider
}

// MARK: - Invitation Canvas

struct InvitationCanvas: View {
    @Binding var elements: [CanvasElement]
    @Binding var selectedElementId: UUID?
    let backgroundColor: Color
    let template: InvitationTemplate
    let project: WeddingProject?

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(backgroundColor)
                .frame(width: 375, height: 600)
                .etherealShadow(.pronounced)

            // Template decorations
            TemplateDecoration(template: template)

            // Canvas elements
            ForEach(elements) { element in
                CanvasElementView(
                    element: element,
                    isSelected: selectedElementId == element.id,
                    onSelect: { selectedElementId = element.id },
                    onMove: { newPosition in
                        if let index = elements.firstIndex(where: { $0.id == element.id }) {
                            elements[index].position = newPosition
                        }
                    },
                    onResize: { newSize in
                        if let index = elements.firstIndex(where: { $0.id == element.id }) {
                            elements[index].size = newSize
                        }
                    },
                    onRotate: { newRotation in
                        if let index = elements.firstIndex(where: { $0.id == element.id }) {
                            elements[index].rotation = newRotation
                        }
                    }
                )
            }
        }
        .frame(width: 375, height: 600)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedElementId = nil
        }
    }
}

// MARK: - Canvas Element View

struct CanvasElementView: View {
    let element: CanvasElement
    let isSelected: Bool
    let onSelect: () -> Void
    let onMove: (CGPoint) -> Void
    let onResize: (CGSize) -> Void
    let onRotate: (Double) -> Void

    @State private var dragOffset: CGSize = .zero
    @GestureState private var isDragging = false

    var body: some View {
        elementContent
            .frame(width: element.size.width, height: element.size.height)
            .rotationEffect(.degrees(element.rotation))
            .position(
                x: element.position.x + dragOffset.width,
                y: element.position.y + dragOffset.height
            )
            .overlay(
                Group {
                    if isSelected {
                        SelectionOverlay(size: element.size)
                            .rotationEffect(.degrees(element.rotation))
                            .position(
                                x: element.position.x + dragOffset.width,
                                y: element.position.y + dragOffset.height
                            )
                    }
                }
            )
            .gesture(
                DragGesture()
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        let newPosition = CGPoint(
                            x: element.position.x + value.translation.width,
                            y: element.position.y + value.translation.height
                        )
                        onMove(newPosition)
                        dragOffset = .zero
                    }
            )
            .onTapGesture {
                HapticManager.shared.selection()
                onSelect()
            }
    }

    @ViewBuilder
    private var elementContent: some View {
        switch element.type {
        case .text(let style):
            Text(style.content)
                .font(style.font.font)
                .foregroundColor(style.color)
                .multilineTextAlignment(style.alignment)
                .lineSpacing(4)

        case .sticker(let sticker):
            ZStack {
                Image(systemName: sticker.systemIcon)
                    .font(.system(size: min(element.size.width, element.size.height) * 0.7))
                    .foregroundColor(.nuviaChampagne)

                if sticker.isPremium {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.nuviaChampagne)
                                .padding(4)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                }
            }

        case .shape(let shapeType):
            switch shapeType {
            case .rectangle:
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.nuviaChampagne, lineWidth: 1)
            case .circle:
                Circle()
                    .stroke(Color.nuviaChampagne, lineWidth: 1)
            case .line:
                Rectangle()
                    .fill(Color.nuviaChampagne)
                    .frame(height: 1)
            case .divider:
                HStack(spacing: 8) {
                    Rectangle().fill(Color.nuviaChampagne).frame(height: 1)
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.nuviaChampagne)
                    Rectangle().fill(Color.nuviaChampagne).frame(height: 1)
                }
            }

        case .image:
            Rectangle()
                .fill(Color.nuviaTertiaryBackground)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.nuviaSecondaryText)
                )
        }
    }
}

// MARK: - Selection Overlay

struct SelectionOverlay: View {
    let size: CGSize

    var body: some View {
        ZStack {
            Rectangle()
                .stroke(Color.nuviaChampagne, lineWidth: 1)
                .frame(width: size.width + 8, height: size.height + 8)

            // Corner handles
            ForEach(corners, id: \.self) { corner in
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.nuviaChampagne, lineWidth: 1))
                    .position(cornerPosition(corner, size: size))
            }
        }
    }

    private var corners: [Corner] { [.topLeft, .topRight, .bottomLeft, .bottomRight] }

    private enum Corner: Hashable {
        case topLeft, topRight, bottomLeft, bottomRight
    }

    private func cornerPosition(_ corner: Corner, size: CGSize) -> CGPoint {
        let halfWidth = (size.width + 8) / 2
        let halfHeight = (size.height + 8) / 2

        switch corner {
        case .topLeft: return CGPoint(x: -halfWidth, y: -halfHeight)
        case .topRight: return CGPoint(x: halfWidth, y: -halfHeight)
        case .bottomLeft: return CGPoint(x: -halfWidth, y: halfHeight)
        case .bottomRight: return CGPoint(x: halfWidth, y: halfHeight)
        }
    }
}

// MARK: - Template Decoration

struct TemplateDecoration: View {
    let template: InvitationTemplate

    var body: some View {
        ZStack {
            switch template {
            case .floral:
                // Top left corner decoration
                Image(systemName: "leaf.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.nuviaSage.opacity(0.2))
                    .rotationEffect(.degrees(-45))
                    .position(x: 40, y: 40)

                // Bottom right corner
                Image(systemName: "leaf.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.nuviaSage.opacity(0.2))
                    .rotationEffect(.degrees(135))
                    .position(x: 335, y: 560)

            case .romantic:
                ForEach(0..<5) { i in
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.nuviaRoseDust.opacity(0.15))
                        .position(
                            x: CGFloat.random(in: 20...355),
                            y: CGFloat.random(in: 20...580)
                        )
                }

            case .luxury:
                // Gold frame
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.nuviaChampagne.opacity(0.3), lineWidth: 2)
                    .padding(20)

                // Corner ornaments
                Image(systemName: "crown.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.nuviaChampagne.opacity(0.3))
                    .position(x: 187, y: 30)

            case .modern:
                // Geometric shapes
                Circle()
                    .stroke(Color.nuviaDustyBlue.opacity(0.1), lineWidth: 40)
                    .frame(width: 200, height: 200)
                    .position(x: 320, y: 80)

                Circle()
                    .stroke(Color.nuviaRoseDust.opacity(0.1), lineWidth: 30)
                    .frame(width: 150, height: 150)
                    .position(x: 50, y: 520)

            case .classic:
                // Border with ornaments
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.nuviaTerracotta.opacity(0.3), lineWidth: 1)
                    .padding(30)

            case .minimal:
                EmptyView()
            }
        }
    }
}

// MARK: - Editor Toolbar

struct EditorToolbar: View {
    let onAddText: () -> Void
    let onAddSticker: () -> Void
    let onChangeBackground: () -> Void
    let onZoomIn: () -> Void
    let onZoomOut: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ToolbarButton(icon: "textformat", label: "Text", action: onAddText)
                ToolbarButton(icon: "star.fill", label: "Stickers", action: onAddSticker)
                ToolbarButton(icon: "paintpalette.fill", label: "Background", action: onChangeBackground)

                Divider().frame(height: 40)

                ToolbarButton(icon: "plus.magnifyingglass", label: "Zoom In", action: onZoomIn)
                ToolbarButton(icon: "minus.magnifyingglass", label: "Zoom Out", action: onZoomOut)
            }
            .padding(.horizontal, 20)
        }
    }
}

struct ToolbarButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.nuviaChampagne)
                    .frame(width: 48, height: 48)
                    .background(Color.nuviaSurface)
                    .cornerRadius(14)
                    .etherealShadow(.whisper)

                Text(label)
                    .font(NuviaTypography.caption2())
                    .foregroundColor(.nuviaSecondaryText)
            }
        }
        .pressEffect()
    }
}

// MARK: - Template Gallery

struct TemplateGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTemplate: InvitationTemplate
    let onSelect: (InvitationTemplate) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Choose Your Style")
                        .font(NuviaTypography.displaySmall())
                        .foregroundColor(.nuviaPrimaryText)
                        .padding(.top, 20)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(InvitationTemplate.allCases, id: \.self) { template in
                            TemplatePreviewCard(
                                template: template,
                                isSelected: selectedTemplate == template
                            ) {
                                onSelect(template)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
            .background(Color.nuviaBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.nuviaChampagne)
                }
            }
        }
    }
}

struct TemplatePreviewCard: View {
    let template: InvitationTemplate
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.nuviaSurface)
                        .frame(height: 180)
                        .overlay(
                            TemplateDecoration(template: template)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        )
                        .etherealShadow(isSelected ? .medium : .soft)

                    VStack(spacing: 8) {
                        Image(systemName: template.icon)
                            .font(.system(size: 32))
                            .foregroundColor(template.accentColor)

                        Text("Names")
                            .font(NuviaTypography.title3())
                            .foregroundColor(.nuviaPrimaryText)

                        Text("Date")
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                    }

                    if template.isPremium {
                        VStack {
                            HStack {
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                    Text("PRO")
                                }
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.nuviaChampagne)
                                .cornerRadius(8)
                                .padding(8)
                            }
                            Spacer()
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? template.accentColor : Color.clear, lineWidth: 2)
                )

                Text(template.rawValue)
                    .font(NuviaTypography.caption())
                    .foregroundColor(isSelected ? .nuviaPrimaryText : .nuviaSecondaryText)
            }
        }
        .pressEffect()
    }
}

// MARK: - Text Element Editor

struct TextElementEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var selectedFont: NuviaTextStyle = .title2
    @State private var selectedColor: Color = .nuviaPrimaryText
    let onSave: (CanvasElement) -> Void

    private let fonts: [NuviaTextStyle] = [.displayLarge, .displayMedium, .title1, .title2, .body, .caption]
    private let colors: [Color] = [.nuviaPrimaryText, .nuviaSecondaryText, .nuviaChampagne, .nuviaRoseDust, .nuviaSage]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Preview
                Text(text.isEmpty ? "Your text here" : text)
                    .font(selectedFont.font)
                    .foregroundColor(selectedColor)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .background(Color.nuviaTertiaryBackground)
                    .cornerRadius(20)

                // Text input
                TextField("Enter text", text: $text, axis: .vertical)
                    .font(NuviaTypography.body())
                    .padding()
                    .background(Color.nuviaTertiaryBackground)
                    .cornerRadius(14)
                    .lineLimit(3...6)

                // Font picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("FONT STYLE")
                        .font(NuviaTypography.overline())
                        .foregroundColor(.nuviaSecondaryText)
                        .tracking(1)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(fonts, id: \.self) { font in
                                Button {
                                    selectedFont = font
                                } label: {
                                    Text("Aa")
                                        .font(font.font)
                                        .foregroundColor(selectedFont == font ? .nuviaChampagne : .nuviaSecondaryText)
                                        .frame(width: 60, height: 60)
                                        .background(Color.nuviaTertiaryBackground)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedFont == font ? Color.nuviaChampagne : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                    }
                }

                // Color picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("COLOR")
                        .font(NuviaTypography.overline())
                        .foregroundColor(.nuviaSecondaryText)
                        .tracking(1)

                    HStack(spacing: 16) {
                        ForEach(colors, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.nuviaChampagne : Color.clear, lineWidth: 2)
                                            .padding(-4)
                                    )
                            }
                        }
                    }
                }

                Spacer()

                NuviaPrimaryButton("Add Text", icon: "plus") {
                    guard !text.isEmpty else { return }
                    let element = CanvasElement(
                        type: .text(TextStyle(content: text, font: selectedFont, color: selectedColor)),
                        position: CGPoint(x: 187, y: 300),
                        size: CGSize(width: 300, height: 100),
                        rotation: 0,
                        isPremium: false
                    )
                    onSave(element)
                }
            }
            .padding(20)
            .background(Color.nuviaBackground)
            .navigationTitle("Add Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.nuviaSecondaryText)
                }
            }
        }
    }
}

// MARK: - Sticker Picker

struct StickerPicker: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (StickerAsset) -> Void
    let onPremiumRequired: () -> Void

    @State private var selectedCategory: StickerAsset.StickerCategory = .floral

    private let stickers: [StickerAsset] = [
        // Free
        StickerAsset(name: "Heart", systemIcon: "heart.fill", isPremium: false, category: .romantic),
        StickerAsset(name: "Star", systemIcon: "star.fill", isPremium: false, category: .classic),
        StickerAsset(name: "Leaf", systemIcon: "leaf.fill", isPremium: false, category: .floral),
        StickerAsset(name: "Circle", systemIcon: "circle.fill", isPremium: false, category: .geometric),
        // Premium
        StickerAsset(name: "Crown", systemIcon: "crown.fill", isPremium: true, category: .classic),
        StickerAsset(name: "Sparkles", systemIcon: "sparkles", isPremium: true, category: .romantic),
        StickerAsset(name: "Flower", systemIcon: "camera.macro", isPremium: true, category: .floral),
        StickerAsset(name: "Diamond", systemIcon: "diamond.fill", isPremium: true, category: .geometric),
        StickerAsset(name: "Rings", systemIcon: "circles.hexagonpath.fill", isPremium: true, category: .romantic),
        StickerAsset(name: "Dove", systemIcon: "bird.fill", isPremium: true, category: .classic),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Category tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(StickerAsset.StickerCategory.allCases, id: \.self) { category in
                            NuviaFilterChip(
                                title: category.rawValue,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Stickers grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(stickers.filter { $0.category == selectedCategory }) { sticker in
                        StickerCell(sticker: sticker) {
                            if sticker.isPremium {
                                onPremiumRequired()
                            } else {
                                onSelect(sticker)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Stickers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.nuviaChampagne)
                }
            }
        }
    }
}

struct StickerCell: View {
    let sticker: StickerAsset
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.nuviaTertiaryBackground)
                    .frame(width: 70, height: 70)

                Image(systemName: sticker.systemIcon)
                    .font(.system(size: 28))
                    .foregroundColor(.nuviaChampagne)

                if sticker.isPremium {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.nuviaChampagne)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(4)
                }
            }
        }
        .pressEffect()
    }
}

// MARK: - Background Picker

struct BackgroundPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColor: Color
    let onSelectPremium: () -> Void

    private let freeColors: [Color] = [.white, Color(hex: "FAFAF9"), Color(hex: "F5F4F2")]
    private let premiumColors: [Color] = [Color(hex: "E8D5D5"), Color(hex: "D5E8E0"), Color(hex: "E0D5E8"), Color(hex: "E8E0D5")]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Free colors
                VStack(alignment: .leading, spacing: 12) {
                    Text("FREE")
                        .font(NuviaTypography.overline())
                        .foregroundColor(.nuviaSecondaryText)
                        .tracking(1)

                    HStack(spacing: 16) {
                        ForEach(freeColors, id: \.self) { color in
                            ColorCell(color: color, isSelected: selectedColor == color, isPremium: false) {
                                selectedColor = color
                            }
                        }
                    }
                }

                // Premium colors
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("PREMIUM")
                            .font(NuviaTypography.overline())
                            .foregroundColor(.nuviaSecondaryText)
                            .tracking(1)

                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.nuviaChampagne)
                    }

                    HStack(spacing: 16) {
                        ForEach(premiumColors, id: \.self) { color in
                            ColorCell(color: color, isSelected: false, isPremium: true) {
                                onSelectPremium()
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(20)
            .background(Color.nuviaBackground)
            .navigationTitle("Background")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.nuviaChampagne)
                }
            }
        }
    }
}

struct ColorCell: View {
    let color: Color
    let isSelected: Bool
    let isPremium: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .frame(width: 60, height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.nuviaChampagne : Color.clear, lineWidth: 2)
                            .padding(-2)
                    )

                if isPremium {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.nuviaSecondaryText)
                }
            }
        }
    }
}

// MARK: - Invitation Template

enum InvitationTemplate: String, CaseIterable {
    case minimal = "Minimal"
    case floral = "Floral"
    case modern = "Modern"
    case luxury = "Luxury"
    case classic = "Classic"
    case romantic = "Romantic"

    var accentColor: Color {
        switch self {
        case .minimal: return .nuviaSecondaryText
        case .floral: return .nuviaSage
        case .modern: return .nuviaDustyBlue
        case .luxury: return .nuviaChampagne
        case .classic: return .nuviaTerracotta
        case .romantic: return .nuviaRoseDust
        }
    }

    var icon: String {
        switch self {
        case .minimal: return "square"
        case .floral: return "leaf.fill"
        case .modern: return "diamond.fill"
        case .luxury: return "crown.fill"
        case .classic: return "scroll.fill"
        case .romantic: return "heart.fill"
        }
    }

    var isPremium: Bool {
        switch self {
        case .minimal, .floral: return false
        case .modern, .luxury, .classic, .romantic: return true
        }
    }
}

// MARK: - Preview

#Preview {
    InvitationEditorView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
