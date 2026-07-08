import Foundation
import Combine

class PreferencesManager: ObservableObject {
    private static let preferencesKey = "com.dynamicwin.preferences"
    private let userDefaults: UserDefaults

    @Published private(set) var preferences: AppPreferences = AppPreferences()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadPreferences() {
        if let data = userDefaults.data(forKey: Self.preferencesKey) {
            do {
                let decoder = JSONDecoder()
                preferences = try decoder.decode(AppPreferences.self, from: data)
                Logger.log("Preferences loaded successfully", category: "PreferencesManager")
            } catch {
                Logger.log("Failed to decode preferences: \(error)", level: .error, category: "PreferencesManager")
                preferences = AppPreferences()
            }
        } else {
            Logger.log("No saved preferences found, using defaults", category: "PreferencesManager")
            preferences = AppPreferences()
        }
        preferences.lastLaunchDate = Date()
    }

    func savePreferences() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(preferences)
            userDefaults.set(data, forKey: Self.preferencesKey)
            Logger.log("Preferences saved successfully", category: "PreferencesManager")
        } catch {
            Logger.log("Failed to encode preferences: \(error)", level: .error, category: "PreferencesManager")
        }
    }

    func updatePreferences(_ updater: (inout AppPreferences) -> Void) {
        updater(&preferences)
        savePreferences()
    }

    func resetToDefaults() {
        preferences = AppPreferences()
        userDefaults.removeObject(forKey: Self.preferencesKey)
        Logger.log("Preferences reset to defaults", category: "PreferencesManager")
    }
}
