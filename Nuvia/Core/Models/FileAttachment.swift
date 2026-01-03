import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// Dosya eki modeli
@Model
final class FileAttachment {
    @Attribute(.unique) var id: UUID
    var createdAt: Date

    /// Dosya bilgileri
    var fileName: String
    var fileType: String // contract, receipt, photo, document, other
    var mimeType: String?
    var fileSize: Int64?

    /// Depolama
    var localPath: String?
    var cloudPath: String?

    /// Güvenlik
    var isEncrypted: Bool
    var requiresFaceID: Bool

    /// Notlar
    var notes: String?

    /// Etiketler
    var tags: [String]

    // MARK: - İlişkiler

    @Relationship(inverse: \WeddingProject.files)
    var project: WeddingProject?

    @Relationship(inverse: \Task.attachments)
    var linkedTask: Task?

    // MARK: - Hesaplanan Özellikler

    var attachmentType: FileAttachmentType {
        get { FileAttachmentType(rawValue: fileType) ?? .other }
        set { fileType = newValue.rawValue }
    }

    var formattedSize: String {
        guard let size = fileSize else { return "Bilinmiyor" }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    var isImage: Bool {
        guard let mime = mimeType else { return false }
        return mime.hasPrefix("image/")
    }

    var isPDF: Bool {
        mimeType == "application/pdf"
    }

    var fileExtension: String {
        (fileName as NSString).pathExtension.lowercased()
    }

    var icon: String {
        switch fileExtension {
        case "pdf": return "doc.fill"
        case "jpg", "jpeg", "png", "heic": return "photo.fill"
        case "doc", "docx": return "doc.text.fill"
        case "xls", "xlsx": return "tablecells.fill"
        default: return "doc.fill"
        }
    }

    // MARK: - Init

    init(
        fileName: String,
        type: FileAttachmentType,
        mimeType: String? = nil,
        fileSize: Int64? = nil
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.fileName = fileName
        self.fileType = type.rawValue
        self.mimeType = mimeType
        self.fileSize = fileSize
        self.isEncrypted = false
        self.requiresFaceID = false
        self.tags = []
    }
}

// MARK: - Dosya Tipi

enum FileAttachmentType: String, CaseIterable, Codable {
    case contract = "contract"
    case receipt = "receipt"
    case photo = "photo"
    case document = "document"
    case id = "id"
    case inspiration = "inspiration"
    case other = "other"

    var displayName: String {
        switch self {
        case .contract: return "Sözleşme"
        case .receipt: return "Fiş/Fatura"
        case .photo: return "Fotoğraf"
        case .document: return "Belge"
        case .id: return "Kimlik/Evrak"
        case .inspiration: return "İlham"
        case .other: return "Diğer"
        }
    }

    var icon: String {
        switch self {
        case .contract: return "doc.text.fill"
        case .receipt: return "receipt.fill"
        case .photo: return "photo.fill"
        case .document: return "doc.fill"
        case .id: return "person.text.rectangle.fill"
        case .inspiration: return "sparkles"
        case .other: return "folder.fill"
        }
    }

    var color: Color {
        switch self {
        case .contract: return .nuviaInfo
        case .receipt: return .nuviaSuccess
        case .photo: return .categoryPhoto
        case .document: return .nuviaSecondaryText
        case .id: return .nuviaWarning
        case .inspiration: return .categoryDress
        case .other: return .nuviaTertiaryText
        }
    }

    var requiresEncryption: Bool {
        self == .id || self == .contract
    }
}

// MARK: - Dosya Kasası Kategorileri

enum FileVaultCategory: String, CaseIterable {
    case contracts = "Sözleşmeler"
    case identityDocuments = "Kimlik/Evrak"
    case invitationDesigns = "Davetiye Görselleri"
    case moodboard = "İlham Panosu"
    case receipts = "Fişler/Faturalar"

    var icon: String {
        switch self {
        case .contracts: return "doc.text.fill"
        case .identityDocuments: return "person.text.rectangle.fill"
        case .invitationDesigns: return "envelope.fill"
        case .moodboard: return "square.grid.2x2.fill"
        case .receipts: return "receipt.fill"
        }
    }

    var requiresFaceID: Bool {
        self == .identityDocuments
    }
}
