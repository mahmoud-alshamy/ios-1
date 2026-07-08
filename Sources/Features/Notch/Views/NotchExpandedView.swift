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

            ActivityContentView(
                activity: vm.currentActivity,
                services: vm.services
            )
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

            Spacer()

            // Activity switcher dots.
            HStack(spacing: 7) {
                ForEach(vm.enabledActivities, id: \.self) { activity in
                    Circle()
                        .fill(activity == vm.currentActivity ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 7, height: 7)
                        .onTapGesture { vm.switchTo(activity) }
                }
            }

            Button(action: { vm.close() }) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
    }
}
