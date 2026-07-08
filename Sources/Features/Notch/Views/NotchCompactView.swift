import SwiftUI

/// Content revealed on the black notch while hovering (the "programmed notch").
/// Left: current activity context. Right: icon tab bar — clicking an icon
/// opens the panel directly on that activity.
struct NotchCompactView: View {
    @ObservedObject var vm: NotchViewModel
    /// Content must clear the physical notch, so it starts below the bezel line.
    var topInset: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            // Left cluster — current activity glyph + label.
            HStack(spacing: 6) {
                Image(systemName: vm.currentActivity.systemImage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)

                Text(vm.currentActivity.displayName)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
            }
            .padding(.leading, 16)

            Spacer(minLength: 12)

            // Right cluster — tap an icon to open that activity immediately.
            ActivityTabBar(vm: vm, compact: true)
                .padding(.trailing, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, topInset)
    }
}
