import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - Visual system

enum NaqraColors {
    static let accent = Color(red: 0.84, green: 0.72, blue: 0.48)
    static let background = Color(red: 0.055, green: 0.065, blue: 0.09)
    static let surface = Color(red: 0.105, green: 0.12, blue: 0.16)
    static let surfaceRaised = Color(red: 0.15, green: 0.16, blue: 0.19)
    static let textPrimary = Color(red: 0.96, green: 0.95, blue: 0.92)
    static let textSecondary = Color(red: 0.68, green: 0.69, blue: 0.72)
    static let border = Color.white.opacity(0.09)
}

enum NaqraSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28
}

enum NaqraRadius {
    static let key: CGFloat = 7
    static let card: CGFloat = 20
    static let button: CGFloat = 14
}

struct NaqraBackground: View {
    var body: some View {
        LinearGradient(
            colors: [NaqraColors.background, Color(red: 0.075, green: 0.075, blue: 0.115)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct SettingsCard<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder let content: Content

    init(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: NaqraSpacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(NaqraColors.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(NaqraColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            content
        }
        .padding(NaqraSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: NaqraRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: NaqraRadius.card, style: .continuous)
                .stroke(NaqraColors.border, lineWidth: 1)
        }
    }
}

