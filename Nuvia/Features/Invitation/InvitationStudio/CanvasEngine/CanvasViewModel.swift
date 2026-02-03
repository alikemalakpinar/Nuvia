import SwiftUI
import Combine

// MARK: - Canvas ViewModel
// Manages canvas state with undo/redo support

@MainActor
public final class CanvasViewModel: ObservableObject {

    // MARK: - Published State
    @Published public private(set) var state: StudioCanvasState
    @Published public var selectedElementId: UUID?
    @Published public var isEditing: Bool = false
    @Published public var showPaywall: Bool = false

    // MARK: - Undo/Redo Stack
    private var undoStack: [StudioCanvasState] = []
    private var redoStack: [StudioCanvasState] = []
    private let maxUndoLevels = 50

    // MARK: - Gesture State
    @Published public var activeGesture: GestureType?
    @Published public var gestureStartTransform: StudioTransform?

    public enum GestureType {
        case drag, scale, rotate, combined
    }

    // Canvas size property
    public var canvasSize: CGSize {
        state.canvasSize
    }

    // Elements accessor
    public var elements: [StudioElement] {
        get { state.elements }
        set { state.elements = newValue }
    }

    // Sorted elements
    public var sortedElements: [StudioElement] {
        state.sortedElements
    }

    // Has premium content
    public var hasPremiumContent: Bool {
        state.hasPremiumContent
    }

    // MARK: - Init
    public init(initialState: StudioCanvasState = StudioCanvasState()) {
        self.state = initialState
    }

    public init(canvasSize: CGSize) {
        self.state = StudioCanvasState(canvasSize: canvasSize)
    }

    // Save to history
    func saveToHistory() {
        undoStack.append(state)
        if undoStack.count > maxUndoLevels {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
    }

    // MARK: - Element Management

    public func addElement(_ element: StudioElement) {
        saveToHistory()
        var newElement = element
        // Set zIndex to top
        var transform = newElement.transform
        transform.zIndex = (state.elements.map { $0.transform.zIndex }.max() ?? 0) + 1
        newElement.transform = transform
        state.elements.append(newElement)
        selectedElementId = newElement.id
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    public func removeElement(id: UUID) {
        saveToHistory()
        state.elements.removeAll { $0.id == id }
        if selectedElementId == id {
            selectedElementId = nil
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    public func duplicateElement(id: UUID) {
        guard let element = state.elements.first(where: { $0.id == id }) else { return }
        saveToHistory()

        var newElement = element
        var transform = newElement.transform
        transform.offset.width += 20
        transform.offset.height += 20
        transform.zIndex = (state.elements.map { $0.transform.zIndex }.max() ?? 0) + 1

        // Create new element with new ID
        switch element {
        case .text(_, let content, let color, let style, _):
            newElement = .text(id: UUID(), content: content, color: color, style: style, transform: transform)
        case .image(_, let data, let filter, _):
            newElement = .image(id: UUID(), imageData: data, filter: filter, transform: transform)
        case .shape(_, let type, let fill, let stroke, let width, _):
            newElement = .shape(id: UUID(), type: type, fillColor: fill, strokeColor: stroke, strokeWidth: width, transform: transform)
        case .sticker(_, let name, let premium, _):
            newElement = .sticker(id: UUID(), assetName: name, isPremiumSticker: premium, transform: transform)
        }

        state.elements.append(newElement)
        selectedElementId = newElement.id
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    public func updateElement(id: UUID, with updatedElement: StudioElement) {
        saveToHistory()
        if let index = state.elements.firstIndex(where: { $0.id == id }) {
            state.elements[index] = updatedElement
        }
    }

    public func selectElement(id: UUID?) {
        selectedElementId = id
        if id != nil {
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }

    public func deselectAll() {
        selectedElementId = nil
    }

    // MARK: - Transform Updates

    public func updateTransform(id: UUID, transform: StudioTransform) {
        if let index = state.elements.firstIndex(where: { $0.id == id }) {
            state.elements[index].transform = transform
        }
    }

    public func beginGesture(for id: UUID, type: GestureType) {
        if let element = state.elements.first(where: { $0.id == id }) {
            gestureStartTransform = element.transform
            activeGesture = type
        }
    }

    public func endGesture(for id: UUID) {
        if gestureStartTransform != nil {
            saveToHistory()
        }
        gestureStartTransform = nil
        activeGesture = nil
    }

    public func applyDrag(to id: UUID, translation: CGSize) {
        guard let startTransform = gestureStartTransform else { return }
        var newTransform = startTransform
        newTransform.offset.width = startTransform.offset.width + translation.width
        newTransform.offset.height = startTransform.offset.height + translation.height
        updateTransform(id: id, transform: newTransform)
    }

    public func applyScale(to id: UUID, scale: CGFloat) {
        guard let startTransform = gestureStartTransform else { return }
        var newTransform = startTransform
        newTransform.scale = max(0.1, min(5.0, startTransform.scale * scale))
        updateTransform(id: id, transform: newTransform)
    }

    public func applyRotation(to id: UUID, angle: Angle) {
        guard let startTransform = gestureStartTransform else { return }
        var newTransform = startTransform
        newTransform.rotation = startTransform.rotation + angle
        updateTransform(id: id, transform: newTransform)
    }

    public func applyCombinedGesture(to id: UUID, translation: CGSize, scale: CGFloat, rotation: Angle) {
        guard let startTransform = gestureStartTransform else { return }
        var newTransform = startTransform
        newTransform.offset.width = startTransform.offset.width + translation.width
        newTransform.offset.height = startTransform.offset.height + translation.height
        newTransform.scale = max(0.1, min(5.0, startTransform.scale * scale))
        newTransform.rotation = startTransform.rotation + rotation
        updateTransform(id: id, transform: newTransform)
    }

    // MARK: - Layer Ordering

    public func bringToFront(id: UUID) {
        saveToHistory()
        let maxZ = state.elements.map { $0.transform.zIndex }.max() ?? 0
        if let index = state.elements.firstIndex(where: { $0.id == id }) {
            var element = state.elements[index]
            var transform = element.transform
            transform.zIndex = maxZ + 1
            element.transform = transform
            state.elements[index] = element
        }
    }

    public func sendToBack(id: UUID) {
        saveToHistory()
        let minZ = state.elements.map { $0.transform.zIndex }.min() ?? 0
        if let index = state.elements.firstIndex(where: { $0.id == id }) {
            var element = state.elements[index]
            var transform = element.transform
            transform.zIndex = minZ - 1
            element.transform = transform
            state.elements[index] = element
        }
    }

    // MARK: - Background

    public func setBackgroundColor(_ color: HexColor) {
        saveToHistory()
        state.backgroundColor = color
    }

    public func setBackgroundImage(_ data: Data?) {
        saveToHistory()
        state.backgroundImageData = data
    }

    // MARK: - Undo/Redo

    public var canUndo: Bool { !undoStack.isEmpty }
    public var canRedo: Bool { !redoStack.isEmpty }

    public func undo() {
        guard let previousState = undoStack.popLast() else { return }
        redoStack.append(state)
        state = previousState
        selectedElementId = previousState.selectedElementId
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    public func redo() {
        guard let nextState = redoStack.popLast() else { return }
        undoStack.append(state)
        state = nextState
        selectedElementId = nextState.selectedElementId
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // MARK: - Premium Check

    public func checkPremiumAccess(completion: @escaping (Bool) -> Void) {
        if state.hasPremiumContent {
            // Check if user has premium
            // For now, show paywall
            showPaywall = true
            completion(false)
        } else {
            completion(true)
        }
    }

    // MARK: - Serialization

    public func exportState() -> Data? {
        try? JSONEncoder().encode(state)
    }

    public func importState(from data: Data) {
        if let newState = try? JSONDecoder().decode(StudioCanvasState.self, from: data) {
            saveToHistory()
            state = newState
        }
    }

    // MARK: - Templates

    func loadTemplate(_ template: InvitationTemplate, partnerNames: (String, String), date: Date) {
        saveToHistory()
        state = StudioCanvasState()

        // Add template-specific elements
        let nameText = "\(partnerNames.0)\n&\n\(partnerNames.1)"
        let dateText = date.formatted(date: .complete, time: .omitted)

        // Title
        addElement(.newText(
            content: "You're Invited",
            color: template.accentHexColor,
            style: StudioTextStyle(fontSize: 18, fontWeight: .medium, letterSpacing: 4),
            at: CGPoint(x: 187, y: 100)
        ))

        // Names
        addElement(.newText(
            content: nameText,
            color: .black,
            style: StudioTextStyle(fontSize: 36, fontWeight: .bold),
            at: CGPoint(x: 187, y: 250)
        ))

        // Date
        addElement(.newText(
            content: dateText,
            color: HexColor(hex: "666666"),
            style: StudioTextStyle(fontSize: 14, fontWeight: .regular, letterSpacing: 1),
            at: CGPoint(x: 187, y: 400)
        ))

        // Clear selection
        selectedElementId = nil
    }
}

// MARK: - Invitation Template Extension
extension InvitationTemplate {
    var accentHexColor: HexColor {
        switch self {
        case .minimal: return HexColor(hex: "666666")
        case .floral: return HexColor(hex: "9CAF88") // sage
        case .modern: return HexColor(hex: "7BA3B8") // dusty blue
        case .luxury: return HexColor(hex: "D4AF37") // champagne
        case .classic: return HexColor(hex: "C4967A") // terracotta
        case .romantic: return HexColor(hex: "D4A5A5") // rose dust
        }
    }
}
