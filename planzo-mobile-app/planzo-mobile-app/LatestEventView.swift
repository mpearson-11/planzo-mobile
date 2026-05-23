//
//  LatestEventView.swift
//  planzo-mobile-app
//

import SwiftUI

struct LatestEventView: View {
    let event: Event
    @State private var tasks: [EventTask]
    @Environment(\..dismiss) private var dismiss

    init(event: Event) {
        self.event = event
        _tasks = State(initialValue: event.tasks)
    }

    private var timeRange: String {
        let f = DateFormatter()
        f.timeStyle = .short
        let start = f.string(from: event.startDate)
        let end = f.string(from: event.endDate)
        return "\(start) – \(end)"
    }

    private var dateText: String {
        if Calendar.current.isDateInToday(event.startDate) { return "Today" }
        if Calendar.current.isDateInTomorrow(event.startDate) { return "Tomorrow" }
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: event.startDate)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient.appBG.ignoresSafeArea()
            BackgroundBlobs().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                    contentSection
                }
                .padding(.bottom, 60)
            }

            // Back button
            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(Circle().fill(.white.opacity(0.08)))
                        .overlay(Circle().stroke(.white.opacity(0.20), lineWidth: 1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 60)
            .padding(.leading, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Hero Section

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient.heroGrad

            LinearGradient(
                colors: [.clear, .black.opacity(0.60)],
                startPoint: .top, endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 12) {
                Spacer()

                HStack(spacing: 8) {
                    TagPill(text: dateText, gradient: LinearGradient(colors: [.white.opacity(0.25), .white.opacity(0.10)], startPoint: .leading, endPoint: .trailing))
                    if event.allDay {
                        TagPill(text: "All Day", gradient: LinearGradient(colors: [.white.opacity(0.25), .white.opacity(0.10)], startPoint: .leading, endPoint: .trailing))
                    }
                }

                Text(event.title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                if let loc = event.location {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 15))
                        Text(loc.name)
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.88))
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 320)
    }

    // MARK: Content Section

    private var contentSection: some View {
        VStack(spacing: 20) {
            // Event Preview
            if let preview = event.preview {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient.sunsetGrad)
                            .frame(width: 42, height: 42)
                        Image(systemName: "megaphone.fill")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(preview.previewTitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.planzoText)
                        if let desc = preview.previewDescription {
                            Text(desc)
                                .font(.system(size: 12))
                                .foregroundColor(.planzoSubtext)
                                .lineLimit(2)
                        }
                    }
                    Spacer()
                }
                .padding(14)
                .glassCard(16)
            }

            // Quick stats row
            HStack(spacing: 12) {
                StatChip(icon: "clock.fill", label: event.allDay ? "All day" : timeRange, gradient: .blueGrad)
                StatChip(icon: "person.2.fill", label: "\(event.assignees.count) attending", gradient: .accentGrad)
                if !tasks.isEmpty {
                    let done = tasks.filter(\.isCompleted).count
                    StatChip(icon: "checklist", label: "\(done)/\(tasks.count) tasks", gradient: .greenGrad)
                } else if event.location != nil {
                    StatChip(icon: "mappin.fill", label: "Has venue", gradient: .greenGrad)
                }
                if let budget = event.budget, budget > 0 {
                    StatChip(icon: "dollarsign.circle.fill", label: "£\(Int(budget))", gradient: .greenGrad)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Description
            if let desc = event.description {
                VStack(alignment: .leading, spacing: 10) {
                    Label("About", systemImage: "text.alignleft")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.planzoSubtext)
                    Text(desc)
                        .font(.system(size: 15))
                        .foregroundColor(.planzoText)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .glassCard(18)
            }

            // Date & Time
            VStack(alignment: .leading, spacing: 14) {
                Label("Date & Time", systemImage: "calendar.badge.clock")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.planzoSubtext)

                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Starts")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.planzoSubtext)
                        Text(dateText)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.planzoText)
                        if !event.allDay {
                            Text(timeRange.components(separatedBy: " – ").first ?? "")
                                .font(.system(size: 13))
                                .foregroundColor(Color.planzoAccentBlue)
                        }
                    }
                    Spacer()
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(width: 1, height: 50)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Ends")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.planzoSubtext)
                        Text(dateText)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.planzoText)
                        if !event.allDay {
                            Text(timeRange.components(separatedBy: " – ").last ?? "")
                                .font(.system(size: 13))
                                .foregroundColor(Color.planzoAccentPink)
                        }
                    }
                }
            }
            .padding(16)
            .glassCard(18)

            // Tasks
            if !tasks.isEmpty {
                tasksSection
            }

            // Location
            if let loc = event.location {
                VStack(alignment: .leading, spacing: 14) {
                    Label("Location", systemImage: "mappin.and.ellipse")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.planzoSubtext)

                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient.heroGrad)
                                .frame(width: 44, height: 44)
                            Image(systemName: "mappin.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(loc.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.planzoText)
                            if !loc.fullAddress.isEmpty {
                                Text(loc.fullAddress)
                                    .font(.system(size: 12))
                                    .foregroundColor(.planzoSubtext)
                                    .lineLimit(2)
                            }
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(LinearGradient.accentGrad)
                    }

                    // Map placeholder
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .frame(height: 120)
                        .overlay {
                            HStack(spacing: 8) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.planzoSubtext)
                                Text("Open in Maps")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.planzoSubtext)
                            }
                        }
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 1))
                }
                .padding(16)
                .glassCard(18)
            }

            // Attendees
            VStack(alignment: .leading, spacing: 14) {
                Label("Attendees", systemImage: "person.2.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.planzoSubtext)

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 16
                ) {
                    ForEach(event.assignees) { assignee in
                        VStack(spacing: 6) {
                            AvatarView(user: assignee.user, size: 48)
                            Text(assignee.user.name.components(separatedBy: " ").first ?? "")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.planzoSubtext)
                                .lineLimit(1)
                            Text(assignee.role)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(LinearGradient.accentGrad)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(16)
            .glassCard(18)

            // Action buttons
            HStack(spacing: 12) {
                Button { } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                        Text("RSVP")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(LinearGradient.accentGrad)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.planzoAccent.opacity(0.45), radius: 12, x: 0, y: 6)
                }

                Button { } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Share")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.planzoText)
                    .frame(width: 110, height: 50)
                    .background(Color.primary.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.10), lineWidth: 1))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    // MARK: Tasks Section

    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            let completedCount = tasks.filter(\.isCompleted).count
            HStack {
                Label("Tasks", systemImage: "checklist")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.planzoSubtext)
                Spacer()
                Text("\(completedCount)/\(tasks.count) done")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(LinearGradient.accentGrad)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 5)
                    Capsule()
                        .fill(LinearGradient.accentGrad)
                        .frame(
                            width: tasks.isEmpty ? 0 : geo.size.width * CGFloat(completedCount) / CGFloat(tasks.count),
                            height: 5
                        )
                        .animation(.spring(duration: 0.45), value: completedCount)
                }
            }
            .frame(height: 5)

            // Task rows
            VStack(spacing: 0) {
                ForEach($tasks) { $task in
                    TaskRow(task: $task)
                    if task.id != tasks.last?.id {
                        Divider()
                            .padding(.leading, 34)
                    }
                }
            }
        }
        .padding(16)
        .glassCard(18)
    }
}

// MARK: - Task Row

private struct TaskRow: View {
    @Binding var task: EventTask

    private var relativeDue: String? {
        guard let due = task.dueDate else { return nil }
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .short
        return f.localizedString(for: due, relativeTo: Date())
    }

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button {
                withAnimation(.spring(duration: 0.3)) { task.isCompleted.toggle() }
            } label: {
                ZStack {
                    if task.isCompleted {
                        Circle()
                            .fill(LinearGradient.accentGrad)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Circle()
                            .stroke(Color.primary.opacity(0.30), lineWidth: 1.5)
                            .frame(width: 22, height: 22)
                    }
                }
            }
            .buttonStyle(.plain)

            // Title, description & due date
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(task.isCompleted ? .planzoTertiary : .planzoText)
                    .strikethrough(task.isCompleted, color: .planzoTertiary)
                    .animation(.easeOut(duration: 0.2), value: task.isCompleted)
                if let desc = task.description, !task.isCompleted {
                    Text(desc)
                        .font(.system(size: 11))
                        .foregroundColor(.planzoTertiary)
                        .lineLimit(2)
                }
                if let amount = task.amount {
                    Text("£\(amount, specifier: amount.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.2f")")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(LinearGradient.greenGrad)
                }
                if let due = relativeDue {
                    Text(due)
                        .font(.system(size: 11))
                        .foregroundColor(.planzoTertiary)
                }
            }

            Spacer()

            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(task.category.gradient)
                    .frame(width: 20, height: 20)
                Image(systemName: task.category.icon)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
            }

            // Assignee avatar
            if let assignee = task.assignedTo {
                AvatarView(user: assignee, size: 28, showBorder: false)
            }
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Stat Chip

private struct StatChip: View {
    let icon: String
    let label: String
    let gradient: LinearGradient

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(gradient)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.planzoText)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background {
            Capsule().fill(Color.primary.opacity(0.07))
                .overlay(Capsule().stroke(Color.primary.opacity(0.09), lineWidth: 1))
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LatestEventView(event: SampleEvents.latest)
    }
}
