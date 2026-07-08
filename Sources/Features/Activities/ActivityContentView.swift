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
                BluetoothExpandedView(
                    viewModel: BluetoothViewModel(service: services.bluetoothService)
                )
            }
        }
    }
}
