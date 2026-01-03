import Foundation
import SwiftData

/// Kullanıcı modeli
@Model
final class User {
    @Attribute(.unique) var id: UUID
    var createdAt: Date

    /// Kullanıcı bilgileri
    var name: String
    var email: String?
    var phone: String?
    var avatarData: Data?

    /// Rol
    var role: String // owner, partner, family, organizer, guest

    /// Proje ilişkisi
    @Relationship(inverse: \WeddingProject.users)
    var project: WeddingProject?

    /// Atanan görevler
    @Relationship(inverse: \Task.assignee)
    var assignedTasks: [Task]

    // MARK: - Hesaplanan Özellikler

    var userRole: UserRole {
        UserRole(rawValue: role) ?? .guest
    }

    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var pendingTasksCount: Int {
        assignedTasks.filter { $0.status != .completed }.count
    }

    // MARK: - Init

    init(name: String, role: UserRole = .owner, email: String? = nil, phone: String? = nil) {
        self.id = UUID()
        self.createdAt = Date()
        self.name = name
        self.role = role.rawValue
        self.email = email
        self.phone = phone
        self.assignedTasks = []
    }
}

// MARK: - Invite Link Helper

struct InviteLink {
    let projectId: UUID
    let role: UserRole
    let expiresAt: Date
    let token: String

    var url: URL? {
        var components = URLComponents()
        components.scheme = "nuvia"
        components.host = "invite"
        components.queryItems = [
            URLQueryItem(name: "project", value: projectId.uuidString),
            URLQueryItem(name: "role", value: role.rawValue),
            URLQueryItem(name: "token", value: token)
        ]
        return components.url
    }

    static func generate(for projectId: UUID, role: UserRole) -> InviteLink {
        InviteLink(
            projectId: projectId,
            role: role,
            expiresAt: Date().addingTimeInterval(7 * 24 * 60 * 60), // 7 gün
            token: UUID().uuidString
        )
    }
}
