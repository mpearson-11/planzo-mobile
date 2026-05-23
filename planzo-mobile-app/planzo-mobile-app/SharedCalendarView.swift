//
//  SharedCalendarView.swift
//  planzo-mobile-app
//

import SwiftUI

struct SharedCalendarView: View {
    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var selectedEvent: Event? = nil

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let weekLetters = ["M", "T", "W", "T", "F", "S", "S"]

    private var monthTitle: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: displayedMonth)
    }

    private var calendarDays: [Date?] {
        var cal = Calendar.current
        cal.firstWeekday = 2
        let comps = cal.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        let weekday = cal.component(.weekday, from: firstOfMonth)
        let offset = (weekday - 2 + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: offset)
        for d in 0..<range.count {
            days.append(cal.date(byAdding: .day, value: d, to: firstOfMonth))
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    private var selectedDayEvents: [Event] {
        SampleEvents.all.filter { Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate) }
    }

    private func eventsOn(_ date: Date) -> [Event] {
        SampleEvents.all.filter { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
    }

    var body: some View {
        ZStack {
            LinearGradient.appBG.ignoresSafeArea()
            BackgroundBlobs().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Page header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Shared Calendar")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.planzoText)
                            Text("Tap a day to see events")
                                .font(.system(size: 13))
                                .foregroundColor(.planzoSubtext)
                        }
                        Spacer()
                        Button { } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.primary.opacity(0.07))
                                    .overlay(Circle().stroke(Color.primary.opacity(0.10), lineWidth: 1))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 16))
                                    .foregroundStyle(LinearGradient.accentGrad)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Calendar card
                    VStack(spacing: 0) {
                        // Month navigation
                        HStack {
                            Button { changeMonth(by: -1) } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.planzoSubtext)
                                    .frame(width: 36, height: 36)
                                    .background(Circle().fill(Color.primary.opacity(0.07)))
                            }
                            Spacer()
                            Text(monthTitle)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.planzoText)
                            Spacer()
                            Button { changeMonth(by: 1) } label: {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.planzoSubtext)
                                    .frame(width: 36, height: 36)
                                    .background(Circle().fill(Color.primary.opacity(0.07)))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)

                        Divider()

                        // Day of week header
                        HStack(spacing: 0) {
                            ForEach(weekLetters, id: \.self) { letter in
                                Text(letter)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.planzoTertiary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.vertical, 10)

                        // Calendar grid
                        LazyVGrid(columns: columns, spacing: 0) {
                            ForEach(Array(calendarDays.enumerated()), id: \.offset) { _, date in
                                if let date {
                                    let events = eventsOn(date)
                                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                                    let isToday = Calendar.current.isDateInToday(date)
                                    CalendarDayCell(
                                        date: date,
                                        isSelected: isSelected,
                                        isToday: isToday,
                                        eventCount: events.count
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(duration: 0.28)) { selectedDate = date }
                                    }
                                } else {
                                    Color.clear.frame(height: 52)
                                }
                            }
                        }
                        .padding(.horizontal, 6)
                        .padding(.bottom, 12)
                    }
                    .glassCard(24)
                    .padding(.horizontal, 20)

                    // Selected day events
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: selectedDayTitle)
                            .padding(.horizontal, 20)

                        if selectedDayEvents.isEmpty {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 22))
                                    .foregroundStyle(LinearGradient.accentGrad)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Nothing planned")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.planzoText)
                                    Text("Tap + to add an event on this day")
                                        .font(.system(size: 13))
                                        .foregroundColor(.planzoSubtext)
                                }
                            }
                            .padding(16)
                            .glassCard(18)
                            .padding(.horizontal, 20)
                        } else {
                            ForEach(selectedDayEvents) { event in
                                NavigationLink(destination: LatestEventView(event: event)) {
                                    CalendarEventCard(event: event)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    // All upcoming events
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "All Events")
                            .padding(.horizontal, 20)

                        ForEach(SampleEvents.all) { event in
                            NavigationLink(destination: LatestEventView(event: event)) {
                                CalendarEventCard(event: event)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 120)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var selectedDayTitle: String {
        if Calendar.current.isDateInToday(selectedDate) { return "Today's Events" }
        if Calendar.current.isDateInTomorrow(selectedDate) { return "Tomorrow's Events" }
        let f = DateFormatter(); f.dateFormat = "EEEE, MMM d"
        return f.string(from: selectedDate)
    }

    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) {
            withAnimation(.spring(duration: 0.35)) { displayedMonth = newDate }
        }
    }
}

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let eventCount: Int

    private var dayNumber: String {
        let f = DateFormatter(); f.dateFormat = "d"
        return f.string(from: date)
    }

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient.accentGrad)
                        .frame(width: 34, height: 34)
                } else if isToday {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.primary.opacity(0.10))
                        .frame(width: 34, height: 34)
                }
                Text(dayNumber)
                    .font(.system(size: 14, weight: isSelected || isToday ? .bold : .regular))
                    .foregroundColor(
                        isSelected ? .white : isToday ? Color.planzoAccent : .planzoSubtext
                    )
            }

            // Event dots
            HStack(spacing: 2) {
                ForEach(0..<min(eventCount, 3), id: \.self) { i in
                    Circle()
                        .fill(i == 0 ? Color.planzoAccentPink : (i == 1 ? Color.planzoAccentBlue : Color.planzoGreen))
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 6)
        }
        .frame(height: 52)
    }
}

// MARK: - Calendar Event Card

struct CalendarEventCard: View {
    let event: Event

    private var timeText: String {
        if event.allDay { return "All day" }
        let f = DateFormatter(); f.timeStyle = .short
        return f.string(from: event.startDate)
    }

    private var dateText: String {
        if Calendar.current.isDateInToday(event.startDate) { return "Today" }
        if Calendar.current.isDateInTomorrow(event.startDate) { return "Tomorrow" }
        let f = DateFormatter(); f.dateFormat = "EEE, MMM d"
        return f.string(from: event.startDate)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Color accent bar + icon
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(gradientForEvent(event))
                        .frame(width: 46, height: 46)
                    Image(systemName: iconForEvent(event))
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.90))
                }
                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(event.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.planzoText)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar").font(.system(size: 11))
                            .foregroundColor(Color.planzoAccentBlue)
                        Text(dateText)
                            .font(.system(size: 12))
                            .foregroundColor(.planzoSubtext)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "clock").font(.system(size: 11))
                            .foregroundColor(Color.planzoAccentPink)
                        Text(timeText)
                            .font(.system(size: 12))
                            .foregroundColor(.planzoSubtext)
                    }
                }

                if let loc = event.location {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.fill").font(.system(size: 10))
                            .foregroundColor(Color.planzoAccent)
                        Text(loc.shortAddress)
                            .font(.system(size: 12))
                            .foregroundColor(.planzoSubtext)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                AssigneesRow(assignees: event.assignees, avatarSize: 22, maxVisible: 2)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.planzoTertiary)
            }
        }
        .padding(14)
        .glassCard(18)
    }

    func gradientForEvent(_ event: Event) -> LinearGradient {
        let g: [LinearGradient] = [.heroGrad, .blueGrad, .greenGrad, .sunsetGrad, .accentGrad]
        return g[abs(event.id.hashValue) % g.count]
    }

    func iconForEvent(_ event: Event) -> String {
        let t = event.title.lowercased()
        if t.contains("party") || t.contains("dinner") || t.contains("birthday") { return "fork.knife" }
        if t.contains("hike") || t.contains("run") { return "figure.hiking" }
        if t.contains("movie") || t.contains("cinema") { return "film.fill" }
        if t.contains("picnic") || t.contains("park") { return "leaf.fill" }
        if t.contains("meeting") || t.contains("team") { return "person.3.fill" }
        return "sparkles"
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SharedCalendarView()
    }
}
