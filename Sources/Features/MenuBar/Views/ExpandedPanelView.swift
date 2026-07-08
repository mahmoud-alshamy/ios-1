import SwiftUI

struct ExpandedPanelView: View {
    @Environment(\.serviceProvider) var serviceProvider

    var body: some View {
        VStack(spacing: 0) {
            Text("DynamicWin")
                .font(.headline)
                .padding()

            Divider()

            VStack(spacing: 12) {
                Text("Phase 1: Setup Complete ✓")
                    .font(.body)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Infrastructure:")
                        .font(.caption)
                        .fontWeight(.semibold)

                    Label("Logger system", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)

                    Label("Service provider", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)

                    Label("Preferences manager", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)

                    Label("App coordinator", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .padding(.horizontal)
            }
            .padding()

            Spacer()

            Divider()

            Button(action: { NSApplication.shared.terminate(nil) }) {
                Label("Quit", systemImage: "power")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.small)
            .padding()
        }
        .frame(width: 300, height: 250)
        .background(Color(nsColor: NSColor.controlBackgroundColor))
    }
}

#Preview {
    ExpandedPanelView()
        .environment(\.serviceProvider, DefaultServiceProvider())
}
