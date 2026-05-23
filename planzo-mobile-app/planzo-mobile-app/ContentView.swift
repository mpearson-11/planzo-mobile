//
//  ContentView.swift
//  planzo-mobile-app
//
//  Created by Max Pearson on 23/05/2026.
//

import SwiftUI

// MARK: - Root Content View

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var showCreateEvent: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // TabView preserves each tab's NavigationStack state and has no
            // zombie-overlay or coordinate-space issues unlike the custom switch approach.
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView(onCreateTap: { showCreateEvent = true })
                }
                .toolbar(.hidden, for: .tabBar)
                .tag(0)

                NavigationStack {
                    SharedCalendarView()
                }
                .toolbar(.hidden, for: .tabBar)
                .tag(1)

                NavigationStack {
                    FriendsView()
                }
                .toolbar(.hidden, for: .tabBar)
                .tag(2)
            }

            // Floating glass tab bar overlaid on top
            GlassTabBar(selectedTab: $selectedTab) {
                showCreateEvent = true
            }
        }
        // Do NOT ignoresSafeArea here — GlassTabBar's own background handles
        // safe-area extension. Ignoring it on the ZStack pushed the bar below
        // the home indicator into the system gesture area.
        .preferredColorScheme(.light)
        .sheet(isPresented: $showCreateEvent) {
            CreateEventView()
        }
    }
}

// MARK: - Glass Tab Bar

struct GlassTabBar: View {
    @Binding var selectedTab: Int
    let onCreateTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(icon: "house.fill",    label: "Home",     isSelected: selectedTab == 0) { selectedTab = 0 }
            TabBarItem(icon: "calendar",      label: "Calendar", isSelected: selectedTab == 1) { selectedTab = 1 }

            // Center create button
            Button(action: onCreateTap) {
                ZStack {
                    Circle()
                        .fill(LinearGradient.accentGrad)
                        .frame(width: 54, height: 54)
                        .shadow(color: Color.planzoAccent.opacity(0.55), radius: 16, x: 0, y: 6)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -14)
            .frame(maxWidth: .infinity)

            TabBarItem(icon: "person.2.fill", label: "Friends",  isSelected: selectedTab == 2) { selectedTab = 2 }
            // Non-interactive balance spacer — allowsHitTesting(false) prevents
            // this invisible area from absorbing taps
            Spacer()
                .frame(maxWidth: .infinity)
                .allowsHitTesting(false)
        }
        .padding(.horizontal, 10)
        .padding(.top, 14)
        .padding(.bottom, 6)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(height: 0.5)
                }
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.spring(duration: 0.28)) { action() }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(
                        isSelected
                        ? AnyShapeStyle(LinearGradient.accentGrad)
                        : AnyShapeStyle(Color(.secondaryLabel))
                    )
                    .scaleEffect(isSelected ? 1.10 : 1.0)
                    .animation(.spring(duration: 0.28), value: isSelected)

                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isSelected ? Color.planzoAccent : Color(.secondaryLabel))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
