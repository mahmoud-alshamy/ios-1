import SwiftUI

struct PanelContentView: View {
    @ObservedObject var viewModel: MenuBarViewModel
    let serviceProvider: ServiceProvider

    var body: some View {
        VStack(spacing: 0) {
            // Header with activity indicator
            HStack {
                Text(viewModel.currentActivity.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                // Activity navigation dots
                HStack(spacing: 4) {
                    ForEach(viewModel.enabledActivities, id: \.self) { activity in
                        Circle()
                            .fill(
                                activity == viewModel.currentActivity ?
                                Color.accentColor : Color.secondary.opacity(0.3)
                            )
                            .frame(width: 6, height: 6)
                            .onTapGesture {
                                viewModel.switchActivity(to: activity)
                            }
                    }
                }
            }
            .padding()
            .background(Color(nsColor: NSColor.controlBackgroundColor))

            Divider()

            // Activity Content Router
            ActivityContentView(
                activity: viewModel.currentActivity,
                services: serviceProvider
            )
            .slideAndFade(true, direction: .top)
            .id(viewModel.currentActivity)

            Divider()

            // Footer with navigation
            HStack {
                Button(action: { viewModel.previousActivity() }) {
                    Image(systemName: "chevron.left")
                        .frame(height: 20)
                }
                .help("Previous activity")

                Spacer()

                Button(action: { viewModel.toggleExpanded() }) {
                    Image(systemName: "xmark")
                        .frame(height: 20)
                }
                .help("Close panel")

                Spacer()

                Button(action: { viewModel.nextActivity() }) {
                    Image(systemName: "chevron.right")
                        .frame(height: 20)
                }
                .help("Next activity")
            }
            .padding()
            .background(Color(nsColor: NSColor.controlBackgroundColor))
        }
        .background(Color(nsColor: NSColor.windowBackgroundColor))
    }
}
