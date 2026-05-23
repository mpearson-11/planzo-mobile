//
//  Models.swift
//  planzo-mobile-app
//

import Foundation

// MARK: - User

struct AppUser: Identifiable, Hashable {
    let id: String
    let username: String
    let displayName: String?
    let avatarUrl: String?
    let email: String

    var name: String { displayName ?? username }

    static func == (lhs: AppUser, rhs: AppUser) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Event Location

struct EventLocation: Identifiable {
    let id: String
    let name: String
    let address: String?
    let city: String?
    let country: String?
    let latitude: Double?
    let longitude: Double?

    var shortAddress: String {
        [city, country].compactMap { $0 }.joined(separator: ", ")
    }

    var fullAddress: String {
        [address, city, country].compactMap { $0 }.joined(separator: ", ")
    }
}

// MARK: - Task Category

enum TaskCategory: String, CaseIterable, Identifiable {
    case payment, transport, booking, catering, admin, entertainment, other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .payment: return "Payment"
        case .transport: return "Transport"
        case .booking: return "Booking"
        case .catering: return "Catering"
        case .admin: return "Admin"
        case .entertainment: return "Entertainment"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .payment: return "creditcard.fill"
        case .transport: return "bus.fill"
        case .booking: return "calendar.badge.plus"
        case .catering: return "fork.knife"
        case .admin: return "doc.text.fill"
        case .entertainment: return "music.note"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Event Task

struct EventTask: Identifiable {
    let id: String
    var title: String
    var description: String?
    var isCompleted: Bool
    var assignedTo: AppUser?
    var dueDate: Date?
    var category: TaskCategory = .other
    var amount: Double? = nil
}

// MARK: - Assignee

struct Assignee: Identifiable, Hashable {
    let id: String
    let user: AppUser
    var role: String

    static func == (lhs: Assignee, rhs: Assignee) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Event Preview

struct EventPreview: Identifiable {
    let id: String
    let eventId: String
    var previewTitle: String
    var previewDescription: String?
    var thumbnailUrl: String?
}

// MARK: - Event

struct Event: Identifiable {
    let id: String
    var title: String
    var description: String?
    var startDate: Date
    var endDate: Date
    var allDay: Bool
    var location: EventLocation?
    var assignees: [Assignee]
    var preview: EventPreview?
    var budget: Double?
    var tasks: [EventTask] = []
}

// MARK: - Shared Calendar Entry

struct SharedCalendarEntry: Identifiable {
    let id: String
    let sharedWithUserId: String
    var permission: String
}

// MARK: - Friend

struct AppFriend: Identifiable {
    let id: String
    let friendUser: AppUser
    var status: String

    var isPending: Bool { status == "pending" }
    var isAccepted: Bool { status == "accepted" }
}
