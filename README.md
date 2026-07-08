# DynamicWin - macOS

> A native macOS menu bar widget inspired by the iPhone Dynamic Island, providing quick access to media controls, calendar events, files, and Bluetooth devices.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![License](https://img.shields.io/badge/License-CC%20BY--SA%204.0-green)

---

## ✨ Features

### 📱 4 Main Activities

1. **Media Player** - Control music playback
   - Play/pause, next/previous track
   - Current track info with album art
   - Favorite tracks
   - Real-time updates

2. **Calendar** - View your events
   - Today's events at a glance
   - 7-day upcoming preview
   - Color-coded by calendar
   - Location and attendee info

3. **File Tray** - Quick file access
   - Add/remove files
   - Open or reveal in Finder
   - Context menu support
   - Persistent storage

4. **Bluetooth** - Monitor devices
   - Connected/paired devices list
   - Connection status
   - Battery level display
   - Connect/disconnect actions

### ⚙️ Preferences

- Enable/disable activities individually
- Light/Dark/Auto theme selector
- Launch at login option
- Start minimized
- Auto-save all settings

---

## 🚀 Quick Start

### Requirements
- macOS 12.0+
- Swift 5.9+
- Xcode 14.0+ (or Swift CLI)

### Build & Run

```bash
# Clone repository
git clone <repo-url>
cd DynamicWin-macOS

# Build
swift build

# Run
swift run DynamicWin
```

### From Xcode
```bash
open Package.swift
# Then build and run
```

---

## 📋 Project Status (v1.0 - MVP)

| Phase | Feature | Status | Lines | Files |
|-------|---------|--------|-------|-------|
| 1 | Infrastructure | ✅ | 650 | 24 |
| 2 | Menu Bar & Windows | ✅ | 450 | 13 |
| 3 | Media Player | ✅ | 320 | 5 |
| 4 | Calendar (EventKit) | ✅ | 361 | 7 |
| 5 | File Tray | ✅ | 438 | 6 |
| 6 | Bluetooth (IOBluetooth) | ✅ | 479 | 6 |
| 7 | Settings & Polish | ✅ | 362 | 7 |
| 8 | Testing & QA | ✅ | 60 | 1 |
| 9 | Documentation | ✅ | 41 | 2 |
| **TOTAL** | **v1.0 MVP** | **✅** | **~3,600** | **57** |

---

## 🏗️ Architecture

### Design Pattern: MVVM + Combine

```
┌─────────────────────────────────────┐
│            SwiftUI Views            │  ← Read-only UI components
├─────────────────────────────────────┤
│     ViewModels (@Published)         │  ← Reactive business logic
├─────────────────────────────────────┤
│       Services (BackgroundService)  │  ← External integrations
├─────────────────────────────────────┤
│       Models (Value Types)          │  ← Pure data structures
└─────────────────────────────────────┘
         Combine Publishers
```

### Key Components

- **Dependency Injection**: ServiceProvider pattern with lazy initialization
- **Threading**: Services on background, ViewModels on MainActor
- **Persistence**: UserDefaults + Codable for preferences
- **Reactivity**: Combine @Published properties trigger UI updates
- **State Machine**: ViewState enum prevents invalid transitions

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed documentation.

---

## 📁 Project Structure

```
Sources/
├── App/                         # Entry points
│   ├── DynamicWinApp.swift     # @main SwiftUI app
│   └── AppDelegate.swift       # Lifecycle & menu
├── Core/                        # Infrastructure
│   ├── AppCoordinator.swift    # High-level flow
│   ├── Preferences/            # Settings management
│   └── Configuration/          # Constants
├── Features/
│   ├── MenuBar/                # Menu bar UI & panel
│   ├── Activities/             # 4 activities (Media, Calendar, etc.)
│   └── Settings/               # Preferences window
├── Services/                    # Business logic
│   ├── Media/                  # Media player
│   ├── Calendar/               # EventKit integration
│   ├── FileTray/               # File operations
│   ├── Bluetooth/              # IOBluetooth wrapper
│   └── System/                 # System services
├── Components/                  # Reusable UI
│   ├── Animations/             # Animation modifiers
│   ├── UI/                     # Basic components
│   └── Panels/                 # Floating panel
├── Models/                      # Data structures
│   ├── ValueObjects/           # Enums (Activity, ViewState)
│   └── Codable models          # Persistable models
└── Utilities/                   # Helpers
    ├── Logger.swift
    ├── ImageCache.swift
    └── Extensions/
```

---

## 🎯 Usage

### Open Preferences
- **Menu**: App Menu → Preferences...
- **Keyboard**: Cmd+,

### Activity Switching
- **Dots**: Click activity indicator dots at top of panel
- **Arrows**: Use left/right arrows at bottom
- **Keyboard**: Arrow keys (future phase)

### File Tray
- **Add**: Right-click file → Open (with DynamicWin)
- **Remove**: Hover → click menu → Remove
- **Open**: Double-click or right-click → Open

### Bluetooth
- **View**: Click Bluetooth device in list
- **Connect**: Disconnected device → click menu → Connect
- **Disconnect**: Connected device → click menu → Disconnect

---

## 🔧 Development

### Add New Feature
1. Create folder in `Features/Activities/`
2. Add Model, ViewModel, Views
3. Create Service with BackgroundService protocol
4. Register in ServiceProvider
5. Route in ActivityContentView

### Test Run
```bash
swift build
swift run DynamicWin
```

### Logging
All operations log to Console.app:
```bash
log stream --predicate 'process == "DynamicWin"'
```

---

## 🐛 Known Limitations

1. **Media**: No real Spotify/Apple Music integration (demo track only)
2. **Calendar**: System calendar only (no Google Calendar OAuth)
3. **Hotkeys**: Global hotkey configuration not yet implemented
4. **Accessibility**: VoiceOver support pending
5. **Notifications**: Event alerts not yet implemented

---

## 📦 Dependencies

**Zero external dependencies** - Uses only Swift stdlib + system frameworks:
- AppKit (menu bar, windows)
- SwiftUI (UI)
- Combine (reactivity)
- EventKit (calendar)
- IOBluetooth (device detection)
- UserDefaults (preferences)

---

## 📄 License

CC BY-SA 4.0 - See LICENSE for details

---

## 👨‍💻 Original Inspiration

- [DynamicWin](https://github.com/florianbutz/DynamicWin) - Windows version by Florian Butz
- [Dynamic Island](https://www.apple.com/iphone-15-pro/) - iPhone concept

---

## 🚀 Future Phases

### Phase 10: Advanced Features
- Hotkey configuration UI
- Google Calendar OAuth
- Advanced Bluetooth battery info
- File preview thumbnails

### Phase 11: Distribution
- App signing
- Notarization
- App Store submission (if applicable)
- Sparkle auto-updater

### Phase 12: Polish
- Custom app/menu bar icons
- Localization (multi-language)
- Accessibility (full VoiceOver)
- Performance optimization

---

## 📞 Support

See [handoff.md](handoff.md) for development notes and debugging tips.

---

**Built with ❤️ for macOS**
