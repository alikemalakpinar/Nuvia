import SwiftUI

// MARK: - Scroll Observer System
// PreferenceKey-based scroll tracking for premium animations

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - View Visibility Preference Key
struct ViewVisibilityPreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]

    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// MARK: - Scroll Offset Reader
struct ScrollOffsetReader: View {
    let coordinateSpace: String

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: -proxy.frame(in: .named(coordinateSpace)).minY
                )
        }
        .frame(height: 0)
    }
}

// MARK: - Visibility Tracker
struct VisibilityTracker: ViewModifier {
    let id: String
    let coordinateSpace: String

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: ViewVisibilityPreferenceKey.self,
                            value: [id: proxy.frame(in: .named(coordinateSpace))]
                        )
                }
            )
    }
}

extension View {
    func trackVisibility(id: String, in coordinateSpace: String) -> some View {
        modifier(VisibilityTracker(id: id, coordinateSpace: coordinateSpace))
    }
}

// MARK: - Scroll State
@Observable
class ScrollState {
    var offset: CGFloat = 0
    var velocity: CGFloat = 0
    var isScrolling: Bool = false
    var visibleViews: Set<String> = []

    private var lastOffset: CGFloat = 0
    private var lastUpdateTime: Date = Date()

    func update(offset: CGFloat) {
        let now = Date()
        let timeDelta = now.timeIntervalSince(lastUpdateTime)

        if timeDelta > 0 {
            velocity = (offset - lastOffset) / CGFloat(timeDelta)
        }

        self.offset = offset
        self.lastOffset = offset
        self.lastUpdateTime = now
        self.isScrolling = abs(velocity) > 10
    }

    func updateVisibility(frames: [String: CGRect], containerHeight: CGFloat) {
        var visible: Set<String> = []

        for (id, frame) in frames {
            // Check if view is within visible bounds (with some margin)
            let isVisible = frame.maxY > -50 && frame.minY < containerHeight + 50
            if isVisible {
                visible.insert(id)
            }
        }

        if visible != visibleViews {
            visibleViews = visible
        }
    }

    func visibilityProgress(for frame: CGRect, containerHeight: CGFloat) -> CGFloat {
        // 0 = not visible, 1 = fully visible in center
        let viewCenter = frame.midY
        let containerCenter = containerHeight / 2
        let distance = abs(viewCenter - containerCenter)
        let maxDistance = containerHeight / 2 + frame.height / 2

        return max(0, 1 - (distance / maxDistance))
    }
}

// MARK: - Observable Scroll View
struct ObservableScrollView<Content: View>: View {
    @Binding var scrollState: ScrollState
    let showsIndicators: Bool
    let coordinateSpace: String
    @ViewBuilder let content: () -> Content

    init(
        scrollState: Binding<ScrollState>,
        showsIndicators: Bool = false,
        coordinateSpace: String = "scroll",
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._scrollState = scrollState
        self.showsIndicators = showsIndicators
        self.coordinateSpace = coordinateSpace
        self.content = content
    }

    var body: some View {
        GeometryReader { outerProxy in
            ScrollView(showsIndicators: showsIndicators) {
                VStack(spacing: 0) {
                    ScrollOffsetReader(coordinateSpace: coordinateSpace)
                    content()
                }
            }
            .coordinateSpace(name: coordinateSpace)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                scrollState.update(offset: offset)
            }
            .onPreferenceChange(ViewVisibilityPreferenceKey.self) { frames in
                scrollState.updateVisibility(frames: frames, containerHeight: outerProxy.size.height)
            }
        }
    }
}

// MARK: - Scroll-Driven Animation Modifier
struct ScrollDrivenAnimation: ViewModifier {
    let scrollState: ScrollState
    let id: String
    let enterFrom: EntranceAnimation
    let threshold: CGFloat

    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : enterFrom.offset.height)
            .scaleEffect(hasAppeared ? 1 : enterFrom.initialScale)
            .animation(enterFrom.animation, value: hasAppeared)
            .onChange(of: scrollState.visibleViews) { _, visibleViews in
                if visibleViews.contains(id) && !hasAppeared {
                    hasAppeared = true
                }
            }
    }
}

extension View {
    func animateOnScroll(
        scrollState: ScrollState,
        id: String,
        animation: EntranceAnimation = .slideUp,
        threshold: CGFloat = 0.3
    ) -> some View {
        self
            .trackVisibility(id: id, in: "scroll")
            .modifier(ScrollDrivenAnimation(
                scrollState: scrollState,
                id: id,
                enterFrom: animation,
                threshold: threshold
            ))
    }
}

// MARK: - Sticky Header
struct StickyHeader<Content: View>: View {
    let minHeight: CGFloat
    let maxHeight: CGFloat
    let scrollOffset: CGFloat
    @ViewBuilder let content: (CGFloat) -> Content

    private var progress: CGFloat {
        let range = maxHeight - minHeight
        return max(0, min(1, scrollOffset / range))
    }

    private var currentHeight: CGFloat {
        max(minHeight, maxHeight - scrollOffset)
    }

    var body: some View {
        GeometryReader { proxy in
            content(progress)
                .frame(width: proxy.size.width, height: currentHeight)
                .clipped()
        }
        .frame(height: currentHeight)
    }
}

// MARK: - Sticky Section Header
struct StickySectionHeader<Content: View>: View {
    let scrollOffset: CGFloat
    let sectionOffset: CGFloat
    let headerHeight: CGFloat
    @ViewBuilder let content: () -> Content

    private var isPinned: Bool {
        scrollOffset >= sectionOffset
    }

    var body: some View {
        content()
            .frame(height: headerHeight)
            .background(
                Group {
                    if isPinned {
                        GlassmorphicBackground()
                    } else {
                        Color.clear
                    }
                }
            )
            .zIndex(isPinned ? 100 : 0)
    }
}

// MARK: - Glassmorphic Background
struct GlassmorphicBackground: View {
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                Rectangle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
    }
}

// MARK: - Scroll Progress Indicator
struct ScrollProgressIndicator: View {
    let progress: CGFloat
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(color)
                .frame(width: proxy.size.width * progress)
                .animation(.linear(duration: 0.1), value: progress)
        }
        .frame(height: 3)
    }
}
