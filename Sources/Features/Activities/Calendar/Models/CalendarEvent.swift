import Foundation
import AppKit

struct CalendarEvent: Identifiable {
    let id: UUID = UUID()
    let title: String
    let startDate: Date
    let endDate: Date
    let calendar: String
    let color: NSColor
    let location: String?
    let isAllDay: Bool
    let attendees: [String]

    init(title: String, startDate: Date, endDate: Date, calendar: String, color: NSColor = .systemBlue, location: String? = nil, isAllDay: Bool = false, attendees: [String] = []) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.calendar = calendar
        self.color = color
        self.location = location
        self.isAllDay = isAllDay
        self.attendees = attendees
    }

    var isInProgress: Bool {
        let now = Date()
        return startDate <= now && now <= endDate
    }

    var formattedTime: String {
        if isAllDay { return "All Day" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: startDate)
    }
}
