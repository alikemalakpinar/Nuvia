import Foundation
import SwiftData
import SwiftUI

/// Davetli modeli
@Model
final class Guest {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date

    /// Kişi bilgileri
    var firstName: String
    var lastName: String
    var phone: String?
    var email: String?

    /// Grup/taraf
    var group: String // bride, groom, mutual, work, friend

    /// RSVP durumu
    var rsvpStatus: String // pending, attending, notAttending, maybe

    /// Eşlik eden kişiler
    var plusOneCount: Int
    var plusOneNames: [String]

    /// Etiketler
    var tags: [String] // VIP, aile, cocukyok, alerji, vegan, etc.

    /// Özel notlar
    var notes: String?

    /// Alerji/diyet bilgisi
    var dietaryRestrictions: String?

    /// Çatışma notu (bu kişiyle yan yana olmasın)
    var conflictWithGuestIds: [UUID]

    // MARK: - İlişkiler

    @Relationship(inverse: \WeddingProject.guests)
    var project: WeddingProject?

    @Relationship(inverse: \SeatAssignment.guest)
    var seatAssignment: SeatAssignment?

    // MARK: - Hesaplanan Özellikler

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var initials: String {
        String(firstName.prefix(1) + lastName.prefix(1)).uppercased()
    }

    var guestGroup: GuestGroup {
        get { GuestGroup(rawValue: group) ?? .mutual }
        set { group = newValue.rawValue }
    }

    var rsvp: RSVPStatus {
        get { RSVPStatus(rawValue: rsvpStatus) ?? .pending }
        set { rsvpStatus = newValue.rawValue }
    }

    var totalHeadcount: Int {
        1 + plusOneCount
    }

    var hasAllergy: Bool {
        tags.contains("alerji") || dietaryRestrictions != nil
    }

    var isVIP: Bool {
        tags.contains("VIP")
    }

    var isChild: Bool {
        tags.contains("cocuk")
    }

    var isSeated: Bool {
        seatAssignment != nil
    }

    // MARK: - Init

    init(
        firstName: String,
        lastName: String,
        group: GuestGroup = .mutual,
        plusOneCount: Int = 0
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.firstName = firstName
        self.lastName = lastName
        self.group = group.rawValue
        self.rsvpStatus = RSVPStatus.pending.rawValue
        self.plusOneCount = plusOneCount
        self.plusOneNames = []
        self.tags = []
        self.conflictWithGuestIds = []
    }

    // MARK: - Methods

    func updateRSVP(_ status: RSVPStatus) {
        rsvpStatus = status.rawValue
        updatedAt = Date()
    }

    func addConflict(with guestId: UUID) {
        if !conflictWithGuestIds.contains(guestId) {
            conflictWithGuestIds.append(guestId)
        }
    }

    func removeConflict(with guestId: UUID) {
        conflictWithGuestIds.removeAll { $0 == guestId }
    }

    func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
        }
    }

    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
}

// MARK: - Davetli Grubu

enum GuestGroup: String, CaseIterable, Codable {
    case bride = "bride"
    case groom = "groom"
    case mutual = "mutual"
    case work = "work"
    case friend = "friend"

    var displayName: String {
        switch self {
        case .bride: return "Gelin Tarafı"
        case .groom: return "Damat Tarafı"
        case .mutual: return "Ortak"
        case .work: return "İş Arkadaşları"
        case .friend: return "Arkadaşlar"
        }
    }

    var icon: String {
        switch self {
        case .bride: return "person.fill"
        case .groom: return "person.fill"
        case .mutual: return "person.2.fill"
        case .work: return "briefcase.fill"
        case .friend: return "heart.fill"
        }
    }

    var color: Color {
        switch self {
        case .bride: return .categoryDress
        case .groom: return .nuviaInfo
        case .mutual: return .nuviaGoldFallback
        case .work: return .nuviaSecondaryText
        case .friend: return .categoryMusic
        }
    }
}

// MARK: - RSVP Durumu

enum RSVPStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case attending = "attending"
    case notAttending = "notAttending"
    case maybe = "maybe"

    var displayName: String {
        switch self {
        case .pending: return "Bekliyor"
        case .attending: return "Geliyor"
        case .notAttending: return "Gelmiyor"
        case .maybe: return "Belki"
        }
    }

    var icon: String {
        switch self {
        case .pending: return "questionmark.circle"
        case .attending: return "checkmark.circle.fill"
        case .notAttending: return "xmark.circle.fill"
        case .maybe: return "minus.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .pending: return .statusPending
        case .attending: return .statusCompleted
        case .notAttending: return .nuviaError
        case .maybe: return .nuviaWarning
        }
    }
}

// MARK: - Guest Tags (Yaygın etiketler)

enum GuestTag: String, CaseIterable {
    case vip = "VIP"
    case family = "aile"
    case noChildren = "cocukyok"
    case child = "cocuk"
    case allergy = "alerji"
    case vegan = "vegan"
    case vegetarian = "vejetaryen"
    case wheelchair = "tekerlekli_sandalye"
    case plusOne = "eşli"

    var displayName: String {
        switch self {
        case .vip: return "VIP"
        case .family: return "Aile"
        case .noChildren: return "Çocuk Davetli Değil"
        case .child: return "Çocuk"
        case .allergy: return "Alerjisi Var"
        case .vegan: return "Vegan"
        case .vegetarian: return "Vejetaryen"
        case .wheelchair: return "Tekerlekli Sandalye"
        case .plusOne: return "+1 Eşli"
        }
    }

    var icon: String {
        switch self {
        case .vip: return "star.fill"
        case .family: return "person.3.fill"
        case .noChildren: return "figure.child.and.lock"
        case .child: return "figure.child"
        case .allergy: return "allergens"
        case .vegan: return "leaf.fill"
        case .vegetarian: return "carrot.fill"
        case .wheelchair: return "figure.roll"
        case .plusOne: return "person.2.fill"
        }
    }
}

// MARK: - Guest Summary

struct GuestSummary {
    let totalInvited: Int
    let totalHeadcount: Int
    let attending: Int
    let notAttending: Int
    let pending: Int
    let maybe: Int

    var attendanceRate: Double {
        guard totalInvited > 0 else { return 0 }
        return Double(attending) / Double(totalInvited)
    }

    var responseRate: Double {
        guard totalInvited > 0 else { return 0 }
        return Double(totalInvited - pending) / Double(totalInvited)
    }
}
