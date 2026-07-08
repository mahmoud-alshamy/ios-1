import Foundation

struct AppPreferences: Codable {
    var enabledActivities: Set<Activity> = [.media, .calendar, .fileTray, .bluetooth]
    var autoLaunchOnStartup: Bool = false
    var startMinimized: Bool = true
    var globalHotkey: KeyCombo?
    var theme: Theme = .auto
    var calendarRefreshInterval: TimeInterval = 30
    var bluetoothRefreshInterval: TimeInterval = 10
    var mediaRefreshInterval: TimeInterval = 2
    var maxFileTrayItems: Int = 50
    var appVersion: String = "1.0.0"
    var lastLaunchDate: Date?

    enum CodingKeys: String, CodingKey {
        case enabledActivities, autoLaunchOnStartup, startMinimized, globalHotkey, theme
        case calendarRefreshInterval, bluetoothRefreshInterval, mediaRefreshInterval
        case maxFileTrayItems, appVersion, lastLaunchDate
    }

    init() {}

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Array(enabledActivities), forKey: .enabledActivities)
        try container.encode(autoLaunchOnStartup, forKey: .autoLaunchOnStartup)
        try container.encode(startMinimized, forKey: .startMinimized)
        try container.encode(globalHotkey, forKey: .globalHotkey)
        try container.encode(theme, forKey: .theme)
        try container.encode(calendarRefreshInterval, forKey: .calendarRefreshInterval)
        try container.encode(bluetoothRefreshInterval, forKey: .bluetoothRefreshInterval)
        try container.encode(mediaRefreshInterval, forKey: .mediaRefreshInterval)
        try container.encode(maxFileTrayItems, forKey: .maxFileTrayItems)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(lastLaunchDate, forKey: .lastLaunchDate)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let activities = try container.decode([Activity].self, forKey: .enabledActivities)
        self.enabledActivities = Set(activities)
        self.autoLaunchOnStartup = try container.decode(Bool.self, forKey: .autoLaunchOnStartup)
        self.startMinimized = try container.decode(Bool.self, forKey: .startMinimized)
        self.globalHotkey = try container.decodeIfPresent(KeyCombo.self, forKey: .globalHotkey)
        self.theme = try container.decode(Theme.self, forKey: .theme)
        self.calendarRefreshInterval = try container.decode(TimeInterval.self, forKey: .calendarRefreshInterval)
        self.bluetoothRefreshInterval = try container.decode(TimeInterval.self, forKey: .bluetoothRefreshInterval)
        self.mediaRefreshInterval = try container.decode(TimeInterval.self, forKey: .mediaRefreshInterval)
        self.maxFileTrayItems = try container.decode(Int.self, forKey: .maxFileTrayItems)
        self.appVersion = try container.decode(String.self, forKey: .appVersion)
        self.lastLaunchDate = try container.decodeIfPresent(Date.self, forKey: .lastLaunchDate)
    }
}

struct KeyCombo: Codable {
    let keyCode: UInt16
    let modifiers: UInt
    init(keyCode: UInt16, modifiers: UInt) {
        self.keyCode = keyCode
        self.modifiers = modifiers
    }
}

enum Activity: String, Codable, Hashable, CaseIterable {
    case media, calendar, fileTray, bluetooth
}

enum Theme: String, Codable {
    case light, dark, auto
}
