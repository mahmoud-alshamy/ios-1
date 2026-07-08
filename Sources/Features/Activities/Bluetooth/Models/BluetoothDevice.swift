import Foundation
import AppKit

struct BluetoothDevice: Identifiable {
    let id: String
    let name: String
    let address: String
    let isConnected: Bool
    let batteryLevel: Int?
    let deviceType: DeviceType
    let lastUpdated: Date

    init(name: String, address: String, isConnected: Bool, batteryLevel: Int? = nil, deviceType: DeviceType = .unknown) {
        self.id = address
        self.name = name
        self.address = address
        self.isConnected = isConnected
        self.batteryLevel = batteryLevel
        self.deviceType = deviceType
        self.lastUpdated = Date()
    }

    var icon: NSImage? {
        NSImage(systemSymbolName: deviceType.systemImage, accessibilityDescription: deviceType.displayName)
    }

    var statusText: String { isConnected ? "Connected" : "Disconnected" }
    var batteryText: String? {
        guard let batteryLevel = batteryLevel else { return nil }
        return "\(batteryLevel)%"
    }
}

enum DeviceType: String, Codable, CaseIterable {
    case headphones, watch, mouse, keyboard, speaker, unknown

    var systemImage: String {
        switch self {
        case .headphones: return "headphones"
        case .watch: return "applewatch"
        case .mouse: return "computermouse"
        case .keyboard: return "keyboard"
        case .speaker: return "speaker.wave.2"
        case .unknown: return "questionmark.circle"
        }
    }

    var displayName: String {
        switch self {
        case .headphones: return "Headphones"
        case .watch: return "Watch"
        case .mouse: return "Mouse"
        case .keyboard: return "Keyboard"
        case .speaker: return "Speaker"
        case .unknown: return "Device"
        }
    }
}
