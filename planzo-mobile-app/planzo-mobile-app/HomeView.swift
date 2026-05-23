//
//  HomeView.swift
//  planzo-mobile-app
//

import SwiftUI

// MARK: - Home View

struct HomeView: View {
    var onCreateTap: () -> Void = {}

    @State private var selectedDate: Date = Date()

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default:      return "Good night"
        }
    }

    var body: some View {
        ZStack {
            LinearGradient.appBG.ignoresSafeArea()
            BackgroundBlobs()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    headerSection
                    latestEventSection
                    calendarWidgetSection
                    createEventSection
                    upcomingEventsSection
                    friendsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Header

    private var headerSection: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.planzoSubtext)
                Text(AppUser.current.name)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.planzoText)
            }
            Spacer()
            ZStack(alignment: .bottomTrailing) {
                AvatarView(user: .current, size: 46)
                Circle()
                    .fill(Color.planzoGreen)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
            }
        }
    }

    // MARK: Latest Event

    private var latestEventSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Latest Event")
            NavigationLink(destination: LatestEventView(event: SampleEvents.latest)) {
                LatestEventHeroCard(event: SampleEvents.latest)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Calendar Widget

    private var calendarWidgetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "This Week")
            VStack(spacing: 12) {
                WeekStripView(events: SampleEvents.all, selectedDate: $selectedDate)
                    .padding(.vertical, 4)
                let dayEvents = SampleEvents.all.filter {
                    Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate)
                }
                if dayEvents.isEmpty {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.planzoTertiary)
                        Text("No events on this day")
                            .font(.system(size: 13))
                            .foregroundColor(.planzoTertiary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                } else {
                    ForEach(dayEvents) { event in
                        NavigationLink(destination: LatestEventView(event: event)) {
                            CalendarDayEventRow(event: event)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .glassCard(20)
        }
    }

    // MARK: Create Event

    private var createEventSection: some View {
        Button(action: onCreateTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient.accentGrad)
                        .frame(width: 46, height: 46)
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                .shadow(color: Color.planzoAccent.opacity(0.55), radius: 12, x: 0, y: 6)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Plan Something New")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.planzoText)
                    Text("Create an event with friends")
                        .font(.system(size: 13))
                        .foregroundColor(.planzoSubtext)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.planzoTertiary)
            }
            .padding(16)
            .glassCard(20)
        }
        .buttonStyle(.plain)
    }

    // MARK: Upcoming Events

    private var upcomingEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Upcoming")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(SampleEvents.all) { event in
                        NavigationLink(destination: LatestEventView(event: event)) {
                            UpcomingEventCard(event: event)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
    }

    // MARK: Friends

    private var friendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Your Crew")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(SampleFriends.all.filter(\.isAccepted)) { friend in
                        VStack(spacing: 8) {
                            AvatarView(user: friend.friendUser, size: 54)
                            Text(friend.friendUser.name.components(separatedBy: " ").first ?? "")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.planzoSubtext)
                                .lineLimit(1)
                        }
                    }
                    // Add friend
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.07))
                                .overlay(Circle().stroke(.white.opacity(0.14), lineWidth: 1))
                                .frame(width: 54, height: 54)
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 20))
                                .foregroundStyle(LinearGradient.accentGrad)
                        }
                        Text("Add")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.planzoSubtext)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
    }
}

// MARK: - Latest Event Hero Card

struct LatestEventHeroCard: View {
    let event: Event

    private var timeText: String {
        let f = DateFormatter(); f.timeStyle = .short
        return f.string(from: event.startDate)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient background
            LinearGradient.heroGrad

            // Bottom readability vignette
            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 10) {
                Spacer()

                // Time badge
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill").font(.system(size: 11))
                    Text(timeText).font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white.opacity(0.92))
                .glassPill()

                Text(event.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                if let loc = event.location {
                    HStack(spacing: 5) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.80))
                        Text(loc.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.90))
                            .lineLimit(1)
                    }
                }

                HStack {
                    AssigneesRow(assignees: event.assignees, avatarSize: 30, maxVisible: 4)
                    Spacer()
                    Text("\(event.assignees.count) attending")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.70))
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 230)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.15), lineWidth: 1))
        .shadow(color: Color.planzoAccent.opacity(0.35), radius: 24, x: 0, y: 12)
    }
}

// MARK: - Week Strip

struct WeekStripView: View {
    let events: [Event]
    @Binding var selectedDate: Date

    private var weekDays: [Date] {
        var cal = Calendar.current
        cal.firstWeekday = 2
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let daysFromMonday = (weekday - 2 + 7) % 7
        guard let monday = cal.date(byAdding: .day, value: -daysFromMonday, to: today) else { return [] }
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: monday) }
    }

    private func hasEvent(on date: Date) -> Bool {
        events.contains { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { day in
                WeekDayCell(
                    date: day,
                    isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDate),
                    isToday: Calendar.current.isDateInToday(day),
                    hasEvent: hasEvent(on: day)
                )
                .onTapGesture {
                    withAnimation(.spring(duration: 0.28)) { selectedDate = day }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct WeekDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEvent: Bool

    private var letter: String {
        let f = DateFormatter(); f.dateFormat = "E"
        return String(f.string(from: date).prefix(1))
    }
    private var number: String {
        let f = DateFormatter(); f.dateFormat = "d"
        return f.string(from: date)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(letter)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isSelected ? .white : .planzoTertiary)

            ZStack {
                if isSelected {
                    Circle().fill(LinearGradient.accentGrad).frame(width: 34, height: 34)
                } else if isToday {
                    Circle().fill(.white.opacity(0.10)).frame(width: 34, height: 34)
                }
                Text(number)
                    .font(.system(size: 15, weight: isSelected || isToday ? .bold : .regular))
                    .foregroundColor(
                        isSelected ? .white : isToday ? Color.planzoAccent : .planzoSubtext
                    )
            }

            Circle()
                .fill(hasEvent ? Color.planzoAccentPink : .clear)
                .frame(width: 5, height: 5)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Calendar Day Event Row

struct CalendarDayEventRow: View {
    let event: Event

    private var timeText: String {
        if event.allDay { return "All day" }
        let f = DateFormatter(); f.timeStyle = .short
        return f.string(from: event.startDate)
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(LinearGradient.accentGrad)
                .frame(width: 4, height: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(event.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.planzoText)
                Text(timeText)
                    .font(.system(size: 12))
                    .foregroundColor(.planzoSubtext)
            }
            Spacer()
            AssigneesRow(assignees: event.assignees, avatarSize: 22, maxVisible: 3)
        }
    }
}

// MARK: - Upcoming Event Card

struct UpcomingEventCard: View {
    let event: Event

    private var dayText: String {
        if Calendar.current.isDateInToday(event.startDate) { return "Today" }
        if Calendar.current.isDateInTomorrow(event.startDate) { return "Tomorrow" }
        let f = DateFormatter(); f.dateFormat = "EEE, MMM d"
        return f.string(from: event.startDate)
    }

    private var cardGradient: LinearGradient {
        let g: [LinearGradient] = [.heroGrad, .blueGrad, .greenGrad, .sunsetGrad, .accentGrad]
        return g[abs(event.id.hashValue) % g.count]
    }

    private var eventIcon: String {
        let t = event.title.lowercased()
        if t.contains("party") || t.contains("dinner") || t.contains("birthday") { return "fork.knife" }
        if t.contains("hike") || t.contains("run") || t.contains("walk") { return "figure.hiking" }
        if t.contains("movie") || t.contains("cinema") { return "film.fill" }
        if t.contains("picnic") || t.contains("park") { return "leaf.fill" }
        if t.contains("meeting") || t.contains("team") || t.contains("brainstorm") { return "person.3.fill" }
        return "sparkles"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(cardGradient)
                    .frame(height: 76)
                Image(systemName: eventIcon)
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.88))
            }

            Text(event.title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.planzoText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            if let loc = event.location {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.planzoAccent)
                    Text(loc.city ?? loc.name)
                        .font(.system(size: 11))
                        .foregroundColor(.planzoSubtext)
                        .lineLimit(1)
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 10))
                    .foregroundColor(Color.planzoAccentBlue)
                Text(dayText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.planzoSubtext)
            }

            AssigneesRow(assignees: event.assignees, avatarSize: 20, maxVisible: 3)
        }
        .padding(14)
        .frame(width: 158)
        .glassCard(20)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HomeView()
    }
    .preferredColorScheme(.dark)
}
