//
//  CreateEventView.swift
//  planzo-mobile-app
//

import SwiftUI

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
    @State private var allDay: Bool = false
    @State private var locationName: String = ""
    @State private var selectedAssignees: Set<AppUser> = []
    @State private var showAssigneePicker: Bool = false
    @State private var isCreating: Bool = false
    @State private var showSuccess: Bool = false
    @State private var tasks: [EventTask] = []
    @State private var newTaskTitle: String = ""
    @State private var newTaskAmount: String = ""
    @State private var newTaskCategory: TaskCategory = .other
    @State private var budget: String = ""

    private var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack {
            LinearGradient.appBG.ignoresSafeArea()
            BackgroundBlobs().ignoresSafeArea()

            VStack(spacing: 0) {
                // Sheet handle + header
                sheetHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Title
                        FormField(icon: "pencil.and.sparkles", label: "Event Title") {
                            TextField("What are you planning?", text: $title)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.planzoText)
                                .tint(Color.planzoAccent)
                        }

                        // Description
                        FormField(icon: "text.alignleft", label: "Description") {
                            ZStack(alignment: .topLeading) {
                                if description.isEmpty {
                                    Text("Tell people what to expect…")
                                        .font(.system(size: 15))
                                        .foregroundColor(.planzoTertiary)
                                        .allowsHitTesting(false)
                                }
                                TextEditor(text: $description)
                                    .font(.system(size: 15))
                                    .foregroundColor(.planzoText)
                                    .tint(Color.planzoAccent)
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 80)
                            }
                        }

                        // All day toggle
                        HStack {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 9)
                                        .fill(LinearGradient.blueGrad)
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "sun.max.fill")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                }
                                Text("All Day")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.planzoText)
                            }
                            Spacer()
                            Toggle("", isOn: $allDay)
                                .tint(Color.planzoAccent)
                                .labelsHidden()
                        }
                        .padding(14)
                        .glassCard(16)

                        // Start date
                        FormField(icon: "calendar.badge.clock", label: "Start") {
                            if allDay {
                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(Color.planzoAccent)
                                    .colorScheme(.dark)
                            } else {
                                DatePicker("", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(Color.planzoAccent)
                                    .colorScheme(.dark)
                            }
                        }

                        // End date
                        if !allDay {
                            FormField(icon: "clock.badge.checkmark", label: "End") {
                                DatePicker("", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(Color.planzoAccent)
                                    .colorScheme(.dark)
                            }
                        }

                        // Location
                        FormField(icon: "mappin.and.ellipse", label: "Location") {
                            TextField("Add a venue or address", text: $locationName)
                                .font(.system(size: 15))
                                .foregroundColor(.planzoText)
                                .tint(Color.planzoAccent)
                        }

                        // Budget
                        FormField(icon: "dollarsign.circle.fill", label: "Budget") {
                            HStack(spacing: 6) {
                                Text("£")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.planzoTertiary)
                                TextField("0.00", text: $budget)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.planzoText)
                                    .tint(Color.planzoAccent)
                                    .keyboardType(.decimalPad)
                            }
                        }

                        // Assignees
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                HStack(spacing: 10) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 9)
                                            .fill(LinearGradient.accentGrad)
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 13))
                                            .foregroundColor(.white)
                                    }
                                    Text("Invite Friends")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.planzoText)
                                }
                                Spacer()
                                Button {
                                    withAnimation(.spring(duration: 0.3)) {
                                        showAssigneePicker.toggle()
                                    }
                                } label: {
                                    Text(showAssigneePicker ? "Done" : "Select")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(LinearGradient.accentGrad)
                                }
                            }

                            if !selectedAssignees.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(Array(selectedAssignees)) { user in
                                            HStack(spacing: 6) {
                                                AvatarView(user: user, size: 26, showBorder: false)
                                                Text(user.name.components(separatedBy: " ").first ?? "")
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundColor(.planzoText)
                                                Button {
                                                    selectedAssignees.remove(user)
                                                } label: {
                                                    Image(systemName: "xmark")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundColor(.planzoTertiary)
                                                }
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Capsule().fill(Color.primary.opacity(0.07)).overlay(Capsule().stroke(Color.primary.opacity(0.10), lineWidth: 1)))
                                        }
                                    }
                                }
                            }

                            if showAssigneePicker {
                                VStack(spacing: 0) {
                                    ForEach(SampleUsers.all) { user in
                                        let isSelected = selectedAssignees.contains(user)
                                        Button {
                                            withAnimation(.spring(duration: 0.2)) {
                                                if isSelected { selectedAssignees.remove(user) }
                                                else { selectedAssignees.insert(user) }
                                            }
                                        } label: {
                                            HStack(spacing: 12) {
                                                AvatarView(user: user, size: 38)
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(user.name)
                                                        .font(.system(size: 14, weight: .semibold))
                                                        .foregroundColor(.planzoText)
                                                    Text("@\(user.username)")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.planzoSubtext)
                                                }
                                                Spacer()
                                                ZStack {
                                                    Circle()
                                                        .fill(isSelected ? LinearGradient.accentGrad : LinearGradient(colors: [Color.primary.opacity(0.08), Color.primary.opacity(0.08)], startPoint: .leading, endPoint: .trailing))
                                                        .frame(width: 24, height: 24)
                                                    if isSelected {
                                                        Image(systemName: "checkmark")
                                                            .font(.system(size: 11, weight: .bold))
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                                .overlay(Circle().stroke(Color.primary.opacity(0.18), lineWidth: 1))
                                            }
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 14)
                                        }
                                        if user.id != SampleUsers.all.last?.id {
                                            Divider().padding(.horizontal, 14)
                                        }
                                    }
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.ultraThinMaterial)
                                        .overlay(RoundedRectangle(cornerRadius: 14).fill(LinearGradient.cardOverlay))
                                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.primary.opacity(0.10), lineWidth: 1))
                                }
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                                    removal: .scale(scale: 0.95).combined(with: .opacity)
                                ))
                            }
                        }
                        .padding(14)
                        .glassCard(16)

                        // Tasks
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                HStack(spacing: 10) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 9)
                                            .fill(LinearGradient.greenGrad)
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "checklist")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                    }
                                    Text("Tasks")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.planzoText)
                                }
                                Spacer()
                                if !tasks.isEmpty {
                                    Text("\(tasks.count) added")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.planzoSubtext)
                                }
                            }

                            if !tasks.isEmpty {
                                VStack(spacing: 0) {
                                    ForEach(tasks) { task in
                                        HStack(spacing: 10) {
                                            // Category icon
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(task.category.gradient)
                                                    .frame(width: 18, height: 18)
                                                Image(systemName: task.category.icon)
                                                    .font(.system(size: 8, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                            VStack(alignment: .leading, spacing: 1) {
                                                Text(task.title)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.planzoText)
                                                if let amount = task.amount {
                                                    Text("£\(amount, specifier: amount.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.2f")")
                                                        .font(.system(size: 11, weight: .semibold))
                                                        .foregroundStyle(LinearGradient.greenGrad)
                                                }
                                            }
                                            Spacer()
                                            Button {
                                                withAnimation(.spring(duration: 0.2)) {
                                                    tasks.removeAll { $0.id == task.id }
                                                }
                                            } label: {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(.planzoTertiary)
                                            }
                                        }
                                        .padding(.vertical, 10)
                                        if task.id != tasks.last?.id {
                                            Divider()
                                        }
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.97).combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }

                            // Category selector
                            VStack(alignment: .leading, spacing: 6) {
                                let cats = TaskCategory.allCases
                                ForEach([Array(cats.prefix(4)), Array(cats.suffix(3))], id: \.self) { row in
                                    HStack(spacing: 6) {
                                        ForEach(row) { cat in
                                            let isSelected = newTaskCategory == cat
                                            HStack(spacing: 5) {
                                                Image(systemName: cat.icon)
                                                    .font(.system(size: 10, weight: .semibold))
                                                Text(cat.label)
                                                    .font(.system(size: 12, weight: .medium))
                                            }
                                            .foregroundColor(isSelected ? .white : .planzoSubtext)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background {
                                                if isSelected {
                                                    Capsule().fill(cat.gradient)
                                                } else {
                                                    Capsule().fill(Color.primary.opacity(0.07))
                                                        .overlay(Capsule().stroke(Color.primary.opacity(0.10), lineWidth: 1))
                                                }
                                            }
                                            .contentShape(Capsule())
                                            .onTapGesture {
                                                withAnimation(.spring(duration: 0.2)) { newTaskCategory = cat }
                                            }
                                        }
                                        Spacer(minLength: 0)
                                    }
                                }
                            }

                            // Add task input row
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(LinearGradient.greenGrad)
                                TextField("Add a task…", text: $newTaskTitle)
                                    .font(.system(size: 14))
                                    .foregroundColor(.planzoText)
                                    .tint(Color.planzoAccent)
                                    .submitLabel(.done)
                                    .onSubmit { addTask() }
                                HStack(spacing: 3) {
                                    Text("£")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.planzoTertiary)
                                    TextField("0", text: $newTaskAmount)
                                        .font(.system(size: 13))
                                        .foregroundColor(.planzoText)
                                        .tint(Color.planzoAccent)
                                        .keyboardType(.decimalPad)
                                        .frame(width: 48)
                                        .multilineTextAlignment(.trailing)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.primary.opacity(0.07))
                                .clipShape(Capsule())
                                if !newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                                    Button { addTask() } label: {
                                        Text("Add")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(LinearGradient.greenGrad)
                                    }
                                    .transition(.opacity.combined(with: .scale))
                                }
                            }
                            .padding(.vertical, 4)
                            .animation(.spring(duration: 0.2), value: newTaskTitle.isEmpty)
                        }
                        .padding(14)
                        .glassCard(16)
                        .animation(.spring(duration: 0.3), value: tasks.count)

                        // Create button
                        createButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .overlay {
            if showSuccess {
                SuccessOverlay {
                    showSuccess = false
                    dismiss()
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.spring(duration: 0.4), value: showSuccess)
    }

    private func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let parsedAmount = Double(newTaskAmount.trimmingCharacters(in: .whitespaces))
        withAnimation(.spring(duration: 0.2)) {
            tasks.append(EventTask(id: UUID().uuidString, title: trimmed, isCompleted: false, category: newTaskCategory, amount: parsedAmount))
        }
        newTaskTitle = ""
        newTaskAmount = ""
        newTaskCategory = .other
    }

    // MARK: Sheet Header

    private var sheetHeader: some View {
        ZStack {
            HStack {
                Button { dismiss() } label: {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.planzoSubtext)
                }
                Spacer()
            }
            Text("New Event")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.planzoText)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    // MARK: Create Button

    private var createButton: some View {
        Button {
            guard isValid else { return }
            withAnimation { isCreating = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { isCreating = false; showSuccess = true }
            }
        } label: {
            ZStack {
                if isCreating {
                    ProgressView()
                        .tint(.white)
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Create Event")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                isValid
                ? AnyShapeStyle(LinearGradient.accentGrad)
                : AnyShapeStyle(Color.primary.opacity(0.10))
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(
                color: isValid ? Color.planzoAccent.opacity(0.45) : .clear,
                radius: 16, x: 0, y: 8
            )
        }
        .disabled(!isValid || isCreating)
        .animation(.spring(duration: 0.25), value: isValid)
    }
}

// MARK: - Form Field

struct FormField<Content: View>: View {
    let icon: String
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LinearGradient.accentGrad)
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.planzoSubtext)
            }
            content
        }
        .padding(14)
        .glassCard(16)
    }
}

// MARK: - Success Overlay

struct SuccessOverlay: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.60).ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(LinearGradient.accentGrad)
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.planzoAccent.opacity(0.55), radius: 20, x: 0, y: 10)
                    Image(systemName: "checkmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 8) {
                    Text("Event Created!")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.planzoText)
                    Text("Your friends will be notified")
                        .font(.system(size: 15))
                        .foregroundColor(.planzoSubtext)
                }

                Button(action: onDismiss) {
                    Text("Done")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 140, height: 46)
                        .background(LinearGradient.accentGrad)
                        .clipShape(Capsule())
                }
            }
            .padding(32)
            .glassCard(28)
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Preview

#Preview {
    CreateEventView()
        .preferredColorScheme(.dark)
}
