import Foundation
import EventKit
import Combine

class CalendarService: BackgroundService {
    @Published var upcomingEvents: [CalendarEvent] = []
    @Published var todayEvents: [CalendarEvent] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?

    private let eventStore = EKEventStore()
    private var updateTimer: Timer?
    private let updateInterval: TimeInterval = 60.0

    init() {
        Logger.log("CalendarService initialized", category: "CalendarService")
    }

    func start() {
        Logger.log("CalendarService started", category: "CalendarService")
        requestCalendarAccess()
        DispatchQueue.main.async {
            self.fetchEvents()
        }
        startPeriodicUpdates()
    }

    func stop() {
        Logger.log("CalendarService stopped", category: "CalendarService")
        updateTimer?.invalidate()
        updateTimer = nil
    }

    private func requestCalendarAccess() {
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                if granted {
                    Logger.log("Calendar access granted", category: "CalendarService")
                } else if let error = error {
                    Logger.log("Calendar access denied: \(error)", level: .error, category: "CalendarService")
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                if granted {
                    Logger.log("Calendar access granted", category: "CalendarService")
                } else if let error = error {
                    Logger.log("Calendar access denied: \(error)", level: .error, category: "CalendarService")
                }
            }
        }
    }

    private func fetchEvents() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = true
            }

            let calendar = Calendar.current
            let now = Date()
            let today = calendar.startOfDay(for: now)
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
            let sevenDaysLater = calendar.date(byAdding: .day, value: 7, to: today) ?? today

            let todayPredicate = self.eventStore.predicateForEvents(
                withStart: today,
                end: tomorrow,
                calendars: nil
            )

            let upcomingPredicate = self.eventStore.predicateForEvents(
                withStart: now,
                end: sevenDaysLater,
                calendars: nil
            )

            let todayEKEvents = self.eventStore.events(matching: todayPredicate)
            let allUpcomingEKEvents = self.eventStore.events(matching: upcomingPredicate)

            let todayEvents = todayEKEvents.map { self.convertEKEvent($0) }
            let upcomingEvents = allUpcomingEKEvents.map { self.convertEKEvent($0) }

            DispatchQueue.main.async {
                self.todayEvents = todayEvents.sorted { $0.startDate < $1.startDate }
                self.upcomingEvents = upcomingEvents.sorted { $0.startDate < $1.startDate }
                self.isLoading = false
            }
        }
    }

    private func convertEKEvent(_ ekEvent: EKEvent) -> CalendarEvent {
        CalendarEvent(
            id: ekEvent.eventIdentifier ?? UUID().uuidString,
            title: ekEvent.title ?? "Untitled Event",
            startDate: ekEvent.startDate ?? Date(),
            endDate: ekEvent.endDate ?? Date(),
            calendar: ekEvent.calendar?.title ?? "Calendar",
            calendarColor: ekEvent.calendar?.cgColor ?? nil,
            location: ekEvent.location,
            isAllDay: ekEvent.isAllDay,
            attendees: ekEvent.attendees?.map { $0.name ?? "Unknown" } ?? []
        )
    }

    private func startPeriodicUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.fetchEvents()
        }
    }
}
