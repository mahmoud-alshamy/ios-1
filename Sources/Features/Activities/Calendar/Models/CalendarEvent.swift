import Foundation
import AppKit

struct CalendarEvent: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let calendar: String
    let color: NSColor
    let location: String?
    let isAllDay: Bool
    let attendees: [String]

    init(id: String = UUID().uuidString, title: String, startDate: Date, endDate: Date, calendar: String, color: NSColor? = nil, location: String? = nil, isAllDay: Bool = false, attendees: [String] = []) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.calendar = calendar
        self.color = color ?? .systemBlue
        self.location = location
        self.isAllDay = isAllDay
        self.attendees = attendees
    }

    init(id: String = UUID().uuidString, title: String, startDate: Date, endDate: Date, calendar: String, calendarColor: CGColor?, location: String? = nil, isAllDay: Bool = false, attendees: [String] = []) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.calendar = calendar
        if let cgColor = calendarColor {
            self.color = NSColor(cgColor: cgColor) ?? .systemBlue
        } else {
            self.color = .systemBlue
        }
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
