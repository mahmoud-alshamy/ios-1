import Foundation

class HotKeyManager {
    init() { Logger.log("HotKeyManager initialized", category: "HotKeyManager") }
    func registerGlobalHotkey(_ keyCombo: KeyCombo, action: @escaping () -> Void) { Logger.log("Registering global hotkey: \(keyCombo.keyCode)", category: "HotKeyManager") }
    func unregisterGlobalHotkey(_ keyCombo: KeyCombo) { Logger.log("Unregistering global hotkey: \(keyCombo.keyCode)", category: "HotKeyManager") }
    func unregisterAllHotkeys() { Logger.log("Unregistering all hotkeys", category: "HotKeyManager") }
}
