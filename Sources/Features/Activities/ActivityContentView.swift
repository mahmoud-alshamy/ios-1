import SwiftUI

struct ActivityContentView: View {
    let activity: Activity
    let services: ServiceProvider

    var body: some View {
        Group {
            switch activity {
            case .media:
                MediaExpandedView(
                    viewModel: MediaViewModel(service: services.mediaService)
                )

            case .calendar:
                VStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("Calendar")
                        .font(.headline)
                    Text("Phase 4: Coming Soon")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .fileTray:
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("File Tray")
                        .font(.headline)
                    Text("Phase 6: Coming Soon")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .bluetooth:
                VStack(spacing: 12) {
                    Image(systemName: "airplayaudio")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("Bluetooth")
                        .font(.headline)
                    Text("Phase 7: Coming Soon")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
