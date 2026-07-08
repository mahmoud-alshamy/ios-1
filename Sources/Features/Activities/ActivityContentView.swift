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
                CalendarExpandedView(
                    viewModel: CalendarViewModel(service: services.calendarService)
                )

            case .fileTray:
                FileTrayExpandedView(
                    viewModel: FileTrayViewModel(service: services.fileTrayService)
                )

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
