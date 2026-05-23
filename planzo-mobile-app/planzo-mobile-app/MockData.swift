//
//  MockData.swift
//  planzo-mobile-app
//

import Foundation

// MARK: - Current User

extension AppUser {
    static let current = AppUser(
        id: "u1",
        username: "maxpearson",
        displayName: "Max Pearson",
        avatarUrl: nil,
        email: "max@planzo.app"
    )
}

// MARK: - Sample Users

enum SampleUsers {
    static let all: [AppUser] = [
        AppUser(id: "u2", username: "sarahj",   displayName: "Sarah Johnson", avatarUrl: nil, email: "sarah@planzo.app"),
        AppUser(id: "u3", username: "mikechen", displayName: "Mike Chen",     avatarUrl: nil, email: "mike@planzo.app"),
        AppUser(id: "u4", username: "emilyr",   displayName: "Emily Rose",    avatarUrl: nil, email: "emily@planzo.app"),
        AppUser(id: "u5", username: "danwilson",displayName: "Dan Wilson",    avatarUrl: nil, email: "dan@planzo.app"),
        AppUser(id: "u6", username: "jasminep", displayName: "Jasmine Park",  avatarUrl: nil, email: "jasmine@planzo.app"),
        AppUser(id: "u7", username: "alexm",    displayName: "Alex Martinez", avatarUrl: nil, email: "alex@planzo.app"),
    ]
}

// MARK: - Sample Locations

enum SampleLocations {
    static let rooftop = EventLocation(
        id: "l1", name: "The Rooftop Lounge",
        address: "45 Sky High Street", city: "London", country: "UK",
        latitude: 51.5074, longitude: -0.1278
    )
    static let park = EventLocation(
        id: "l2", name: "Regent's Park",
        address: "Chester Road", city: "London", country: "UK",
        latitude: 51.5313, longitude: -0.1570
    )
    static let restaurant = EventLocation(
        id: "l3", name: "Nobu London",
        address: "15 Old Park Lane", city: "London", country: "UK",
        latitude: 51.5038, longitude: -0.1517
    )
    static let cinema = EventLocation(
        id: "l4", name: "Everyman Cinema",
        address: "5 Holly Bush Vale", city: "London", country: "UK",
        latitude: 51.5569, longitude: -0.1780
    )
    static let hedsor = EventLocation(
        id: "l5", name: "Hedsor House",
        address: "Taplow Hill", city: "Buckinghamshire", country: "UK",
        latitude: 51.5433, longitude: -0.6858
    )
}

// MARK: - Sample Events

enum SampleEvents {
    static let latest = Event(
        id: "e1",
        title: "Summer Rooftop Party",
        description: "Join us for an unforgettable evening with stunning city views, incredible music, and amazing company. Dress code: Smart casual. Drinks are on the house!",
        startDate: Calendar.current.date(byAdding: .hour, value: 3, to: Date())!,
        endDate: Calendar.current.date(byAdding: .hour, value: 7, to: Date())!,
        allDay: false,
        location: SampleLocations.rooftop,
        assignees: [
            Assignee(id: "a1_0", user: SampleUsers.all[0], role: "Host"),
            Assignee(id: "a1_1", user: SampleUsers.all[1], role: "Guest"),
            Assignee(id: "a1_2", user: SampleUsers.all[2], role: "DJ"),
        ],
        preview: EventPreview(
            id: "ep1", eventId: "e1",
            previewTitle: "Doors open at 8pm",
            previewDescription: "Smart casual dress code. Bar open until midnight. Limited entry — check the entry list."
        ),
        budget: 500.0,
        tasks: [
            EventTask(id: "t9",  title: "Confirm rooftop booking with venue",     description: "Call The Rooftop Lounge on 020 7000 0000 to confirm the 8pm slot.", isCompleted: false, assignedTo: SampleUsers.all[0], dueDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date()), category: .booking, amount: 150.0),
            EventTask(id: "t10", title: "Buy drinks & mixers",                    isCompleted: true,  assignedTo: .current, category: .catering, amount: 85.0),
            EventTask(id: "t11", title: "Build the Spotify playlist",             isCompleted: true,  assignedTo: SampleUsers.all[1], category: .entertainment),
            EventTask(id: "t12", title: "Sort entry list at the door",            isCompleted: false, assignedTo: SampleUsers.all[2], category: .admin),
        ]
    )

    static let wedding = Event(
        id: "e7",
        title: "Tom & Emma's Wedding",
        description: "A beautiful summer wedding at Hedsor House. Black tie dress code. We're so excited to celebrate this special day — please check your tasks below and RSVP by June 1st!",
        startDate: Calendar.current.date(byAdding: .day, value: 22, to: Calendar.current.startOfDay(for: Date()))!,
        endDate:   Calendar.current.date(byAdding: .day, value: 22, to: Calendar.current.startOfDay(for: Date()))!,
        allDay: true,
        location: SampleLocations.hedsor,
        assignees: [
            Assignee(id: "a7_0", user: .current,           role: "Guest"),
            Assignee(id: "a7_1", user: SampleUsers.all[0], role: "Best Man"),
            Assignee(id: "a7_2", user: SampleUsers.all[1], role: "Maid of Honour"),
            Assignee(id: "a7_3", user: SampleUsers.all[2], role: "Groom"),
            Assignee(id: "a7_4", user: SampleUsers.all[3], role: "Bride"),
            Assignee(id: "a7_5", user: SampleUsers.all[4], role: "Guest"),
            Assignee(id: "a7_6", user: SampleUsers.all[5], role: "Guest"),
        ],
        preview: EventPreview(
            id: "ep2", eventId: "e7",
            previewTitle: "Ceremony at 2pm sharp",
            previewDescription: "Doors open 1pm. Black tie required. Carriages at midnight. RSVP by June 1st."
        ),
        budget: 8500.0,
        tasks: [
            EventTask(id: "t1", title: "Pay catering deposit (£180 per head)",          description: "Transfer £180 per head via bank transfer — ask Emma for account details.", isCompleted: false, assignedTo: .current,             dueDate: Calendar.current.date(byAdding: .day, value: 2,  to: Date()), category: .payment, amount: 1260.0),
            EventTask(id: "t2", title: "Book group minibus to venue",                    description: "7-seater needed. Pick up from Clapham Junction at 12:30pm.",               isCompleted: false, assignedTo: SampleUsers.all[3],   dueDate: Calendar.current.date(byAdding: .day, value: 5,  to: Date()), category: .transport),
            EventTask(id: "t3", title: "Confirm dietary requirements with all guests",   isCompleted: true,  assignedTo: SampleUsers.all[0], category: .catering),
            EventTask(id: "t4", title: "Arrange floral table centrepieces",              isCompleted: true,  assignedTo: SampleUsers.all[2], category: .admin),
            EventTask(id: "t5", title: "Collect wedding favours from florist",           isCompleted: false, assignedTo: SampleUsers.all[4],   dueDate: Calendar.current.date(byAdding: .day, value: 7,  to: Date()), category: .other),
            EventTask(id: "t6", title: "Finalise evening seating plan",                 isCompleted: false, assignedTo: SampleUsers.all[1], category: .admin),
            EventTask(id: "t7", title: "Coordinate live band & sound check",            isCompleted: true,  assignedTo: SampleUsers.all[5], category: .entertainment),
            EventTask(id: "t8", title: "Send final RSVP count to caterer",              isCompleted: false, assignedTo: .current,             dueDate: Calendar.current.date(byAdding: .day, value: 3,  to: Date()), category: .admin),
        ]
    )

    static let all: [Event] = [
        latest,
        Event(
            id: "e2",
            title: "Sunday Picnic",
            description: "Relaxed afternoon in the park. Bring a dish to share and a blanket!",
            startDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            allDay: false,
            location: SampleLocations.park,
            assignees: [
                Assignee(id: "a2_0", user: SampleUsers.all[0], role: "Organiser"),
                Assignee(id: "a2_1", user: SampleUsers.all[1], role: "Guest"),
                Assignee(id: "a2_2", user: SampleUsers.all[2], role: "Guest"),
                Assignee(id: "a2_3", user: SampleUsers.all[3], role: "Guest"),
            ]
        ),
        Event(
            id: "e3",
            title: "Movie Night",
            description: "Screening of The Godfather at the Everyman. Tickets already sorted — just show up!",
            startDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            allDay: false,
            location: SampleLocations.cinema,
            assignees: [
                Assignee(id: "a3_0", user: SampleUsers.all[0], role: "Guest"),
                Assignee(id: "a3_1", user: SampleUsers.all[1], role: "Guest"),
                Assignee(id: "a3_2", user: SampleUsers.all[2], role: "Guest"),
                Assignee(id: "a3_3", user: SampleUsers.all[3], role: "Guest"),
                Assignee(id: "a3_4", user: SampleUsers.all[4], role: "Guest"),
                Assignee(id: "a3_5", user: SampleUsers.all[5], role: "Guest"),
            ]
        ),
        Event(
            id: "e4",
            title: "Birthday Dinner",
            description: "Celebrating Sarah's birthday at Nobu! RSVP required — book your place ASAP.",
            startDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!,
            allDay: false,
            location: SampleLocations.restaurant,
            assignees: [
                Assignee(id: "a4_0", user: SampleUsers.all[0], role: "Birthday Girl"),
                Assignee(id: "a4_1", user: SampleUsers.all[1], role: "Guest"),
                Assignee(id: "a4_2", user: SampleUsers.all[2], role: "Guest"),
                Assignee(id: "a4_3", user: SampleUsers.all[3], role: "Guest"),
                Assignee(id: "a4_4", user: SampleUsers.all[4], role: "Guest"),
                Assignee(id: "a4_5", user: SampleUsers.all[5], role: "Guest"),
            ]
        ),
        Event(
            id: "e5",
            title: "Team Brainstorm",
            description: "Virtual catch-up — link in the group chat. Bring ideas!",
            startDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
            allDay: false,
            location: nil,
            assignees: [
                Assignee(id: "a5_0", user: SampleUsers.all[0], role: "Lead"),
                Assignee(id: "a5_1", user: SampleUsers.all[1], role: "Member"),
                Assignee(id: "a5_2", user: SampleUsers.all[2], role: "Member"),
            ]
        ),
        Event(
            id: "e6",
            title: "Morning Run",
            description: "5k through Regent's Park. All paces welcome!",
            startDate: Calendar.current.date(byAdding: .day, value: 18, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 18, to: Date())!,
            allDay: false,
            location: SampleLocations.park,
            assignees: [
                Assignee(id: "a6_0", user: SampleUsers.all[0], role: "Organiser"),
                Assignee(id: "a6_1", user: SampleUsers.all[1], role: "Runner"),
            ]
        ),
        wedding,
    ]
}

// MARK: - Sample Friends

enum SampleFriends {
    static let all: [AppFriend] = [
        AppFriend(id: "f1", friendUser: SampleUsers.all[0], status: "accepted"),
        AppFriend(id: "f2", friendUser: SampleUsers.all[1], status: "accepted"),
        AppFriend(id: "f3", friendUser: SampleUsers.all[2], status: "accepted"),
        AppFriend(id: "f4", friendUser: SampleUsers.all[3], status: "pending"),
        AppFriend(id: "f5", friendUser: SampleUsers.all[4], status: "accepted"),
        AppFriend(id: "f6", friendUser: SampleUsers.all[5], status: "pending"),
    ]
}


