import SwiftUI
import SwiftData

// MARK: - Design Constants (Eliminates type ambiguity)
// These private constants provide unambiguous access to design tokens

private enum StudioSpacing {
    static let xxxs: CGFloat = StudioSpacing.xxxs
    static let xxs: CGFloat = StudioSpacing.xxs
    static let xs: CGFloat = StudioSpacing.xs
    static let sm: CGFloat = StudioSpacing.sm
    static let md: CGFloat = StudioSpacing.md
    static let lg: CGFloat = StudioSpacing.lg
    static let xl: CGFloat = StudioSpacing.xl
    static let xxl: CGFloat = StudioSpacing.xxl
}

private enum StudioRadius {
    static let xs: CGFloat = StudioRadius.xs
    static let sm: CGFloat = StudioRadius.sm
    static let md: CGFloat = StudioRadius.md
    static let lg: CGFloat = StudioRadius.lg
    static let xl: CGFloat = StudioRadius.xl
    static let xxl: CGFloat = StudioRadius.xxl
}

private enum StudioStrings {
    static let add: String = L10n.Studio.add
    static let layers: String = L10n.Studio.layers
    static let edit: String = L10n.Studio.edit
    static let templates: String = L10n.Studio.templates
    static let export: String = L10n.Studio.export
}

// MARK: - Invitation Studio View
// Premium Canva-style invitation editor with layer-based composition
// Uses the new Canvas Engine for professional-grade editing

struct InvitationStudioView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Query private var projects: [WeddingProject]
    @EnvironmentObject var appState: AppState

    // Canvas State
    @State private var viewModel: CanvasViewModel
    @State private var canvasScale: CGFloat = 1.0
    @State private var canvasOffset: CGSize = .zero

    // Panel State
    @State private var showLayerSheet = false
    @State private var showPropertyInspector = false
    @State private var showElementPicker = false
    @State private var showTemplatePicker = false
    @State private var showExportOptions = false
    @State private var showPaywall = false

    // Element picker state
    @State private var selectedPickerTab: ElementPickerTab = .text

    private var currentProject: WeddingProject? {
        projects.first { $0.id.uuidString == appState.currentProjectId }
    }

    init() {
        _viewModel = State(initialValue: CanvasViewModel(
            canvasSize: CGSize(width: 375, height: 550)
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.nuviaBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top toolbar
                    topToolbar

                    // Canvas area
                    canvasArea
                        .layoutPriority(1)

                    // Bottom toolbar
                    bottomToolbar
                }

                // Floating panels
                floatingPanels
            }
            .navigationBarHidden(true)
            .onAppear {
                setupInitialCanvas()
            }
            .sheet(isPresented: $showTemplatePicker) {
                StudioTemplatePicker { template in
                    applyTemplate(template)
                    showTemplatePicker = false
                }
            }
            .sheet(isPresented: $showExportOptions) {
                ExportOptionsSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - Top Toolbar

    private var topToolbar: some View {
        HStack(spacing: StudioSpacing.md) {
            // Close button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.nuviaPrimaryText)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.nuviaSurface)
                    )
                    .elevation(.raised)
            }

            Spacer()

            // Title
            VStack(spacing: 2) {
                Text("Invitation Studio")
                    .font(DSTypography.heading(.h4))
                    .foregroundColor(.nuviaPrimaryText)

                if let project = currentProject {
                    Text("\(project.partnerName1) & \(project.partnerName2)")
                        .font(DSTypography.caption)
                        .foregroundColor(.nuviaTertiaryText)
                }
            }

            Spacer()

            // Undo/Redo
            HStack(spacing: StudioSpacing.xs) {
                ToolbarIconButton(
                    icon: "arrow.uturn.backward",
                    isEnabled: viewModel.canUndo
                ) {
                    viewModel.undo()
                    HapticEngine.shared.impact(.light)
                }

                ToolbarIconButton(
                    icon: "arrow.uturn.forward",
                    isEnabled: viewModel.canRedo
                ) {
                    viewModel.redo()
                    HapticEngine.shared.impact(.light)
                }
            }
        }
        .padding(.horizontal, StudioSpacing.md)
        .padding(.vertical, StudioSpacing.sm)
        .background(
            Color.nuviaSurface
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Canvas Area

    private var canvasArea: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                ZStack {
                    // Canvas background
                    canvasBackground

                    // Elements
                    ForEach(viewModel.sortedElements) { element in
                        MovableElementView(viewModel: viewModel, element: element) {
                            StudioElementContentView(element: element)
                        }
                    }
                }
                .frame(width: viewModel.canvasSize.width, height: viewModel.canvasSize.height)
                .clipShape(RoundedRectangle(cornerRadius: StudioRadius.lg, style: .continuous))
                .elevation(.floating)
                .scaleEffect(canvasScale)
                .offset(canvasOffset)
                .gesture(canvasGesture)
                .frame(
                    width: max(geometry.size.width, viewModel.canvasSize.width * canvasScale + 80),
                    height: max(geometry.size.height, viewModel.canvasSize.height * canvasScale + 80)
                )
            }
            .background(canvasBackdrop)
            .contentShape(Rectangle())
            .onTapGesture {
                // Deselect element when tapping canvas background
                viewModel.selectElement(id: nil)
            }
        }
    }

    private var canvasBackground: some View {
        ZStack {
            // Background color or image
            if let bgData = viewModel.state.backgroundImageData,
               let uiImage = UIImage(data: bgData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(viewModel.state.backgroundColor.color)
            }
        }
        .frame(width: viewModel.canvasSize.width, height: viewModel.canvasSize.height)
    }

    private var canvasBackdrop: some View {
        ZStack {
            // Checkerboard pattern to indicate canvas bounds
            Color.nuviaTertiaryBackground

            // Grid pattern
            GeometryReader { geo in
                Path { path in
                    let gridSize: CGFloat = 20
                    for x in stride(from: 0, to: geo.size.width, by: gridSize) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geo.size.height))
                    }
                    for y in stride(from: 0, to: geo.size.height, by: gridSize) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    }
                }
                .stroke(Color.black.opacity(0.03), lineWidth: 0.5)
            }
        }
    }

    private var canvasGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                // Clamp scale between 50% and 200% for stable experience
                let newScale = max(0.5, min(2.0, value))
                canvasScale = newScale
            }
    }

    // MARK: - Bottom Toolbar (Floating Glass Design)

    private var bottomToolbar: some View {
        VStack(spacing: StudioSpacing.xs) {
            // Quick action bar (floating glass)
            quickActionBar

            // Main toolbar (floating glass capsule)
            HStack(spacing: 0) {
                // Add elements
                GlassToolbarTab(icon: "plus.circle.fill", label: StudioStrings.add, isActive: showElementPicker) {
                    withAnimation(MotionCurves.quick) {
                        showElementPicker.toggle()
                        showLayerSheet = false
                        showPropertyInspector = false
                    }
                    HapticEngine.shared.selection()
                }

                // Layers
                GlassToolbarTab(icon: "square.3.layers.3d", label: StudioStrings.layers, isActive: showLayerSheet) {
                    withAnimation(MotionCurves.quick) {
                        showLayerSheet.toggle()
                        showElementPicker = false
                        showPropertyInspector = false
                    }
                    HapticEngine.shared.selection()
                }

                // Properties
                GlassToolbarTab(
                    icon: "slider.horizontal.3",
                    label: StudioStrings.edit,
                    isActive: showPropertyInspector,
                    badge: viewModel.selectedElementId != nil ? "1" : nil
                ) {
                    withAnimation(MotionCurves.quick) {
                        showPropertyInspector.toggle()
                        showElementPicker = false
                        showLayerSheet = false
                    }
                    HapticEngine.shared.selection()
                }

                // Templates
                GlassToolbarTab(icon: "square.grid.2x2", label: StudioStrings.templates, isActive: false) {
                    showTemplatePicker = true
                    HapticEngine.shared.selection()
                }

                // Export
                GlassToolbarTab(icon: "square.and.arrow.up", label: StudioStrings.export, isActive: false, isPrimary: true) {
                    checkPremiumAndExport()
                    HapticEngine.shared.impact(.medium)
                }
            }
            .padding(.horizontal, StudioSpacing.sm)
            .padding(.vertical, StudioSpacing.sm)
            .background(
                // Floating glass capsule
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(colorScheme == .dark ? 0.15 : 0.6),
                                        Color.white.opacity(colorScheme == .dark ? 0.05 : 0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: -4)
            )
            .padding(.horizontal, StudioSpacing.md)
            .padding(.bottom, StudioSpacing.sm)
        }
    }

    private var quickActionBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: StudioSpacing.sm) {
                // Zoom controls (clamped 50%-200%)
                GlassQuickActionChip(icon: "minus.magnifyingglass") {
                    withAnimation(MotionCurves.quick) {
                        canvasScale = max(0.5, canvasScale - 0.25)
                    }
                    HapticEngine.shared.selection()
                }

                Text("\(Int(canvasScale * 100))%")
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaTertiaryText)
                    .frame(width: 50)

                GlassQuickActionChip(icon: "plus.magnifyingglass") {
                    withAnimation(MotionCurves.quick) {
                        // Clamp to 200% max
                        canvasScale = min(2.0, canvasScale + 0.25)
                    }
                    HapticEngine.shared.selection()
                }

                Divider()
                    .frame(height: 24)
                    .background(Color.nuviaTertiaryText.opacity(0.3))

                // Fit to screen
                GlassQuickActionChip(icon: "arrow.up.left.and.arrow.down.right") {
                    withAnimation(MotionCurves.smooth) {
                        canvasScale = 1.0
                        canvasOffset = .zero
                    }
                    HapticEngine.shared.selection()
                }

                // Center selected
                if viewModel.selectedElementId != nil {
                    GlassQuickActionChip(icon: "arrow.up.and.down.and.arrow.left.and.right") {
                        if let id = viewModel.selectedElementId {
                            viewModel.centerElement(id: id)
                            HapticEngine.shared.impact(.medium)
                        }
                    }
                }
            }
            .padding(.horizontal, StudioSpacing.md)
            .padding(.vertical, StudioSpacing.sm)
        }
        .background(
            // Glass background
            RoundedRectangle(cornerRadius: StudioRadius.lg)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal, StudioSpacing.md)
    }

    // MARK: - Floating Panels

    @ViewBuilder
    private var floatingPanels: some View {
        // Element picker panel
        if showElementPicker {
            VStack {
                Spacer()
                ElementPickerPanel(
                    selectedTab: $selectedPickerTab,
                    viewModel: viewModel,
                    onAddElement: { element in
                        viewModel.addElement(element)
                        HapticEngine.shared.notify(.success)
                    },
                    onPremiumRequired: {
                        showPaywall = true
                    },
                    onClose: {
                        withAnimation(MotionCurves.snappy) {
                            showElementPicker = false
                        }
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .zIndex(100)
        }

        // Layer sheet
        if showLayerSheet {
            VStack {
                Spacer()
                LayerSheet(viewModel: viewModel, isPresented: $showLayerSheet)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .zIndex(100)
        }

        // Property inspector
        if showPropertyInspector {
            VStack {
                Spacer()
                PropertyInspector(viewModel: viewModel, isPresented: $showPropertyInspector)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .zIndex(100)
        }
    }

    // MARK: - Setup & Actions

    private func setupInitialCanvas() {
        guard let project = currentProject else { return }

        // Add default elements based on project
        let nameElement = StudioElement.text(
            id: UUID(),
            content: "\(project.partnerName1)\n&\n\(project.partnerName2)",
            color: HexColor(hex: "2C2C2C"),
            style: StudioTextStyle(
                fontFamily: DSTypography.FontFamily.serifBold,
                fontSize: 36,
                fontWeight: .bold,
                letterSpacing: 0,
                lineHeight: 1.3,
                alignment: .center
            ),
            transform: StudioTransform(offset: CGSize(width: 0, height: -60), zIndex: 2)
        )

        let dateElement = StudioElement.text(
            id: UUID(),
            content: project.weddingDate.formatted(date: .complete, time: .omitted),
            color: HexColor(hex: "6B6B6B"),
            style: StudioTextStyle(
                fontFamily: DSTypography.FontFamily.sansRegular,
                fontSize: 14,
                fontWeight: .regular,
                letterSpacing: 2,
                lineHeight: 1.4,
                alignment: .center
            ),
            transform: StudioTransform(offset: CGSize(width: 0, height: 60), zIndex: 1)
        )

        let heartElement = StudioElement.shape(
            id: UUID(),
            type: .heart,
            fillColor: HexColor(hex: "C9A9A6"),
            strokeColor: nil,
            strokeWidth: 0,
            transform: StudioTransform(offset: CGSize(width: 0, height: 0), scale: 0.8, zIndex: 0)
        )

        viewModel.addElement(heartElement)
        viewModel.addElement(nameElement)
        viewModel.addElement(dateElement)
    }

    private func applyTemplate(_ template: StudioTemplate) {
        // Clear current elements and apply template
        viewModel.clearCanvas()

        // Apply template background
        if let bgColor = template.backgroundColor {
            viewModel.setBackgroundColor(bgColor)
        }

        // Add template elements
        for element in template.elements {
            viewModel.addElement(element)
        }

        HapticEngine.shared.notify(.success)
    }

    private func checkPremiumAndExport() {
        if viewModel.hasPremiumContent && !appState.isPremium {
            showPaywall = true
        } else {
            showExportOptions = true
        }
    }
}

// MARK: - Toolbar Components

struct ToolbarIconButton: View {
    let icon: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isEnabled ? .nuviaPrimaryText : .nuviaTertiaryText)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.nuviaTertiaryBackground)
                )
        }
        .disabled(!isEnabled)
    }
}

struct ToolbarTab: View {
    let icon: String
    let label: String
    let isActive: Bool
    var badge: String? = nil
    var isPrimary: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(iconColor)

                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 14, height: 14)
                            .background(Color.nuviaChampagne)
                            .clipShape(Circle())
                            .offset(x: 6, y: -6)
                    }
                }

                Text(label)
                    .font(DSTypography.label(.small))
                    .foregroundColor(labelColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, StudioSpacing.xs)
        }
    }

    private var iconColor: Color {
        if isPrimary {
            return .nuviaChampagne
        }
        return isActive ? .nuviaChampagne : .nuviaPrimaryText
    }

    private var labelColor: Color {
        if isPrimary {
            return .nuviaChampagne
        }
        return isActive ? .nuviaChampagne : .nuviaSecondaryText
    }
}

// MARK: - Glass Toolbar Components

struct GlassToolbarTab: View {
    let icon: String
    let label: String
    let isActive: Bool
    var badge: String? = nil
    var isPrimary: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: isActive ? .semibold : .medium))
                        .foregroundStyle(isActive || isPrimary ? AnyShapeStyle(Color.nuviaGradient) : AnyShapeStyle(Color.nuviaPrimaryText))
                        .scaleEffect(isActive ? 1.1 : 1.0)
                        .animation(MotionCurves.bouncy, value: isActive)

                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 14, height: 14)
                            .background(Color.nuviaGoldFallback)
                            .clipShape(Circle())
                            .offset(x: 6, y: -6)
                    }
                }

                Text(label)
                    .font(NuviaTypography.caption())
                    .foregroundColor(isActive || isPrimary ? .nuviaGoldFallback : .nuviaSecondaryText)
                    .lineLimit(1)
            }
            .frame(width: 54, height: 44)
            .background(
                // Subtle highlight for active tab
                Capsule()
                    .fill(isActive ? Color.nuviaGoldFallback.opacity(0.12) : Color.clear)
                    .animation(MotionCurves.quick, value: isActive)
            )
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

struct GlassQuickActionChip: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.nuviaPrimaryText)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                        )
                )
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
    }
}

struct QuickActionChip: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.nuviaPrimaryText)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.nuviaSurface)
                )
                .elevation(.raised)
        }
    }
}

// MARK: - Element Picker Panel

enum ElementPickerTab: String, CaseIterable {
    case text = "Text"
    case shapes = "Shapes"
    case stickers = "Stickers"
    case images = "Images"
}

struct ElementPickerPanel: View {
    @Binding var selectedTab: ElementPickerTab
    @ObservedObject var viewModel: CanvasViewModel
    let onAddElement: (StudioElement) -> Void
    let onPremiumRequired: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Element")
                    .font(DSTypography.heading(.h4))
                    .foregroundColor(.nuviaPrimaryText)

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.nuviaTertiaryText)
                }
            }
            .padding(StudioSpacing.md)

            // Tab bar
            HStack(spacing: 0) {
                ForEach(ElementPickerTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(MotionCurves.snappy) {
                            selectedTab = tab
                        }
                    } label: {
                        Text(tab.rawValue)
                            .font(DSTypography.label(.regular))
                            .foregroundColor(selectedTab == tab ? .nuviaChampagne : .nuviaSecondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, StudioSpacing.sm)
                            .background(
                                Rectangle()
                                    .fill(selectedTab == tab ? Color.nuviaChampagne.opacity(0.1) : Color.clear)
                            )
                    }
                }
            }

            Divider()

            // Content
            ScrollView {
                switch selectedTab {
                case .text:
                    TextElementPicker(onAdd: onAddElement)
                case .shapes:
                    ShapeElementPicker(onAdd: onAddElement)
                case .stickers:
                    StickerElementPicker(onAdd: onAddElement, onPremiumRequired: onPremiumRequired)
                case .images:
                    ImageElementPicker(onAdd: onAddElement)
                }
            }
            .frame(height: 250)
        }
        .background(Color.nuviaSurface)
        .clipShape(RoundedRectangle(cornerRadius: StudioRadius.xl, style: .continuous))
        .elevation(.overlay)
        .padding(.horizontal, StudioSpacing.md)
        .padding(.bottom, StudioSpacing.lg)
    }
}

// MARK: - Element Pickers

struct TextElementPicker: View {
    let onAdd: (StudioElement) -> Void

    private let presets: [(label: String, fontSize: CGFloat, weight: StudioFontWeight)] = [
        ("Heading", 32, .bold),
        ("Subheading", 24, .semiBold),
        ("Body", 16, .regular),
        ("Caption", 12, .regular)
    ]

    var body: some View {
        VStack(spacing: StudioSpacing.md) {
            ForEach(presets, id: \.label) { preset in
                Button {
                    let element = StudioElement.text(
                        id: UUID(),
                        content: "Your text here",
                        color: HexColor(hex: "2C2C2C"),
                        style: StudioTextStyle(
                            fontFamily: preset.weight == .bold ? DSTypography.FontFamily.serifBold : DSTypography.FontFamily.sansRegular,
                            fontSize: preset.fontSize,
                            fontWeight: preset.weight,
                            letterSpacing: 0,
                            lineHeight: 1.3,
                            alignment: .center
                        ),
                        transform: StudioTransform()
                    )
                    onAdd(element)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(preset.label)
                                .font(DSTypography.body(.bold))
                                .foregroundColor(.nuviaPrimaryText)

                            Text("Tap to add \(preset.label.lowercased())")
                                .font(DSTypography.caption)
                                .foregroundColor(.nuviaTertiaryText)
                        }

                        Spacer()

                        Text("Aa")
                            .font(.system(size: preset.fontSize, weight: preset.weight.swiftUIWeight))
                            .foregroundColor(.nuviaChampagne)
                    }
                    .padding(StudioSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: StudioRadius.md, style: .continuous)
                            .fill(Color.nuviaTertiaryBackground)
                    )
                }
            }
        }
        .padding(StudioSpacing.md)
    }
}

struct ShapeElementPicker: View {
    let onAdd: (StudioElement) -> Void

    private let shapes: [(type: StudioShapeType, icon: String, label: String)] = [
        (.rectangle, "rectangle", "Rectangle"),
        (.circle, "circle", "Circle"),
        (.ellipse, "oval", "Ellipse"),
        (.line, "minus", "Line"),
        (.divider, "text.justify.leading", "Divider"),
        (.heart, "heart.fill", "Heart"),
        (.star, "star.fill", "Star"),
        (.diamond, "diamond.fill", "Diamond")
    ]

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: StudioSpacing.md) {
            ForEach(shapes, id: \.label) { shape in
                Button {
                    let element = StudioElement.shape(
                        id: UUID(),
                        type: shape.type,
                        fillColor: HexColor(hex: "D4AF37"),
                        strokeColor: nil,
                        strokeWidth: 0,
                        transform: StudioTransform()
                    )
                    onAdd(element)
                } label: {
                    VStack(spacing: StudioSpacing.xs) {
                        Image(systemName: shape.icon)
                            .font(.system(size: 28))
                            .foregroundColor(.nuviaChampagne)
                            .frame(width: 60, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: StudioRadius.md, style: .continuous)
                                    .fill(Color.nuviaTertiaryBackground)
                            )

                        Text(shape.label)
                            .font(DSTypography.label(.small))
                            .foregroundColor(.nuviaSecondaryText)
                    }
                }
            }
        }
        .padding(StudioSpacing.md)
    }
}

struct StickerElementPicker: View {
    let onAdd: (StudioElement) -> Void
    let onPremiumRequired: () -> Void

    private let stickers: [(icon: String, isPremium: Bool)] = [
        ("heart.fill", false),
        ("star.fill", false),
        ("leaf.fill", false),
        ("sparkles", false),
        ("crown.fill", true),
        ("diamond.fill", true),
        ("bird.fill", true),
        ("camera.macro", true),
        ("wand.and.stars", true),
        ("figure.2.arms.open", true),
        ("gift.fill", true),
        ("bell.fill", true)
    ]

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: StudioSpacing.md) {
            ForEach(stickers, id: \.icon) { sticker in
                Button {
                    if sticker.isPremium {
                        onPremiumRequired()
                    } else {
                        let element = StudioElement.sticker(
                            id: UUID(),
                            assetName: "system:\(sticker.icon)",
                            isPremiumSticker: sticker.isPremium,
                            transform: StudioTransform()
                        )
                        onAdd(element)
                    }
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: sticker.icon)
                            .font(.system(size: 28))
                            .foregroundColor(sticker.isPremium ? .nuviaTertiaryText : .nuviaChampagne)
                            .frame(width: 60, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: StudioRadius.md, style: .continuous)
                                    .fill(Color.nuviaTertiaryBackground)
                            )

                        if sticker.isPremium {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.nuviaChampagne)
                                .clipShape(Circle())
                                .offset(x: 4, y: -4)
                        }
                    }
                }
            }
        }
        .padding(StudioSpacing.md)
    }
}

struct ImageElementPicker: View {
    let onAdd: (StudioElement) -> Void

    var body: some View {
        VStack(spacing: StudioSpacing.md) {
            // Photo library button
            Button {
                // Open photo picker
                HapticEngine.shared.impact(.medium)
            } label: {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 24))
                        .foregroundColor(.nuviaChampagne)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Choose from Library")
                            .font(DSTypography.body(.bold))
                            .foregroundColor(.nuviaPrimaryText)

                        Text("Select a photo from your device")
                            .font(DSTypography.caption)
                            .foregroundColor(.nuviaTertiaryText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.nuviaTertiaryText)
                }
                .padding(StudioSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: StudioRadius.md, style: .continuous)
                        .fill(Color.nuviaTertiaryBackground)
                )
            }

            // Camera button
            Button {
                // Open camera
                HapticEngine.shared.impact(.medium)
            } label: {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.nuviaChampagne)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Take a Photo")
                            .font(DSTypography.body(.bold))
                            .foregroundColor(.nuviaPrimaryText)

                        Text("Capture a new image")
                            .font(DSTypography.caption)
                            .foregroundColor(.nuviaTertiaryText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.nuviaTertiaryText)
                }
                .padding(StudioSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: StudioRadius.md, style: .continuous)
                        .fill(Color.nuviaTertiaryBackground)
                )
            }
        }
        .padding(StudioSpacing.md)
    }
}

// MARK: - Studio Template

struct StudioTemplate {
    let name: String
    let backgroundColor: HexColor?
    let elements: [StudioElement]
    let isPremium: Bool
}

struct StudioTemplatePicker: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (StudioTemplate) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Coming Soon")
                    .font(DSTypography.body(.regular))
                    .foregroundColor(.nuviaSecondaryText)
                    .padding()
            }
            .background(Color.nuviaBackground)
            .navigationTitle("Templates")
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

// MARK: - Export Options Sheet

struct ExportOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CanvasViewModel
    @State private var isExporting = false
    @State private var selectedFormat: CanvasRenderer.ExportFormat = .png
    @State private var selectedResolution: CanvasRenderer.ExportResolution = .high
    
    // Helper to check format equality
    private func isFormat(_ format: CanvasRenderer.ExportFormat) -> Bool {
        switch (selectedFormat, format) {
        case (.png, .png), (.pdf, .pdf):
            return true
        case (.jpeg, .jpeg):
            return true
        default:
            return false
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: StudioSpacing.lg) {
                // Preview
                ZStack {
                    Color.nuviaTertiaryBackground

                    if let preview = viewModel.previewImage {
                        Image(uiImage: preview)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: StudioRadius.md))
                            .elevation(.raised)
                            .padding()
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: StudioRadius.lg))

                // Format options
                VStack(alignment: .leading, spacing: StudioSpacing.sm) {
                    Text("Format")
                        .font(DSTypography.label(.large))
                        .foregroundColor(.nuviaSecondaryText)

                    HStack(spacing: StudioSpacing.sm) {
                        ExportFormatButton(format: .png, isSelected: isFormat(.png)) {
                            selectedFormat = .png
                        }
                        ExportFormatButton(format: .jpeg(quality: 0.9), isSelected: isFormat(.jpeg(quality: 0.9))) {
                            selectedFormat = .jpeg(quality: 0.9)
                        }
                        ExportFormatButton(format: .pdf, isSelected: isFormat(.pdf)) {
                            selectedFormat = .pdf
                        }
                    }
                }

                // Resolution options
                VStack(alignment: .leading, spacing: StudioSpacing.sm) {
                    Text("Resolution")
                        .font(DSTypography.label(.large))
                        .foregroundColor(.nuviaSecondaryText)

                    HStack(spacing: StudioSpacing.sm) {
                        ResolutionButton(resolution: .standard, isSelected: selectedResolution == .standard) {
                            selectedResolution = .standard
                        }
                        ResolutionButton(resolution: .high, isSelected: selectedResolution == .high) {
                            selectedResolution = .high
                        }
                        ResolutionButton(resolution: .print, isSelected: selectedResolution == .print) {
                            selectedResolution = .print
                        }
                    }
                }

                Spacer()

                // Export button
                Button {
                    _Concurrency.Task {
                        isExporting = true
                        await exportInvitation()
                        isExporting = false
                    }
                } label: {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text(isExporting ? "Exporting..." : "Export & Share")
                    }
                    .font(DSTypography.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, StudioSpacing.md)
                    .background(
                        LinearGradient(
                            colors: [Color.nuviaChampagne, Color.nuviaRoseGold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: StudioRadius.lg))
                }
                .disabled(isExporting)
            }
            .padding(StudioSpacing.lg)
            .background(Color.nuviaBackground)
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.nuviaSecondaryText)
                }
            }
        }
    }

    private func exportInvitation() async {
        let options = CanvasRenderer.ExportOptions(
            format: selectedFormat,
            resolution: selectedResolution,
            includeBackground: true,
            trimWhitespace: false
        )

        await CanvasShareService.share(state: viewModel.state, options: options)
        dismiss()
    }
}

struct ExportFormatButton: View {
    let format: CanvasRenderer.ExportFormat
    let isSelected: Bool
    let action: () -> Void

    private var label: String {
        switch format {
        case .png: return "PNG"
        case .jpeg: return "JPEG"
        case .pdf: return "PDF"
        }
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(DSTypography.label(.regular))
                .foregroundColor(isSelected ? .white : .nuviaPrimaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, StudioSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: StudioRadius.sm)
                        .fill(isSelected ? Color.nuviaChampagne : Color.nuviaTertiaryBackground)
                )
        }
    }
}

struct ResolutionButton: View {
    let resolution: CanvasRenderer.ExportResolution
    let isSelected: Bool
    let action: () -> Void

    private var label: String {
        switch resolution {
        case .standard: return "1x"
        case .high: return "2x"
        case .print: return "Print"
        case .custom: return "Custom"
        }
    }

    private var subtitle: String {
        switch resolution {
        case .standard: return "Standard"
        case .high: return "High"
        case .print: return "300 DPI"
        case .custom: return ""
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(label)
                    .font(DSTypography.body(.bold))
                Text(subtitle)
                    .font(DSTypography.label(.small))
            }
            .foregroundColor(isSelected ? .white : .nuviaPrimaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, StudioSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: StudioRadius.sm)
                    .fill(isSelected ? Color.nuviaChampagne : Color.nuviaTertiaryBackground)
            )
        }
    }
}

// MARK: - ViewModel Extensions

extension CanvasViewModel {
    var previewImage: UIImage? {
        // Generate a preview image synchronously for display
        let view = CanvasRenderView(state: state, includeBackground: true)
        let renderer = ImageRenderer(content: view.frame(width: canvasSize.width, height: canvasSize.height))
        renderer.scale = 1.0
        return renderer.uiImage
    }
}

// MARK: - Preview

#Preview {
    InvitationStudioView()
        .environmentObject(AppState())
        .modelContainer(for: WeddingProject.self, inMemory: true)
}
