# DynamicWin - macOS

A native macOS application inspired by the iPhone Dynamic Island, providing quick access to system information, media controls, calendar events, and file management in a compact, interactive menu bar widget.

## Project Status

### Phase 1: ✅ COMPLETE - Project Setup & Infrastructure

Infrastructure foundation established with 24 Swift files covering:

#### Core Systems
- **Logger** - Unified logging system with debug output and Console.app integration
- **AppDelegate** - Application lifecycle management
- **AppCoordinator** - High-level application flow coordination
- **ServiceProvider** - Dependency injection container with lazy initialization
- **PreferencesManager** - Type-safe preference persistence using Codable

#### Models
- **Activity** - Enum for 4 main activities (Media, Calendar, FileTray, Bluetooth)
- **MediaTrack** - Media player track data
- **CalendarEvent** - Calendar event data
- **FileTrayItem** - File storage with persistence
- **BluetoothDevice** - Bluetooth device info

#### Services (Stubs Ready for Implementation)
- MediaPlayerService, CalendarService, FileTrayService, BluetoothService
- HotKeyManager, NotificationManager, ScreenMonitor, DarkModeListener
- UpdateCheckService

#### Configuration
- **Constants** - UI dimensions, animation timings, refresh intervals
- **ColorPalette** - Theme-aware colors
- **SystemConfiguration** - System state queries

## Next: Phase 2 - Menu Bar & Window System

- NSStatusItem/MenuBarExtra integration
- NSPanel floating window management
- Window positioning and animations
- Compact and expanded view layouts

## Building

```bash
open Package.swift  # Open in Xcode
swift build        # Or build from CLI
swift run DynamicWin
```

## Architecture: MVVM with Dependency Injection

- **Views** - SwiftUI components (read-only)
- **ViewModels** - Reactive business logic
- **Models** - Pure data structures
- **Services** - External integrations
- **Protocols** - Enable testing and mocking

## Technologies

- Swift 5.9+, SwiftUI, Combine, AppKit
- EventKit (Calendar), IOBluetooth (Bluetooth)
- UserDefaults, FileManager, Concurrency APIs

---

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed design documentation.
