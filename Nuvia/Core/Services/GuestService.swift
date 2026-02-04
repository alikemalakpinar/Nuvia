import Foundation
import SwiftData
import SwiftUI

// MARK: - Guest Service
/// Manages all guest, RSVP, and seating operations

@MainActor
public final class GuestService: ObservableObject {
    private let modelContext: ModelContext
    private weak var projectProvider: ProjectProvider?

    init(modelContext: ModelContext, projectProvider: ProjectProvider? = nil) {
        self.modelContext = modelContext
        self.projectProvider = projectProvider
    }

    /// Set the project provider (used for post-init wiring)
    func setProjectProvider(_ provider: ProjectProvider) {
        self.projectProvider = provider
    }

    private var currentProject: WeddingProject? {
        projectProvider?.currentProject
    }

    // MARK: - Guest Operations

    func addGuest(
        firstName: String,
        lastName: String,
        group: GuestGroup = .mutual,
        plusOneCount: Int = 0,
        phone: String? = nil,
        email: String? = nil,
        tags: [String] = [],
        notes: String? = nil
    ) throws -> Guest {
        guard let project = currentProject else { throw DataError.noProject }
        let guest = Guest(firstName: firstName, lastName: lastName, group: group, plusOneCount: plusOneCount)
        guest.phone = phone
        guest.email = email
        guest.notes = notes
        for tag in tags { guest.addTag(tag) }
        project.guests.append(guest)
        try modelContext.save()
        return guest
    }

    func updateGuest(_ guest: Guest, updates: (Guest) -> Void) throws {
        updates(guest)
        guest.updatedAt = Date()
        try modelContext.save()
    }

    func updateGuestRSVP(_ guest: Guest, status: RSVPStatus) throws {
        guest.updateRSVP(status)
        try modelContext.save()
    }

    func bulkUpdateRSVP(guestIds: [UUID], status: RSVPStatus) throws {
        guard let project = currentProject else { throw DataError.noProject }
        for guest in project.guests where guestIds.contains(guest.id) {
            guest.updateRSVP(status)
        }
        try modelContext.save()
    }

    func deleteGuest(_ guest: Guest) throws {
        guard let project = currentProject else { throw DataError.noProject }
        // Remove seat assignment
        if let assignment = guest.seatAssignment {
            modelContext.delete(assignment)
        }
        project.guests.removeAll { $0.id == guest.id }
        modelContext.delete(guest)
        try modelContext.save()
    }

    func addGuestConflict(guest1Id: UUID, guest2Id: UUID) throws {
        guard let project = currentProject else { throw DataError.noProject }
        guard let guest1 = project.guests.first(where: { $0.id == guest1Id }),
              let guest2 = project.guests.first(where: { $0.id == guest2Id }) else {
            throw DataError.notFound
        }
        guest1.addConflict(with: guest2Id)
        guest2.addConflict(with: guest1Id)
        try modelContext.save()
    }

    func removeGuestConflict(guest1Id: UUID, guest2Id: UUID) throws {
        guard let project = currentProject else { throw DataError.noProject }
        guard let guest1 = project.guests.first(where: { $0.id == guest1Id }),
              let guest2 = project.guests.first(where: { $0.id == guest2Id }) else {
            throw DataError.notFound
        }
        guest1.conflictWithGuestIds.removeAll { $0 == guest2Id }
        guest2.conflictWithGuestIds.removeAll { $0 == guest1Id }
        try modelContext.save()
    }

    // MARK: - Seating Operations

    func addTable(
        name: String,
        tableNumber: Int,
        capacity: Int = 10,
        layoutType: TableLayoutType = .round,
        positionX: Double = 0,
        positionY: Double = 0,
        isVIP: Bool = false
    ) throws -> SeatingTable {
        guard let project = currentProject else { throw DataError.noProject }
        let table = SeatingTable(name: name, tableNumber: tableNumber, capacity: capacity, layoutType: layoutType)
        table.positionX = positionX
        table.positionY = positionY
        if isVIP { table.tags.append("VIP") }
        project.tables.append(table)
        try modelContext.save()
        return table
    }

    func updateTable(_ table: SeatingTable, updates: (SeatingTable) -> Void) throws {
        updates(table)
        table.updatedAt = Date()
        try modelContext.save()
    }

    func deleteTable(_ table: SeatingTable) throws {
        guard let project = currentProject else { throw DataError.noProject }
        // Remove all seat assignments for this table
        for assignment in table.seatAssignments {
            modelContext.delete(assignment)
        }
        project.tables.removeAll { $0.id == table.id }
        modelContext.delete(table)
        try modelContext.save()
    }

    func assignGuestToTable(guestId: UUID, tableId: UUID, seatNumber: Int? = nil) throws {
        guard let project = currentProject else { throw DataError.noProject }
        guard let guest = project.guests.first(where: { $0.id == guestId }),
              let table = project.tables.first(where: { $0.id == tableId }) else {
            throw DataError.notFound
        }

        // Check capacity
        guard table.canSeat(guest: guest) else {
            throw DataError.capacityExceeded
        }

        // Check conflicts
        if let conflict = table.hasConflict(with: guest) {
            throw DataError.seatingConflict(conflict.message)
        }

        // Remove existing assignment
        if let existing = guest.seatAssignment {
            modelContext.delete(existing)
        }

        let assignment = SeatAssignment(guest: guest, table: table, seatNumber: seatNumber)
        table.seatAssignments.append(assignment)
        modelContext.insert(assignment)
        try modelContext.save()
    }

    func removeGuestFromTable(guestId: UUID) throws {
        guard let project = currentProject else { throw DataError.noProject }
        guard let guest = project.guests.first(where: { $0.id == guestId }),
              let assignment = guest.seatAssignment else {
            throw DataError.notFound
        }
        modelContext.delete(assignment)
        try modelContext.save()
    }

    func autoAssignGuests() throws -> Int {
        guard let project = currentProject else { throw DataError.noProject }
        var assignedCount = 0
        let unassigned = project.guests.filter { $0.rsvp == .attending && $0.seatAssignment == nil }

        for guest in unassigned {
            for table in project.tables where table.canSeat(guest: guest) && table.hasConflict(with: guest) == nil {
                let assignment = SeatAssignment(guest: guest, table: table)
                table.seatAssignments.append(assignment)
                modelContext.insert(assignment)
                assignedCount += 1
                break
            }
        }

        try modelContext.save()
        return assignedCount
    }

    func detectAllConflicts() -> [SeatingConflict] {
        guard let project = currentProject else { return [] }
        var conflicts: [SeatingConflict] = []

        for table in project.tables {
            let guests = table.seatedGuests
            // Capacity check
            if table.occupiedSeats > table.capacity {
                if let firstGuest = guests.first {
                    conflicts.append(SeatingConflict(type: .capacityExceeded, guest1: firstGuest, guest2: nil, table: table))
                }
            }
            // Personal conflicts
            for i in 0..<guests.count {
                for j in (i+1)..<guests.count {
                    if guests[i].conflictWithGuestIds.contains(guests[j].id) {
                        conflicts.append(SeatingConflict(type: .personalConflict, guest1: guests[i], guest2: guests[j], table: table))
                    }
                }
                // Child at no-child event
                if project.allowChildren == false && guests[i].isChild {
                    conflicts.append(SeatingConflict(type: .noChildTable, guest1: guests[i], guest2: nil, table: table))
                }
            }
        }
        return conflicts
    }

    // MARK: - Guest Analytics

    func getGuestSummary() -> GuestSummary {
        guard let project = currentProject else {
            return GuestSummary(totalInvited: 0, totalHeadcount: 0, attending: 0, notAttending: 0, pending: 0, maybe: 0)
        }

        var attending = 0, notAttending = 0, pending = 0, maybe = 0
        let totalHeadcount = project.totalGuests

        for guest in project.guests {
            switch guest.rsvp {
            case .attending: attending += 1 + guest.plusOneCount
            case .notAttending: notAttending += 1
            case .pending: pending += 1
            case .maybe: maybe += 1
            }
        }

        return GuestSummary(
            totalInvited: project.guests.count,
            totalHeadcount: totalHeadcount,
            attending: attending,
            notAttending: notAttending,
            pending: pending,
            maybe: maybe
        )
    }

    func getSeatingPlanSummary() -> SeatingPlanSummary {
        guard let project = currentProject else {
            return SeatingPlanSummary(totalTables: 0, totalCapacity: 0, seatedGuests: 0, unseatedGuests: 0, conflicts: [])
        }

        let totalCapacity = project.tables.reduce(0) { $0 + $1.capacity }
        let seatedGuests = project.tables.reduce(0) { $0 + $1.occupiedSeats }
        let attendingGuests = project.guests.filter { $0.rsvp == .attending }.reduce(0) { $0 + 1 + $1.plusOneCount }
        let unseatedGuests = max(0, attendingGuests - seatedGuests)

        return SeatingPlanSummary(
            totalTables: project.tables.count,
            totalCapacity: totalCapacity,
            seatedGuests: seatedGuests,
            unseatedGuests: unseatedGuests,
            conflicts: detectAllConflicts()
        )
    }

    func getGuestsByGroup() -> [GuestGroup: [Guest]] {
        guard let project = currentProject else { return [:] }
        return Dictionary(grouping: project.guests, by: { $0.group })
    }

    func getGuestsByRSVP() -> [RSVPStatus: [Guest]] {
        guard let project = currentProject else { return [:] }
        return Dictionary(grouping: project.guests, by: { $0.rsvp })
    }

    func getUnseatedAttendingGuests() -> [Guest] {
        guard let project = currentProject else { return [] }
        return project.guests.filter { $0.rsvp == .attending && $0.seatAssignment == nil }
    }
}

// Note: GuestSummary is defined in Guest.swift
// Note: SeatingPlanSummary is defined in SeatingTable.swift
