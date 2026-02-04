import SwiftUI

// MARK: - Magazine Layout View
// Dynamic AnyLayout-based layout system for editorial dashboard
// Switches between grid and list based on content and preference

struct MagazineLayoutView<Content: View, Item: Identifiable>: View {
    let items: [Item]
    let layout: MagazineLayout
    @ViewBuilder let content: (Item) -> Content

    @State private var currentLayout: MagazineLayout

    init(
        items: [Item],
        layout: MagazineLayout = .grid,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.layout = layout
        self._currentLayout = State(initialValue: layout)
        self.content = content
    }

    var body: some View {
        AnyLayout(currentLayoutType) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                content(item)
                    .cardEntrance(delay: Double(index) * 0.05)
            }
        }
        .animation(DesignTokens.Animation.smooth, value: currentLayout)
    }

    private var currentLayoutType: AnyLayout {
        switch currentLayout {
        case .grid:
            return AnyLayout(LazyVGridLayout(columns: [
                GridItem(.flexible(), spacing: DesignTokens.Spacing.md),
                GridItem(.flexible(), spacing: DesignTokens.Spacing.md)
            ], spacing: DesignTokens.Spacing.md))
        case .list:
            return AnyLayout(VStackLayout(spacing: DesignTokens.Spacing.md))
        case .masonry:
            return AnyLayout(MasonryLayout(columns: 2, spacing: DesignTokens.Spacing.md))
        case .featured:
            return AnyLayout(FeaturedLayout(spacing: DesignTokens.Spacing.md))
        }
    }

    // Public method to change layout
    func setLayout(_ newLayout: MagazineLayout) {
        withAnimation(DesignTokens.Animation.smooth) {
            currentLayout = newLayout
        }
    }
}

// MARK: - Magazine Layout Types

enum MagazineLayout: String, CaseIterable {
    case grid = "Grid"
    case list = "List"
    case masonry = "Masonry"
    case featured = "Featured"

    var icon: String {
        switch self {
        case .grid:     return "square.grid.2x2"
        case .list:     return "list.bullet"
        case .masonry:  return "rectangle.3.group"
        case .featured: return "rectangle.split.1x2"
        }
    }
}

// MARK: - Layout Switcher

struct LayoutSwitcher: View {
    @Binding var selectedLayout: MagazineLayout

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            ForEach(MagazineLayout.allCases, id: \.self) { layout in
                Button {
                    withAnimation(DesignTokens.Animation.snappy) {
                        selectedLayout = layout
                    }
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    Image(systemName: layout.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedLayout == layout ? .nuviaChampagne : .nuviaTertiaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(selectedLayout == layout ? Color.nuviaChampagne.opacity(0.15) : Color.clear)
                        )
                }
            }
        }
        .padding(DesignTokens.Spacing.xxs)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.nuviaTertiaryBackground)
        )
    }
}

// MARK: - Custom Layouts

/// LazyVGrid wrapper for AnyLayout compatibility
struct LazyVGridLayout: Layout {
    let columns: [GridItem]
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        let columnCount = columns.count
        let columnWidth = (width - spacing * CGFloat(columnCount - 1)) / CGFloat(columnCount)

        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0
        var currentColumn = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.init(width: columnWidth, height: nil))

            if currentColumn == 0 {
                rowHeight = size.height
            } else {
                rowHeight = max(rowHeight, size.height)
            }

            currentColumn += 1

            if currentColumn >= columnCount {
                totalHeight += rowHeight + spacing
                currentColumn = 0
                rowHeight = 0
            }
        }

        if currentColumn > 0 {
            totalHeight += rowHeight
        } else if totalHeight > 0 {
            totalHeight -= spacing
        }

        return CGSize(width: width, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let columnCount = columns.count
        let columnWidth = (bounds.width - spacing * CGFloat(columnCount - 1)) / CGFloat(columnCount)

        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        var currentColumn = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.init(width: columnWidth, height: nil))

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: .init(width: columnWidth, height: size.height)
            )

            rowHeight = max(rowHeight, size.height)
            currentColumn += 1
            x += columnWidth + spacing

            if currentColumn >= columnCount {
                x = bounds.minX
                y += rowHeight + spacing
                currentColumn = 0
                rowHeight = 0
            }
        }
    }
}

/// Masonry layout for Pinterest-style display
struct MasonryLayout: Layout {
    let columns: Int
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        let columnWidth = (width - spacing * CGFloat(columns - 1)) / CGFloat(columns)

        var columnHeights = Array(repeating: CGFloat(0), count: columns)

        for subview in subviews {
            let shortestColumn = columnHeights.enumerated().min(by: { $0.element < $1.element })!.offset
            let size = subview.sizeThatFits(.init(width: columnWidth, height: nil))
            columnHeights[shortestColumn] += size.height + spacing
        }

        let maxHeight = columnHeights.max() ?? 0
        return CGSize(width: width, height: max(0, maxHeight - spacing))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let columnWidth = (bounds.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        var columnHeights = Array(repeating: CGFloat(0), count: columns)
        var columnXPositions = (0..<columns).map { CGFloat($0) * (columnWidth + spacing) + bounds.minX }

        for subview in subviews {
            let shortestColumnIndex = columnHeights.enumerated().min(by: { $0.element < $1.element })!.offset
            let size = subview.sizeThatFits(.init(width: columnWidth, height: nil))

            subview.place(
                at: CGPoint(
                    x: columnXPositions[shortestColumnIndex],
                    y: bounds.minY + columnHeights[shortestColumnIndex]
                ),
                proposal: .init(width: columnWidth, height: size.height)
            )

            columnHeights[shortestColumnIndex] += size.height + spacing
        }
    }
}

/// Featured layout with one large item and smaller items below
struct FeaturedLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let width = proposal.width ?? .infinity

        // Featured item takes full width
        let featuredHeight = subviews[0].sizeThatFits(.init(width: width, height: nil)).height

        // Remaining items in 2-column grid
        let columnWidth = (width - spacing) / 2
        var gridHeight: CGFloat = 0
        var rowHeight: CGFloat = 0
        var currentColumn = 0

        for subview in subviews.dropFirst() {
            let size = subview.sizeThatFits(.init(width: columnWidth, height: nil))
            rowHeight = max(rowHeight, size.height)
            currentColumn += 1

            if currentColumn >= 2 {
                gridHeight += rowHeight + spacing
                currentColumn = 0
                rowHeight = 0
            }
        }

        if currentColumn > 0 {
            gridHeight += rowHeight
        } else if gridHeight > 0 {
            gridHeight -= spacing
        }

        let totalHeight = featuredHeight + spacing + gridHeight
        return CGSize(width: width, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }

        let width = bounds.width
        var y = bounds.minY

        // Place featured item
        let featuredSize = subviews[0].sizeThatFits(.init(width: width, height: nil))
        subviews[0].place(
            at: CGPoint(x: bounds.minX, y: y),
            proposal: .init(width: width, height: featuredSize.height)
        )
        y += featuredSize.height + spacing

        // Place remaining items in grid
        let columnWidth = (width - spacing) / 2
        var x = bounds.minX
        var rowHeight: CGFloat = 0
        var currentColumn = 0

        for subview in subviews.dropFirst() {
            let size = subview.sizeThatFits(.init(width: columnWidth, height: nil))

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: .init(width: columnWidth, height: size.height)
            )

            rowHeight = max(rowHeight, size.height)
            x += columnWidth + spacing
            currentColumn += 1

            if currentColumn >= 2 {
                x = bounds.minX
                y += rowHeight + spacing
                currentColumn = 0
                rowHeight = 0
            }
        }
    }
}

// MARK: - Magazine Section View

struct MagazineSectionView<Item: Identifiable, Content: View>: View {
    let title: String
    let subtitle: String?
    let items: [Item]
    @Binding var layout: MagazineLayout
    @ViewBuilder let content: (Item) -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            // Section header
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    if let subtitle = subtitle {
                        Text(subtitle.uppercased())
                            .font(NuviaTypography.overline())
                            .tracking(1.5)
                            .foregroundColor(.nuviaTertiaryText)
                    }

                    Text(title)
                        .font(NuviaTypography.title1())
                        .foregroundColor(.nuviaPrimaryText)
                }

                Spacer()

                LayoutSwitcher(selectedLayout: $layout)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)

            // Content with layout
            MagazineLayoutView(items: items, layout: layout, content: content)
                .padding(.horizontal, DesignTokens.Spacing.lg)
        }
    }
}

// MARK: - Editorial Card Variants

struct EditorialFeatureCard: View {
    let title: String
    let subtitle: String
    let image: Image?
    let accentColor: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Image area
                ZStack(alignment: .bottomLeading) {
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipped()
                    } else {
                        // Gradient placeholder
                        LinearGradient(
                            colors: [accentColor.opacity(0.6), accentColor.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 180)
                    }

                    // Overlay gradient for text readability
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .frame(height: 180)

                // Content
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(title)
                        .font(NuviaTypography.title2())
                        .foregroundColor(.nuviaPrimaryText)
                        .lineLimit(2)

                    Text(subtitle)
                        .font(NuviaTypography.footnote())
                        .foregroundColor(.nuviaSecondaryText)
                        .lineLimit(2)
                }
                .padding(DesignTokens.Spacing.md)
            }
            .background(Color.nuviaSurface)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))
            .elevation(DesignTokens.Elevation.raised)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(DesignTokens.Animation.snappy, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            isPressed = pressing
            if pressing {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }, perform: {})
    }
}

struct EditorialCompactCard: View {
    let title: String
    let subtitle: String?
    let icon: String
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.md) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(accentColor)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                            .fill(accentColor.opacity(0.12))
                    )

                // Content
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    Text(title)
                        .font(NuviaTypography.bodyBold())
                        .foregroundColor(.nuviaPrimaryText)
                        .lineLimit(1)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaTertiaryText)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.nuviaTertiaryText)
            }
            .padding(DesignTokens.Spacing.md)
            .background(Color.nuviaSurface)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
            .elevation(DesignTokens.Elevation.raised)
        }
        .buttonStyle(PlainButtonStyle())
        .pressable()
    }
}

// MARK: - Progress Ring Card

struct ProgressRingCard: View {
    let title: String
    let progress: Double
    let total: Int
    let completed: Int
    let accentColor: Color

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            // Ring
            ZStack {
                // Background track
                Circle()
                    .stroke(accentColor.opacity(0.15), lineWidth: 8)

                // Progress
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        accentColor,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                // Center text
                VStack(spacing: 2) {
                    Text("\(Int(progress * 100))%")
                        .font(NuviaTypography.title2())
                        .foregroundColor(.nuviaPrimaryText)

                    Text("\(completed)/\(total)")
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaTertiaryText)
                }
            }
            .frame(width: 100, height: 100)

            Text(title)
                .font(NuviaTypography.bodyBold())
                .foregroundColor(.nuviaPrimaryText)
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.nuviaSurface)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))
        .elevation(DesignTokens.Elevation.raised)
    }
}

// MARK: - Preview

private struct MagazinePreviewItem: Identifiable {
    let id = UUID()
    let title: String
    let color: Color
}

#Preview("Magazine Layout") {
    let items = [
        MagazinePreviewItem(title: "Venue", color: .nuviaWisteria),
        MagazinePreviewItem(title: "Catering", color: .nuviaSage),
        MagazinePreviewItem(title: "Photography", color: .nuviaDustyBlue),
        MagazinePreviewItem(title: "Flowers", color: .nuviaRoseDust),
        MagazinePreviewItem(title: "Music", color: .nuviaChampagne),
        MagazinePreviewItem(title: "Decorations", color: .nuviaTerracotta)
    ]

    return ScrollView {
        VStack(spacing: DesignTokens.Spacing.xl) {
            MagazineSectionView(
                title: "Your Tasks",
                subtitle: "Wedding Planning",
                items: items,
                layout: .constant(.grid)
            ) { item in
                EditorialFeatureCard(
                    title: item.title,
                    subtitle: "3 items remaining",
                    image: nil,
                    accentColor: item.color
                ) {}
            }
        }
        .padding(.vertical)
    }
    .background(Color.nuviaBackground)
}
