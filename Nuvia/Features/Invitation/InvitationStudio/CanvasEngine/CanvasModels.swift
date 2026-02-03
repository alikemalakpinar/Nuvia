import SwiftUI
import Foundation

// MARK: - Studio Canvas Models
// Layer-based rendering engine for the Invitation Studio
// All types prefixed with "Studio" to avoid conflicts with legacy InvitationEditorView

public struct StudioTransform: Codable, Equatable {
    public var offset: CGSize
    public var rotation: Angle
    public var scale: CGFloat
    public var zIndex: Int

    public init(
        offset: CGSize = .zero,
        rotation: Angle = .zero,
        scale: CGFloat = 1.0,
        zIndex: Int = 0
    ) {
        self.offset = offset
        self.rotation = rotation
        self.scale = scale
        self.zIndex = zIndex
    }

    // Codable conformance for Angle
    enum CodingKeys: String, CodingKey {
        case offsetWidth, offsetHeight, rotationDegrees, scale, zIndex
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let width = try container.decode(CGFloat.self, forKey: .offsetWidth)
        let height = try container.decode(CGFloat.self, forKey: .offsetHeight)
        offset = CGSize(width: width, height: height)
        let degrees = try container.decode(Double.self, forKey: .rotationDegrees)
        rotation = .degrees(degrees)
        scale = try container.decode(CGFloat.self, forKey: .scale)
        zIndex = try container.decode(Int.self, forKey: .zIndex)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(offset.width, forKey: .offsetWidth)
        try container.encode(offset.height, forKey: .offsetHeight)
        try container.encode(rotation.degrees, forKey: .rotationDegrees)
        try container.encode(scale, forKey: .scale)
        try container.encode(zIndex, forKey: .zIndex)
    }
}

// MARK: - Hex Color (Codable)
public struct HexColor: Codable, Equatable, Hashable {
    public let hex: String
    public let opacity: Double

    public init(hex: String, opacity: Double = 1.0) {
        self.hex = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        self.opacity = opacity
    }

    public var color: Color {
        Color(hex: hex).opacity(opacity)
    }

    public static let white = HexColor(hex: "FFFFFF")
    public static let black = HexColor(hex: "000000")
    public static let champagne = HexColor(hex: "D4AF37")
    public static let roseDust = HexColor(hex: "D4A5A5")
    public static let sage = HexColor(hex: "9CAF88")
}

// MARK: - Studio Shape Type
public enum StudioShapeType: String, Codable, CaseIterable {
    case rectangle
    case circle
    case ellipse
    case line
    case divider
    case heart
    case star
    case diamond

    public var systemImage: String {
        switch self {
        case .rectangle: return "rectangle"
        case .circle: return "circle"
        case .ellipse: return "oval"
        case .line: return "line.diagonal"
        case .divider: return "minus"
        case .heart: return "heart"
        case .star: return "star"
        case .diamond: return "diamond"
        }
    }
}

// MARK: - Studio Photo Filter
public enum StudioPhotoFilter: String, Codable, CaseIterable {
    case none
    case sepia
    case mono
    case chrome
    case fade
    case instant
    case process
    case transfer
    case vignette

    public var displayName: String {
        switch self {
        case .none: return "Original"
        case .sepia: return "Sepia"
        case .mono: return "Mono"
        case .chrome: return "Chrome"
        case .fade: return "Fade"
        case .instant: return "Instant"
        case .process: return "Process"
        case .transfer: return "Transfer"
        case .vignette: return "Vignette"
        }
    }

    public var isPremiumFilter: Bool {
        switch self {
        case .none, .sepia, .mono: return false
        default: return true
        }
    }
}

// MARK: - Studio Text Style
public struct StudioTextStyle: Codable, Equatable {
    public var fontFamily: String
    public var fontSize: CGFloat
    public var fontWeight: StudioFontWeight
    public var letterSpacing: CGFloat
    public var lineHeight: CGFloat
    public var alignment: StudioTextAlignment

    public init(
        fontFamily: String = "System",
        fontSize: CGFloat = 24,
        fontWeight: StudioFontWeight = .regular,
        letterSpacing: CGFloat = 0,
        lineHeight: CGFloat = 1.2,
        alignment: StudioTextAlignment = .center
    ) {
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.letterSpacing = letterSpacing
        self.lineHeight = lineHeight
        self.alignment = alignment
    }
}

public enum StudioFontWeight: String, Codable, CaseIterable {
    case thin, light, regular, medium, semiBold, bold, heavy, black

    public var swiftUIWeight: Font.Weight {
        switch self {
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semiBold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        }
    }
}

public enum StudioTextAlignment: String, Codable, CaseIterable {
    case leading, center, trailing

    public var swiftUIAlignment: TextAlignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

// MARK: - Studio Element
public enum StudioElement: Identifiable, Codable, Equatable {
    case text(id: UUID, content: String, color: HexColor, style: StudioTextStyle, transform: StudioTransform)
    case image(id: UUID, imageData: Data, filter: StudioPhotoFilter, transform: StudioTransform)
    case shape(id: UUID, type: StudioShapeType, fillColor: HexColor, strokeColor: HexColor?, strokeWidth: CGFloat, transform: StudioTransform)
    case sticker(id: UUID, assetName: String, isPremiumSticker: Bool, transform: StudioTransform)

    public var id: UUID {
        switch self {
        case .text(let id, _, _, _, _): return id
        case .image(let id, _, _, _): return id
        case .shape(let id, _, _, _, _, _): return id
        case .sticker(let id, _, _, _): return id
        }
    }

    public var transform: StudioTransform {
        get {
            switch self {
            case .text(_, _, _, _, let t): return t
            case .image(_, _, _, let t): return t
            case .shape(_, _, _, _, _, let t): return t
            case .sticker(_, _, _, let t): return t
            }
        }
        set {
            switch self {
            case .text(let id, let content, let color, let style, _):
                self = .text(id: id, content: content, color: color, style: style, transform: newValue)
            case .image(let id, let data, let filter, _):
                self = .image(id: id, imageData: data, filter: filter, transform: newValue)
            case .shape(let id, let type, let fill, let stroke, let width, _):
                self = .shape(id: id, type: type, fillColor: fill, strokeColor: stroke, strokeWidth: width, transform: newValue)
            case .sticker(let id, let name, let premium, _):
                self = .sticker(id: id, assetName: name, isPremiumSticker: premium, transform: newValue)
            }
        }
    }

    public var isPremiumContent: Bool {
        switch self {
        case .image(_, _, let filter, _):
            return filter.isPremiumFilter
        case .sticker(_, _, let isPremiumSticker, _):
            return isPremiumSticker
        default:
            return false
        }
    }

    // Factory methods
    public static func newText(
        content: String,
        color: HexColor = .black,
        style: StudioTextStyle = StudioTextStyle(),
        at position: CGPoint = CGPoint(x: 187, y: 300)
    ) -> StudioElement {
        .text(
            id: UUID(),
            content: content,
            color: color,
            style: style,
            transform: StudioTransform(offset: CGSize(width: position.x, height: position.y))
        )
    }

    public static func newShape(
        type: StudioShapeType,
        fillColor: HexColor = .champagne,
        strokeColor: HexColor? = nil,
        strokeWidth: CGFloat = 0,
        at position: CGPoint = CGPoint(x: 187, y: 300)
    ) -> StudioElement {
        .shape(
            id: UUID(),
            type: type,
            fillColor: fillColor,
            strokeColor: strokeColor,
            strokeWidth: strokeWidth,
            transform: StudioTransform(offset: CGSize(width: position.x, height: position.y))
        )
    }

    public static func newSticker(
        assetName: String,
        isPremium: Bool = false,
        at position: CGPoint = CGPoint(x: 187, y: 300)
    ) -> StudioElement {
        .sticker(
            id: UUID(),
            assetName: assetName,
            isPremiumSticker: isPremium,
            transform: StudioTransform(offset: CGSize(width: position.x, height: position.y))
        )
    }
}

// MARK: - Studio Canvas State
public struct StudioCanvasState: Codable, Equatable {
    public var elements: [StudioElement]
    public var backgroundColor: HexColor
    public var backgroundImageData: Data?
    public var canvasSize: CGSize
    public var selectedElementId: UUID?

    public init(
        elements: [StudioElement] = [],
        backgroundColor: HexColor = .white,
        backgroundImageData: Data? = nil,
        canvasSize: CGSize = CGSize(width: 375, height: 600),
        selectedElementId: UUID? = nil
    ) {
        self.elements = elements
        self.backgroundColor = backgroundColor
        self.backgroundImageData = backgroundImageData
        self.canvasSize = canvasSize
        self.selectedElementId = selectedElementId
    }

    // Sorted by zIndex
    public var sortedElements: [StudioElement] {
        elements.sorted { $0.transform.zIndex < $1.transform.zIndex }
    }

    public var selectedElement: StudioElement? {
        guard let id = selectedElementId else { return nil }
        return elements.first { $0.id == id }
    }

    public var hasPremiumContent: Bool {
        elements.contains { $0.isPremiumContent }
    }
}

// MARK: - Studio Canvas Action (For Undo/Redo)
public enum StudioCanvasAction {
    case addElement(StudioElement)
    case removeElement(UUID)
    case updateElement(UUID, StudioElement)
    case updateTransform(UUID, StudioTransform)
    case reorder(UUID, Int) // element id, new zIndex
    case setBackground(HexColor)
    case setBackgroundImage(Data?)
}

// MARK: - Studio Gesture Type
public enum StudioGestureType {
    case drag
    case scale
    case rotate
    case tap
}
