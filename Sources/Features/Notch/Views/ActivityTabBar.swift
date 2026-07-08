import SwiftUI

/// Icon-based activity switcher shown inside the notch.
/// Replaces the old anonymous dots: every activity is a recognizable icon,
/// the active one is a white pill, hover brightens, tooltips name each tab.
struct ActivityTabBar: View {
    @ObservedObject var vm: NotchViewModel
    /// Smaller sizing for the hover-peek band.
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 2 : 4) {
            ForEach(vm.enabledActivities, id: \.self) { activity in
                ActivityTabButton(
                    activity: activity,
                    isActive: activity == vm.currentActivity,
                    compact: compact
                ) {
                    vm.switchTo(activity)
                }
            }
        }
        .padding(compact ? 2 : 3)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: compact ? 7 : 9, style: .continuous))
    }
}

private struct ActivityTabButton: View {
    let activity: Activity
    let isActive: Bool
    let compact: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: activity.systemImage)
                .font(.system(size: compact ? 10 : 12, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: compact ? 26 : 32, height: compact ? 18 : 22)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: compact ? 5 : 6, style: .continuous))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(activity.displayName)
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.12), value: isHovered)
    }

    private var iconColor: Color {
        if isActive { return .black }
        return .white.opacity(isHovered ? 0.95 : 0.55)
    }

    private var backgroundColor: Color {
        if isActive { return .white }
        return isHovered ? .white.opacity(0.14) : .clear
    }
}
