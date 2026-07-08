import Foundation

enum Activity: String, Codable, Hashable, CaseIterable {
    case media, calendar, fileTray, bluetooth

    var displayName: String {
        switch self {
        case .media: return "Media"
        case .calendar: return "Calendar"
        case .fileTray: return "File Tray"
        case .bluetooth: return "Bluetooth"
        }
    }

    var systemImage: String {
        switch self {
        case .media: return "music.note"
        case .calendar: return "calendar"
        case .fileTray: return "tray"
        case .bluetooth: return "airplayaudio"
        }
    }
}
