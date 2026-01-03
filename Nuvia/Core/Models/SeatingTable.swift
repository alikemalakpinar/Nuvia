import Foundation
import SwiftData
import SwiftUI

/// Masa modeli
@Model
final class SeatingTable {
    @Attribute(.unique) var id: UUID
    var createdAt: Date

    /// Masa bilgileri
    var name: String
    var tableNumber: Int
    var capacity: Int
    var layoutType: String // round, rectangular, oval

    /// Canvas üzerindeki konum
    var positionX: Double
    var positionY: Double
    var rotation: Double

    /// Özel notlar
    var notes: String?

    /// Özel etiketler
    var tags: [String] // VIP, aile, gelin, damat

    // MARK: - İlişkiler

    @Relationship(inverse: \WeddingProject.tables)
    var project: WeddingProject?

    @Relationship(deleteRule: .cascade, inverse: \SeatAssignment.table)
    var seatAssignments: [SeatAssignment]

    // MARK: - Hesaplanan Özellikler

    var tableLayoutType: TableLayoutType {
        get { TableLayoutType(rawValue: layoutType) ?? .round }
        set { layoutType = newValue.rawValue }
    }

    var occupiedSeats: Int {
        seatAssignments.reduce(0) { total, assignment in
            total + 1 + (assignment.guest?.plusOneCount ?? 0)
        }
    }

    var availableSeats: Int {
        max(0, capacity - occupiedSeats)
    }

    var isFull: Bool {
        availableSeats == 0
    }

    var occupancyRate: Double {
        guard capacity > 0 else { return 0 }
        return Double(occupiedSeats) / Double(capacity)
    }

    var isVIP: Bool {
        tags.contains("VIP")
    }

    var seatedGuests: [Guest] {
        seatAssignments.compactMap { $0.guest }
    }

    // MARK: - Init

    init(
        name: String,
        tableNumber: Int,
        capacity: Int = 10,
        layoutType: TableLayoutType = .round
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.name = name
        self.tableNumber = tableNumber
        self.capacity = capacity
        self.layoutType = layoutType.rawValue
        self.positionX = 0
        self.positionY = 0
        self.rotation = 0
        self.tags = []
        self.seatAssignments = []
    }

    // MARK: - Methods

    func canSeat(guest: Guest) -> Bool {
        let requiredSeats = 1 + guest.plusOneCount
        return availableSeats >= requiredSeats
    }

    func hasConflict(with guest: Guest) -> SeatingConflict? {
        for assignment in seatAssignments {
            guard let seatedGuest = assignment.guest else { continue }

            // Çatışma kontrolü
            if guest.conflictWithGuestIds.contains(seatedGuest.id) ||
               seatedGuest.conflictWithGuestIds.contains(guest.id) {
                return SeatingConflict(
                    type: .personalConflict,
                    guest1: guest,
                    guest2: seatedGuest,
                    table: self
                )
            }
        }
        return nil
    }
}

// MARK: - Koltuk Ataması

@Model
final class SeatAssignment {
    @Attribute(.unique) var id: UUID
    var createdAt: Date

    /// Koltuk numarası (opsiyonel)
    var seatNumber: Int?

    // MARK: - İlişkiler

    @Relationship
    var guest: Guest?

    @Relationship
    var table: SeatingTable?

    // MARK: - Init

    init(guest: Guest, table: SeatingTable, seatNumber: Int? = nil) {
        self.id = UUID()
        self.createdAt = Date()
        self.guest = guest
        self.table = table
        self.seatNumber = seatNumber
    }
}

// MARK: - Masa Tipi

enum TableLayoutType: String, CaseIterable, Codable {
    case round = "round"
    case rectangular = "rectangular"
    case oval = "oval"
    case uShape = "uShape"

    var displayName: String {
        switch self {
        case .round: return "Yuvarlak"
        case .rectangular: return "Dikdörtgen"
        case .oval: return "Oval"
        case .uShape: return "U Şeklinde"
        }
    }

    var icon: String {
        switch self {
        case .round: return "circle"
        case .rectangular: return "rectangle"
        case .oval: return "oval"
        case .uShape: return "u.circle"
        }
    }

    var defaultCapacity: Int {
        switch self {
        case .round: return 10
        case .rectangular: return 8
        case .oval: return 12
        case .uShape: return 20
        }
    }
}

// MARK: - Çatışma Türü

struct SeatingConflict: Identifiable {
    let id = UUID()
    let type: ConflictType
    let guest1: Guest
    let guest2: Guest?
    let table: SeatingTable

    enum ConflictType {
        case personalConflict    // İki kişi yan yana olmasın
        case familySeparation   // Aile üyeleri ayrılmış
        case capacityExceeded   // Kapasite aşıldı
        case noChildTable       // Çocuğu yetişkin masasına oturttun

        var displayName: String {
            switch self {
            case .personalConflict: return "Kişisel Çatışma"
            case .familySeparation: return "Aile Ayrılmış"
            case .capacityExceeded: return "Kapasite Aşıldı"
            case .noChildTable: return "Çocuk Uyumsuzluğu"
            }
        }

        var icon: String {
            switch self {
            case .personalConflict: return "exclamationmark.triangle.fill"
            case .familySeparation: return "person.3.sequence.fill"
            case .capacityExceeded: return "person.crop.circle.badge.exclamationmark"
            case .noChildTable: return "figure.child.and.lock"
            }
        }

        var color: Color {
            switch self {
            case .personalConflict: return .nuviaError
            case .familySeparation: return .nuviaWarning
            case .capacityExceeded: return .nuviaError
            case .noChildTable: return .nuviaWarning
            }
        }
    }

    var message: String {
        switch type {
        case .personalConflict:
            return "\(guest1.fullName) ve \(guest2?.fullName ?? "bu kişi") yan yana oturmamalı"
        case .familySeparation:
            return "\(guest1.fullName) aile üyelerinden ayrılmış"
        case .capacityExceeded:
            return "\(table.name) kapasitesi aşıldı"
        case .noChildTable:
            return "\(guest1.fullName) çocuk, yetişkin masasına atanmış"
        }
    }
}

// MARK: - Seating Plan Summary

struct SeatingPlanSummary {
    let totalTables: Int
    let totalCapacity: Int
    let seatedGuests: Int
    let unseatedGuests: Int
    let conflicts: [SeatingConflict]

    var occupancyRate: Double {
        guard totalCapacity > 0 else { return 0 }
        return Double(seatedGuests) / Double(totalCapacity)
    }

    var hasConflicts: Bool {
        !conflicts.isEmpty
    }
}
