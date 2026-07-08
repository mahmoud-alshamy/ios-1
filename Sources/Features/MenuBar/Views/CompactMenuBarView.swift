import SwiftUI

struct CompactMenuBarView: View {
    @ObservedObject var viewModel: MenuBarViewModel
    var size: CGFloat = 22

    var body: some View {
        HStack(spacing: 6) {
            // App Icon
            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.system(size: size))
                .foregroundColor(.primary)

            // Activity Indicator Dots
            HStack(spacing: 4) {
                ForEach(viewModel.enabledActivities, id: \.self) { activity in
                    Circle()
                        .fill(activity == viewModel.currentActivity ? Color.accentColor : Color.secondary)
                        .frame(width: 4, height: 4)
                        .opacity(activity == viewModel.currentActivity ? 1 : 0.4)
                }
            }
        }
        .frame(width: AppConstants.MenuBar.compactWidth, height: size)
    }
}
