//
//  DesignSystem.swift
//  planzo-mobile-app
//

import SwiftUI

// MARK: - Brand Colors

extension Color {
    static let planzoAccent      = Color(red: 0.48, green: 0.25, blue: 1.00)
    static let planzoAccentPink  = Color(red: 1.00, green: 0.24, blue: 0.60)
    static let planzoAccentBlue  = Color(red: 0.24, green: 0.73, blue: 1.00)
    static let planzoGreen       = Color(red: 0.15, green: 0.95, blue: 0.65)
    static let planzoText        = Color(.label)
    static let planzoSubtext     = Color(.secondaryLabel)
    static let planzoTertiary    = Color(.tertiaryLabel)
}

// MARK: - Gradient Palette

extension LinearGradient {
    static let appBG = LinearGradient(
        colors: [
            Color(red: 0.96, green: 0.93, blue: 1.00),
            Color(red: 0.91, green: 0.88, blue: 1.00),
            Color(red: 0.93, green: 0.95, blue: 1.00),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGrad = LinearGradient(
        colors: [Color.planzoAccent, Color.planzoAccentPink],
        startPoint: .leading, endPoint: .trailing
    )

    static let heroGrad = LinearGradient(
        colors: [
            Color(red: 0.48, green: 0.25, blue: 1.00),
            Color(red: 0.76, green: 0.18, blue: 0.85),
            Color(red: 1.00, green: 0.24, blue: 0.60),
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let blueGrad = LinearGradient(
        colors: [Color.planzoAccentBlue, Color.planzoAccent],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let greenGrad = LinearGradient(
        colors: [Color.planzoGreen, Color.planzoAccentBlue],
        startPoint: .leading, endPoint: .trailing
    )

    static let sunsetGrad = LinearGradient(
        colors: [Color(red: 1.0, green: 0.60, blue: 0.20), Color(red: 1.0, green: 0.28, blue: 0.60)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let cardOverlay = LinearGradient(
        colors: [Color.white.opacity(0.12), Color.white.opacity(0.03)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

// MARK: - Glass Card Modifier

struct GlassCardMod: ViewModifier {
    var r: CGFloat = 20
    var showShadow: Bool = true

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: r)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: r)
                            .fill(LinearGradient.cardOverlay)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: r)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: r))
            .shadow(
                color: Color.primary.opacity(showShadow ? 0.07 : 0),
                radius: 14, x: 0, y: 4
            )
    }
}

extension View {
    func glassCard(_ r: CGFloat = 20, shadow: Bool = true) -> some View {
        modifier(GlassCardMod(r: r, showShadow: shadow))
    }

    func glassPill() -> some View {
        self
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay { Capsule().fill(.white.opacity(0.08)) }
                    .overlay { Capsule().stroke(.white.opacity(0.22), lineWidth: 1) }
            }
    }
}

// MARK: - Avatar View

struct AvatarView: View {
    let user: AppUser
    let size: CGFloat
    var showBorder: Bool = true

    private var initials: String {
        let parts = user.name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1)) + String(parts[1].prefix(1))
        }
        return String(user.name.prefix(2)).uppercased()
    }

    private var avatarGradient: LinearGradient {
        let palettes: [LinearGradient] = [
            .accentGrad,
            .blueGrad,
            .sunsetGrad,
            .greenGrad,
            LinearGradient(colors: [Color(red: 1.0, green: 0.85, blue: 0.1), Color(red: 1.0, green: 0.5, blue: 0.15)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [Color(red: 0.80, green: 0.20, blue: 1.0), Color(red: 0.40, green: 0.20, blue: 1.0)], startPoint: .topLeading, endPoint: .bottomTrailing),
        ]
        return palettes[abs(user.id.hashValue) % palettes.count]
    }

    var body: some View {
        ZStack {
            Circle().fill(avatarGradient)
            Text(initials)
                .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .overlay {
            if showBorder {
                Circle().stroke(.white.opacity(0.28), lineWidth: 1.5)
            }
        }
    }
}

// MARK: - Assignees Row

struct AssigneesRow: View {
    let assignees: [Assignee]
    var avatarSize: CGFloat = 28
    var maxVisible: Int = 4

    private var visible: [Assignee] { Array(assignees.prefix(maxVisible)) }
    private var overflow: Int { max(0, assignees.count - maxVisible) }

    var body: some View {
        HStack(spacing: -(avatarSize * 0.28)) {
            ForEach(Array(visible.enumerated()), id: \.offset) { index, assignee in
                AvatarView(user: assignee.user, size: avatarSize)
                    .zIndex(Double(visible.count - index))
            }
            if overflow > 0 {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.14))
                        .overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 1.5))
                    Text("+\(overflow)")
                        .font(.system(size: avatarSize * 0.30, weight: .semibold))
                        .foregroundColor(.planzoSubtext)
                }
                .frame(width: avatarSize, height: avatarSize)
            }
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.planzoText)
            Spacer()
            if let actionTitle {
                Button { action?() } label: {
                    Text(actionTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(LinearGradient.accentGrad)
                }
            }
        }
    }
}

// MARK: - Tag Pill

struct TagPill: View {
    let text: String
    var gradient: LinearGradient = .accentGrad

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(gradient).opacity(0.85))
    }
}

// MARK: - Background Blobs

struct BackgroundBlobs: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.planzoAccent.opacity(0.28))
                .frame(width: 380, height: 380)
                .blur(radius: 90)
                .offset(x: -100, y: -80)

            Circle()
                .fill(Color.planzoAccentPink.opacity(0.20))
                .frame(width: 300, height: 300)
                .blur(radius: 75)
                .offset(x: 160, y: 180)

            Circle()
                .fill(Color.planzoAccentBlue.opacity(0.18))
                .frame(width: 240, height: 240)
                .blur(radius: 65)
                .offset(x: -60, y: 400)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - TaskCategory Gradient

extension TaskCategory {
    var gradient: LinearGradient {
        switch self {
        case .payment:       return .greenGrad
        case .transport:     return .blueGrad
        case .booking:       return .accentGrad
        case .catering:      return .sunsetGrad
        case .admin:         return .blueGrad
        case .entertainment: return .heroGrad
        case .other:         return LinearGradient(colors: [.white.opacity(0.22), .white.opacity(0.12)], startPoint: .leading, endPoint: .trailing)
        }
    }
}
