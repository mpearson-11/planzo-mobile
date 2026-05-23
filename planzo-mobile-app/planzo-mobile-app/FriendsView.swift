//
//  FriendsView.swift
//  planzo-mobile-app
//

import SwiftUI

struct FriendsView: View {
    @State private var searchText: String = ""
    @State private var friends: [AppFriend] = SampleFriends.all
    @State private var showAddFriend: Bool = false

    private var pending: [AppFriend] { friends.filter(\.isPending) }
    private var accepted: [AppFriend] {
        let list = friends.filter(\.isAccepted)
        guard !searchText.isEmpty else { return list }
        return list.filter {
            $0.friendUser.name.localizedCaseInsensitiveContains(searchText) ||
            $0.friendUser.username.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            LinearGradient.appBG.ignoresSafeArea()
            BackgroundBlobs().ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Friends")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.planzoText)
                            Text("\(friends.filter(\.isAccepted).count) connections")
                                .font(.system(size: 13))
                                .foregroundColor(.planzoSubtext)
                        }
                        Spacer()
                        Button { showAddFriend = true } label: {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient.accentGrad)
                                    .frame(width: 42, height: 42)
                                    .shadow(color: Color.planzoAccent.opacity(0.50), radius: 10, x: 0, y: 5)
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 17))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15))
                            .foregroundColor(.planzoTertiary)
                        TextField("Search friends…", text: $searchText)
                            .font(.system(size: 15))
                            .foregroundColor(.planzoText)
                            .tint(Color.planzoAccent)
                        if !searchText.isEmpty {
                            Button { searchText = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(.planzoTertiary)
                            }
                        }
                    }
                    .padding(12)
                    .glassCard(14, shadow: false)
                    .padding(.horizontal, 20)

                    // Pending requests
                    if !pending.isEmpty && searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Pending Requests")
                                .padding(.horizontal, 20)

                            VStack(spacing: 10) {
                                ForEach(pending) { friend in
                                    PendingFriendCard(
                                        friend: friend,
                                        onAccept: { accept(friend) },
                                        onDecline: { decline(friend) }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // Friends list
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: searchText.isEmpty ? "Your Friends" : "Results")
                            .padding(.horizontal, 20)

                        if accepted.isEmpty {
                            emptyState
                        } else {
                            VStack(spacing: 0) {
                                ForEach(accepted) { friend in
                                    FriendRow(friend: friend)
                                    if friend.id != accepted.last?.id {
                                        Divider()
                                            .padding(.horizontal, 14)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            .glassCard(20)
                            .padding(.horizontal, 20)
                        }
                    }

                    // Stats section
                    if searchText.isEmpty {
                        statsSection
                    }
                }
                .padding(.bottom, 120)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showAddFriend) {
            AddFriendSheet()
        }
    }

    // MARK: Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 40))
                .foregroundStyle(LinearGradient.accentGrad)
            Text(searchText.isEmpty ? "No friends yet" : "No results found")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.planzoText)
            Text(searchText.isEmpty ? "Add friends to plan events together" : "Try a different name")
                .font(.system(size: 13))
                .foregroundColor(.planzoSubtext)
                .multilineTextAlignment(.center)
            if searchText.isEmpty {
                Button { showAddFriend = true } label: {
                    Text("Add Friends")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(LinearGradient.accentGrad)
                        .clipShape(Capsule())
                        .shadow(color: Color.planzoAccent.opacity(0.45), radius: 10, x: 0, y: 5)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .glassCard(20)
        .padding(.horizontal, 20)
    }

    // MARK: Stats Section

    private var statsSection: some View {
        HStack(spacing: 12) {
            FriendStatCard(value: "\(friends.filter(\.isAccepted).count)", label: "Friends", gradient: .accentGrad)
            FriendStatCard(value: "\(SampleEvents.all.count)", label: "Shared Events", gradient: .blueGrad)
            FriendStatCard(value: "\(pending.count)", label: "Pending", gradient: .sunsetGrad)
        }
        .padding(.horizontal, 20)
    }

    // MARK: Actions

    private func accept(_ friend: AppFriend) {
        withAnimation(.spring(duration: 0.35)) {
            if let idx = friends.firstIndex(where: { $0.id == friend.id }) {
                friends[idx] = AppFriend(id: friend.id, friendUser: friend.friendUser, status: "accepted")
            }
        }
    }

    private func decline(_ friend: AppFriend) {
        withAnimation(.spring(duration: 0.35)) {
            friends.removeAll { $0.id == friend.id }
        }
    }
}

// MARK: - Friend Row

struct FriendRow: View {
    let friend: AppFriend

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(user: friend.friendUser, size: 46)

            VStack(alignment: .leading, spacing: 3) {
                Text(friend.friendUser.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.planzoText)
                Text("@\(friend.friendUser.username)")
                    .font(.system(size: 12))
                    .foregroundColor(.planzoSubtext)
            }

            Spacer()

            Button { } label: {
                Text("Plan")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(LinearGradient.accentGrad)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color.planzoAccent.opacity(0.14)).overlay(Capsule().stroke(Color.planzoAccent.opacity(0.28), lineWidth: 1)))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

// MARK: - Pending Friend Card

struct PendingFriendCard: View {
    let friend: AppFriend
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(user: friend.friendUser, size: 46)

            VStack(alignment: .leading, spacing: 3) {
                Text(friend.friendUser.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.planzoText)
                Text("Wants to be your friend")
                    .font(.system(size: 12))
                    .foregroundColor(.planzoSubtext)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onDecline) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.planzoSubtext)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.primary.opacity(0.07)).overlay(Circle().stroke(Color.primary.opacity(0.10), lineWidth: 1)))
                }

                Button(action: onAccept) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(LinearGradient.accentGrad))
                        .shadow(color: Color.planzoAccent.opacity(0.40), radius: 8, x: 0, y: 4)
                }
            }
        }
        .padding(14)
        .glassCard(18)
        .overlay(alignment: .topLeading) {
            Capsule()
                .fill(LinearGradient.sunsetGrad)
                .frame(width: 60, height: 6)
                .offset(x: 14, y: -3)
        }
    }
}

// MARK: - Friend Stat Card

struct FriendStatCard: View {
    let value: String
    let label: String
    let gradient: LinearGradient

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(gradient)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.planzoSubtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard(16, shadow: false)
    }
}

// MARK: - Add Friend Sheet

struct AddFriendSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""

    var body: some View {
        ZStack {
            LinearGradient.appBG.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ZStack {
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            ZStack {
                                Circle().fill(Color.primary.opacity(0.08))
                                    .overlay(Circle().stroke(Color.primary.opacity(0.10), lineWidth: 1))
                                    .frame(width: 34, height: 34)
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.planzoText)
                            }
                        }
                    }
                    Text("Add Friends")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.planzoText)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                Divider()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Search
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 15))
                                .foregroundColor(.planzoTertiary)
                            TextField("Search by name or username…", text: $searchText)
                                .font(.system(size: 15))
                                .foregroundColor(.planzoText)
                                .tint(Color.planzoAccent)
                        }
                        .padding(12)
                        .glassCard(14, shadow: false)

                        // Suggestions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Suggestions")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.planzoSubtext)

                            VStack(spacing: 0) {
                                ForEach(SampleUsers.all) { user in
                                    AddFriendRow(user: user)
                                    if user.id != SampleUsers.all.last?.id {
                                        Divider().padding(.horizontal, 14)
                                    }
                                }
                            }
                            .glassCard(20)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct AddFriendRow: View {
    let user: AppUser
    @State private var sent: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(user: user, size: 44)
            VStack(alignment: .leading, spacing: 3) {
                Text(user.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.planzoText)
                Text("@\(user.username)")
                    .font(.system(size: 12))
                    .foregroundColor(.planzoSubtext)
            }
            Spacer()
            Button {
                withAnimation(.spring(duration: 0.3)) { sent = true }
            } label: {
                Text(sent ? "Sent ✓" : "Add")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(sent ? .planzoSubtext : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        sent
                        ? AnyShapeStyle(Color.primary.opacity(0.08))
                        : AnyShapeStyle(LinearGradient.accentGrad),
                        in: Capsule()
                    )
                    .shadow(color: sent ? .clear : Color.planzoAccent.opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .disabled(sent)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FriendsView()
    }
}
