import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundColor(.accentColor)

                Text("DynamicWin")
                    .font(.system(size: 24, weight: .bold))

                Text("v1.0.0")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(24)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 12) {
                Text("About")
                    .font(.headline)

                Text("DynamicWin is a native macOS menu bar widget inspired by the iPhone Dynamic Island. It provides quick access to media controls, calendar events, file management, and Bluetooth devices.")
                    .font(.body)
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Credits")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    creditRow(label: "Architecture", value: "MVVM + Combine")
                    creditRow(label: "Built with", value: "SwiftUI, AppKit")
                    creditRow(label: "License", value: "CC BY-SA 4.0")
                    creditRow(label: "Original", value: "DynamicWin (Windows)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: openSourceCode) {
                    Label("View on GitHub", systemImage: "link")
                }

                Button(action: checkForUpdates) {
                    Label("Check for Updates", systemImage: "arrow.clockwise")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
    }

    private func creditRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
        }
    }

    private func openSourceCode() {
        if let url = URL(string: "https://github.com/yourusername/DynamicWin-macOS") {
            NSWorkspace.shared.open(url)
        }
    }

    private func checkForUpdates() {
        Logger.log("Checking for updates", category: "About")
    }
}
