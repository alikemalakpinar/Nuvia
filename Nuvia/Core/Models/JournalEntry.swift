import Foundation
import SwiftData
import SwiftUI

/// Günlük/Anı girişi modeli
@Model
final class JournalEntry {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date

    /// İçerik
    var title: String?
    var content: String
    var date: Date

    /// Ruh hali
    var mood: String? // happy, excited, stressed, calm, romantic, grateful

    /// Etiketler
    var tags: [String] // karar, mutluluk, stres, hatira

    /// Fotoğraf verileri (küçük boyutlu)
    var photoIdentifiers: [String]

    /// Timeline bağlantısı
    var linkedDate: Date?

    // MARK: - İlişkiler

    @Relationship(inverse: \WeddingProject.journalEntries)
    var project: WeddingProject?

    // MARK: - Hesaplanan Özellikler

    var entryMood: JournalMood? {
        get {
            guard let mood = mood else { return nil }
            return JournalMood(rawValue: mood)
        }
        set { mood = newValue?.rawValue }
    }

    var preview: String {
        String(content.prefix(100)) + (content.count > 100 ? "..." : "")
    }

    var formattedDate: String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    var hasPhotos: Bool {
        !photoIdentifiers.isEmpty
    }

    // MARK: - Init

    init(content: String, date: Date = Date(), mood: JournalMood? = nil) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.content = content
        self.date = date
        self.mood = mood?.rawValue
        self.tags = []
        self.photoIdentifiers = []
    }

    // MARK: - Methods

    func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
        }
    }

    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    func addPhoto(identifier: String) {
        photoIdentifiers.append(identifier)
        updatedAt = Date()
    }
}

// MARK: - Ruh Hali

enum JournalMood: String, CaseIterable, Codable {
    case happy = "happy"
    case excited = "excited"
    case stressed = "stressed"
    case calm = "calm"
    case romantic = "romantic"
    case grateful = "grateful"
    case anxious = "anxious"
    case proud = "proud"

    var displayName: String {
        switch self {
        case .happy: return "Mutlu"
        case .excited: return "Heyecanlı"
        case .stressed: return "Stresli"
        case .calm: return "Sakin"
        case .romantic: return "Romantik"
        case .grateful: return "Minnettar"
        case .anxious: return "Endişeli"
        case .proud: return "Gururlu"
        }
    }

    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .excited: return "🥳"
        case .stressed: return "😰"
        case .calm: return "😌"
        case .romantic: return "🥰"
        case .grateful: return "🙏"
        case .anxious: return "😟"
        case .proud: return "😤"
        }
    }

    var color: Color {
        switch self {
        case .happy: return .nuviaSuccess
        case .excited: return .nuviaWarning
        case .stressed: return .nuviaError
        case .calm: return .nuviaInfo
        case .romantic: return .categoryDress
        case .grateful: return .nuviaGoldFallback
        case .anxious: return .categoryMusic
        case .proud: return .categoryVenue
        }
    }
}

// MARK: - Yaygın Etiketler

enum JournalTag: String, CaseIterable {
    case decision = "karar"
    case happiness = "mutluluk"
    case stress = "stres"
    case memory = "hatira"
    case milestone = "dönüm_noktası"
    case lesson = "ders"
    case gratitude = "minnettarlık"

    var displayName: String {
        switch self {
        case .decision: return "Karar"
        case .happiness: return "Mutluluk"
        case .stress: return "Stres"
        case .memory: return "Hatıra"
        case .milestone: return "Dönüm Noktası"
        case .lesson: return "Öğrenilen Ders"
        case .gratitude: return "Minnettarlık"
        }
    }

    var icon: String {
        switch self {
        case .decision: return "checkmark.seal.fill"
        case .happiness: return "heart.fill"
        case .stress: return "bolt.fill"
        case .memory: return "camera.fill"
        case .milestone: return "flag.fill"
        case .lesson: return "lightbulb.fill"
        case .gratitude: return "hands.clap.fill"
        }
    }
}
