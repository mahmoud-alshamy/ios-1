import SwiftUI

/// Content rendered when the notch is opened into a full panel.
struct NotchExpandedView: View {
    @ObservedObject var vm: NotchViewModel
    /// Header must clear the physical notch, so it starts below the bezel line.
    var topInset: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, max(8, topInset - 4))
                .padding(.bottom, 8)

            // Activity content with a soft transition on switch.
            ZStack {
                ActivityContentView(
                    activity: vm.currentActivity,
                    services: vm.services
                )
                .id(vm.currentActivity)
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .offset(y: 8)),
                        removal: .opacity
                    )
                )
            }
            .animation(.easeOut(duration: 0.18), value: vm.currentActivity)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.horizontal, 12)
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: vm.currentActivity.systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)

            Text(vm.currentActivity.displayName)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .id(vm.currentActivity)

            Spacer()

            // Icon-based activity switcher (replaces the old anonymous dots).
            ActivityTabBar(vm: vm)

            CloseButton { vm.close() }
        }
    }
}

/// Small circular close affordance with a hover state.
private struct CloseButton: View {
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.up")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(isHovered ? 1.0 : 0.6))
                .frame(width: 24, height: 24)
                .background(isHovered ? Color.white.opacity(0.14) : .clear)
                .clipShape(Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .help("Close")
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.12), value: isHovered)
    }
}
