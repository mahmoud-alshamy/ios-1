import Foundation
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var todayEvents: [CalendarEvent] = []
    @Published var upcomingEvents: [CalendarEvent] = []
    @Published var isLoading: Bool = false
    @Published var error: String?

    private let service: CalendarService
    private var cancellables = Set<AnyCancellable>()

    init(service: CalendarService) {
        self.service = service
        setupBindings()
    }

    private func setupBindings() {
        service.$todayEvents
            .receive(on: DispatchQueue.main)
            .assign(to: &$todayEvents)

        service.$upcomingEvents
            .receive(on: DispatchQueue.main)
            .assign(to: &$upcomingEvents)

        service.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)

        service.$error
            .receive(on: DispatchQueue.main)
            .map { $0?.localizedDescription }
            .assign(to: &$error)
    }

    var nextEvent: CalendarEvent? {
        todayEvents.first(where: { $0.startDate > Date() }) ?? upcomingEvents.first
    }

    var currentEvent: CalendarEvent? {
        todayEvents.first(where: { $0.isInProgress })
    }

    var allEvents: [CalendarEvent] {
        (todayEvents + upcomingEvents).sorted { $0.startDate < $1.startDate }
    }
}
