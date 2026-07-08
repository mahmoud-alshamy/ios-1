import SwiftUI

/// Content revealed on the black notch while hovering (the "programmed notch").
/// Splits into left/right clusters with a gap in the middle for the camera.
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

            Spacer(minLength: 14)

            // Right cluster — activity indicator dots.
            HStack(spacing: 5) {
                ForEach(vm.enabledActivities, id: \.self) { activity in
                    Circle()
                        .fill(activity == vm.currentActivity ? Color.white : Color.white.opacity(0.35))
                        .frame(width: 5, height: 5)
                }
            }
            .padding(.trailing, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, topInset)
    }
}
