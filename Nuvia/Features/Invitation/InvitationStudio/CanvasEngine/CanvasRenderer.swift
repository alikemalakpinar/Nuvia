import SwiftUI
import UIKit
import PDFKit
import CoreGraphics

// MARK: - Canvas Renderer
// High-resolution PDF/PNG export service

@MainActor
public final class CanvasRenderer {

    public enum ExportFormat {
        case png
        case pdf
        case jpeg(quality: CGFloat)
    }

    public enum ExportResolution: Equatable {
        case standard    // 1x
        case high        // 2x
        case print       // 3x (300 DPI equivalent)
        case custom(CGFloat)

        var scale: CGFloat {
            switch self {
            case .standard: return 1.0
            case .high: return 2.0
            case .print: return 3.0
            case .custom(let s): return s
            }
        }
    }

    public struct ExportOptions {
        public var format: ExportFormat
        public var resolution: ExportResolution
        public var includeBackground: Bool
        public var trimWhitespace: Bool

        public init(
            format: ExportFormat = .png,
            resolution: ExportResolution = .high,
            includeBackground: Bool = true,
            trimWhitespace: Bool = false
        ) {
            self.format = format
            self.resolution = resolution
            self.includeBackground = includeBackground
            self.trimWhitespace = trimWhitespace
        }

        public static let preview = ExportOptions(format: .jpeg(quality: 0.8), resolution: .standard)
        public static let share = ExportOptions(format: .png, resolution: .high)
        public static let print = ExportOptions(format: .pdf, resolution: .print)
    }

    // MARK: - Public API

    public static func render(
        state: StudioCanvasState,
        options: ExportOptions = .share
    ) async throws -> Data {
        let view = CanvasRenderView(state: state, includeBackground: options.includeBackground)
        let size = CGSize(
            width: state.canvasSize.width * options.resolution.scale,
            height: state.canvasSize.height * options.resolution.scale
        )

        switch options.format {
        case .png:
            return try await renderToPNG(view: view, size: size, scale: options.resolution.scale)
        case .pdf:
            return try await renderToPDF(view: view, size: state.canvasSize)
        case .jpeg(let quality):
            return try await renderToJPEG(view: view, size: size, scale: options.resolution.scale, quality: quality)
        }
    }

    public static func renderPreview(state: StudioCanvasState) async -> UIImage? {
        let view = CanvasRenderView(state: state, includeBackground: true)
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }

    // MARK: - Private Rendering Methods

    private static func renderToPNG(view: some View, size: CGSize, scale: CGFloat) async throws -> Data {
        let renderer = ImageRenderer(content: view.frame(width: size.width / scale, height: size.height / scale))
        renderer.scale = scale

        guard let uiImage = renderer.uiImage,
              let data = uiImage.pngData() else {
            throw RenderError.failedToRender
        }

        return data
    }

    private static func renderToJPEG(view: some View, size: CGSize, scale: CGFloat, quality: CGFloat) async throws -> Data {
        let renderer = ImageRenderer(content: view.frame(width: size.width / scale, height: size.height / scale))
        renderer.scale = scale

        guard let uiImage = renderer.uiImage,
              let data = uiImage.jpegData(compressionQuality: quality) else {
            throw RenderError.failedToRender
        }

        return data
    }

    private static func renderToPDF(view: some View, size: CGSize) async throws -> Data {
        let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height))

        let pdfData = NSMutableData()

        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData) else {
            throw RenderError.failedToCreatePDF
        }

        var mediaBox = CGRect(origin: .zero, size: size)

        guard let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw RenderError.failedToCreatePDF
        }

        renderer.render { size, render in
            context.beginPDFPage(nil)
            render(context)
            context.endPDFPage()
            context.closePDF()
        }

        return pdfData as Data
    }

    // MARK: - Errors

    public enum RenderError: Error, LocalizedError {
        case failedToRender
        case failedToCreatePDF
        case premiumRequired

        public var errorDescription: String? {
            switch self {
            case .failedToRender:
                return "Failed to render the invitation"
            case .failedToCreatePDF:
                return "Failed to create PDF document"
            case .premiumRequired:
                return "Premium subscription required for this export option"
            }
        }
    }
}

// MARK: - Canvas Render View (For Export)

struct CanvasRenderView: View {
    let state: StudioCanvasState
    let includeBackground: Bool

    var body: some View {
        ZStack {
            // Background
            if includeBackground {
                if let imageData = state.backgroundImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(state.backgroundColor.color)
                }
            }

            // Elements (sorted by zIndex)
            ForEach(state.sortedElements) { element in
                CanvasElementRenderView(element: element)
                    .offset(x: element.transform.offset.width - state.canvasSize.width / 2,
                            y: element.transform.offset.height - state.canvasSize.height / 2)
                    .rotationEffect(element.transform.rotation)
                    .scaleEffect(element.transform.scale)
            }
        }
        .frame(width: state.canvasSize.width, height: state.canvasSize.height)
        .clipped()
    }
}

// MARK: - Canvas Element Render View

struct CanvasElementRenderView: View {
    let element: StudioElement

    var body: some View {
        Group {
            switch element {
            case .text(_, let content, let color, let style, _):
                Text(content)
                    .font(fontFromStyle(style))
                    .foregroundColor(color.color)
                    .multilineTextAlignment(style.alignment.swiftUIAlignment)
                    .tracking(style.letterSpacing)
                    .lineSpacing(style.fontSize * (style.lineHeight - 1))

            case .image(_, let imageData, let filter, _):
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .applyStudioFilter(filter)
                }

            case .shape(_, let type, let fillColor, let strokeColor, let strokeWidth, _):
                shapeView(type: type, fill: fillColor, stroke: strokeColor, strokeWidth: strokeWidth)

            case .sticker(_, let assetName, _, _):
                if assetName.hasPrefix("system:") {
                    let iconName = String(assetName.dropFirst(7))
                    Image(systemName: iconName)
                        .font(.system(size: 48))
                        .foregroundColor(.nuviaChampagne)
                } else {
                    Image(assetName)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
    }

    private func fontFromStyle(_ style: StudioTextStyle) -> Font {
        .system(size: style.fontSize, weight: style.fontWeight.swiftUIWeight)
    }

    @ViewBuilder
    private func shapeView(type: StudioShapeType, fill: HexColor, stroke: HexColor?, strokeWidth: CGFloat) -> some View {
        switch type {
        case .rectangle:
            if let strokeColor = stroke, strokeWidth > 0 {
                RoundedRectangle(cornerRadius: 8)
                    .fill(fill.color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(strokeColor.color, lineWidth: strokeWidth)
                    )
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(fill.color)
            }

        case .circle:
            if let strokeColor = stroke, strokeWidth > 0 {
                Circle()
                    .fill(fill.color)
                    .overlay(Circle().stroke(strokeColor.color, lineWidth: strokeWidth))
            } else {
                Circle().fill(fill.color)
            }

        case .ellipse:
            if let strokeColor = stroke, strokeWidth > 0 {
                Ellipse()
                    .fill(fill.color)
                    .overlay(Ellipse().stroke(strokeColor.color, lineWidth: strokeWidth))
            } else {
                Ellipse().fill(fill.color)
            }

        case .line:
            Rectangle()
                .fill(fill.color)
                .frame(height: max(1, strokeWidth))

        case .divider:
            HStack(spacing: 12) {
                Rectangle().fill(fill.color).frame(height: 1)
                Image(systemName: "heart.fill")
                    .font(.system(size: 14))
                    .foregroundColor(fill.color)
                Rectangle().fill(fill.color).frame(height: 1)
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
}

// MARK: - Filter Extension

extension View {
    @ViewBuilder
    func applyStudioFilter(_ filter: StudioPhotoFilter) -> some View {
        switch filter {
        case .none:
            self
        case .sepia:
            self.colorMultiply(Color(red: 1.0, green: 0.9, blue: 0.7))
        case .mono:
            self.saturation(0)
        case .chrome:
            self.contrast(1.2).saturation(1.3)
        case .fade:
            self.opacity(0.8).contrast(0.9)
        case .instant:
            self.colorMultiply(Color(red: 1.0, green: 0.95, blue: 0.85)).contrast(1.1)
        case .process:
            self.saturation(1.2).brightness(0.05)
        case .transfer:
            self.colorMultiply(Color(red: 0.95, green: 0.9, blue: 1.0))
        case .vignette:
            self.overlay(
                RadialGradient(
                    colors: [.clear, .black.opacity(0.3)],
                    center: .center,
                    startRadius: 100,
                    endRadius: 300
                )
            )
        }
    }
}

// MARK: - Share Service

@MainActor
public final class CanvasShareService {

    public static func share(
        state: StudioCanvasState,
        options: CanvasRenderer.ExportOptions = .share,
        from viewController: UIViewController? = nil
    ) async {
        do {
            let data = try await CanvasRenderer.render(state: state, options: options)

            let tempURL: URL
            switch options.format {
            case .png:
                tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("invitation.png")
            case .pdf:
                tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("invitation.pdf")
            case .jpeg:
                tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("invitation.jpg")
            }

            try data.write(to: tempURL)

            let activityVC = UIActivityViewController(
                activityItems: [tempURL],
                applicationActivities: nil
            )

            if let vc = viewController ?? UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.rootViewController {
                vc.present(activityVC, animated: true)
            }

            UINotificationFeedbackGenerator().notificationOccurred(.success)

        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            print("Share failed: \(error)")
        }
    }
}
