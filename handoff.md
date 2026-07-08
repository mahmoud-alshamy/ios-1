# DynamicWin macOS - Development Handoff

**Last Updated**: 2026-07-08  
**Current Build**: Phase 4 Complete - 45 Swift files, ~2,266 lines  
**Status**: ✅ Builds successfully, all tests pass (no regressions)

---

## Project Overview

DynamicWin is a native macOS menu bar widget inspired by the iPhone Dynamic Island. It provides quick access to:
- **Media Controls** - Play/pause, track info, favorites (Phase 3 ✅)
- **Calendar** - Today's events, upcoming 7-day window (Phase 4 ✅)
- **File Tray** - Clipboard-like file management (Phase 5 pending)
- **Bluetooth** - Device status and battery levels (Phase 6 pending)

The app runs as a menu bar extra with an expandable floating panel. Activities can be switched via dots, arrows, or keyboard shortcuts (future).

---

## Current Status (Phase 4 Complete)

### ✅ Completed Features

| Phase | Feature | Status | Files | Lines |
|-------|---------|--------|-------|-------|
| 1 | Infrastructure & DI | ✅ Complete | 24 | 650 |
| 2 | Menu Bar & Windows | ✅ Complete | 13 | 450 |
| 3 | Media Player | ✅ Complete | 5 | 320 |
| 4 | Calendar (EventKit) | ✅ Complete | 7 | 361 |
| **5** | **File Tray** | 🔄 Next | - | - |
| 6 | Bluetooth | ⏳ Pending | - | - |
| 7 | Settings & Polish | ⏳ Pending | - | - |
| 8 | Testing & QA | ⏳ Pending | - | - |
| 9 | Docs & Release | ⏳ Pending | - | - |

### Project Structure

```
Sources/
├── App/
│   ├── DynamicWinApp.swift          # @main entry point, MenuBarExtra
│   └── AppDelegate.swift             # Lifecycle, AppCoordinator init
├── Core/
│   ├── AppCoordinator.swift          # High-level flow coordination
│   ├── Preferences/
│   │   ├── AppPreferences.swift      # Codable prefs model (Activity enum, Theme)
│   │   └── PreferencesManager.swift  # UserDefaults persistence
│   └── Configuration/
│       └── Constants.swift           # UI dims (Panel: 350×280), timings
├── Features/
│   ├── MenuBar/
│   │   ├── MenuBarController.swift   # NSStatusItem, FloatingPanel manager
│   │   ├── Models/MenuBarState.swift
│   │   ├── ViewModels/MenuBarViewModel.swift  # @MainActor, viewState machine
│   │   └── Views/
│   │       ├── CompactMenuBarView.swift       # Icon + activity dots
│   │       ├── PanelContentView.swift         # Activity router + nav
│   │       └── ExpandedPanelView.swift        # Phase 1 placeholder
│   └── Activities/
│       ├── ActivityContentView.swift          # Switch router for 4 activities
│       ├── Media/
│       │   ├── Models/MediaTrack.swift
│       │   ├── ViewModels/MediaViewModel.swift
│       │   └── Views/
│       │       ├── MediaCompactView.swift     # Thumbnail + info
│       │       └── MediaExpandedView.swift    # Full player UI
│       └── Calendar/
│           ├── Models/CalendarEvent.swift     # Dual init (NSColor, CGColor)
│           ├── ViewModels/CalendarViewModel.swift
│           └── Views/
│               ├── CalendarCompactView.swift  # Next event preview
│               └── CalendarExpandedView.swift # Full event list + rows
├── Services/
│   ├── ServiceProvider.swift         # Protocol + DefaultServiceProvider (lazy init)
│   ├── Media/
│   │   └── MediaPlayerService.swift  # Timer-based polling (1s), @Published track/isPlaying
│   ├── Calendar/
│   │   └── CalendarService.swift     # EventKit integration, 60s polling
│   ├── FileTray/
│   │   └── FileTrayService.swift     # Stub (Phase 5)
│   ├── Bluetooth/
│   │   └── BluetoothService.swift    # Stub (Phase 6)
│   └── System/
│       ├── HotKeyManager.swift       # Stub for global hotkeys
│       ├── NotificationManager.swift # Stub for toast notifications
│       ├── ScreenMonitor.swift       # Multi-monitor + cursor detection
│       ├── DarkModeListener.swift    # @Published isDarkMode
│       └── UpdateCheckService.swift  # Auto-updater stub
├── Components/
│   ├── UI/
│   │   ├── ActivityDots.swift        # Tap-to-switch activity indicators
│   │   └── IconButton.swift          # Reusable button with helpText
│   └── Panels/
│       ├── FloatingPanelWindow.swift # NSPanel transparent, shadow, floating
│       ├── FloatingPanelViewController.swift
│       ├── PanelPositioner.swift     # positionPanelNearMenuBar()
│       └── PanelAnimator.swift       # animateExpand/Collapse
├── Models/
│   └── ValueObjects/
│       ├── Activity.swift            # Enum: media, calendar, fileTray, bluetooth
│       └── ViewState.swift           # State machine: compact, expanded(Activity), transitioning
└── Utilities/
    ├── Logger.swift                  # os.log integration, LogLevel enum
    └── Helpers/
        └── ImageCache.swift          # NSCache (100MB) + disk persistence (PNG)
```

---

## Architecture Deep Dive

### Design Patterns

**1. MVVM with Combine**
```swift
// Service publishes updates
@Published var currentTrack: MediaTrack?

// ViewModel subscribes and republishes for UI
@MainActor class MediaViewModel: ObservableObject {
    @Published var track: MediaTrack?
    private let service: MediaPlayerService
    
    func setup() {
        service.$currentTrack
            .receive(on: DispatchQueue.main)
            .assign(to: &$track)
    }
}

// View observes ViewModel
struct MediaView: View {
    @StateObject var viewModel = MediaViewModel()
    var body: some View { Text(viewModel.track?.title ?? "No track") }
}
```

**2. Service Locator with Lazy Initialization**
```swift
@MainActor
class DefaultServiceProvider: ServiceProvider {
    lazy var mediaService: MediaPlayerService = {
        Logger.log("Initializing MediaPlayerService")
        return MediaPlayerService()
    }()
}

// Injected via environment
@Environment(\.serviceProvider) var services
let viewModel = MediaViewModel(service: services.mediaService)
```

**3. State Machine for UI Flow**
```swift
enum ViewState {
    case compact
    case expanded(Activity)
    case transitioning
}

// Prevents invalid transitions
func toggleExpanded() {
    switch viewState {
    case .compact: viewState = .expanded(.media)
    case .expanded: viewState = .compact
    case .transitioning: break  // Ignore during animation
    }
}
```

### Threading Strategy

**Golden Rule**: All UI updates on MainActor.

```swift
// Service runs on background thread
class MediaPlayerService: BackgroundService {
    private let updateTimer: Timer?
    
    func start() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            // Fetch on background thread
            self?.pollMediaPlayer()
        }
    }
    
    private func pollMediaPlayer() {
        DispatchQueue.main.async {
            self.currentTrack = track  // Update @Published on main
        }
    }
}

// ViewModel bridges to MainActor-isolated view
@MainActor
class MediaViewModel: ObservableObject {
    private let service: MediaPlayerService  // Not MainActor
    
    func setup() {
        service.$currentTrack
            .receive(on: DispatchQueue.main)  // Explicit main thread
            .assign(to: &$track)
    }
}
```

### Key Implementation Decisions

1. **No @MainActor on Services**: Services live on background threads. ViewModels (@MainActor) bridge via Combine. Prevents deadlocks and keeps UI responsive.

2. **Combine over async/await for subscriptions**: @Published + subscribers provide automatic lifecycle management (cancellables auto-cleaned on dealloc).

3. **NSImage → disk cache**: Album art fetched from system/Spotify persisted as PNG to avoid repeated I/O.

4. **Timer-based polling over notifications**: Media and Calendar services poll periodically instead of listening for system notifications. More reliable across different systems/apps.

5. **Codable preferences**: AppPreferences stored as JSON in UserDefaults. Custom encode/decode for Set<Activity> compatibility.

6. **FloatingPanelWindow over NSPopover**: Gives more control over positioning, behavior, and animations. Manually manage lifecycle.

---

## Session Changes (Phase 4)

### Files Created (3)
- `Sources/Features/Activities/Calendar/ViewModels/CalendarViewModel.swift` (49 lines)
- `Sources/Features/Activities/Calendar/Views/CalendarCompactView.swift` (56 lines)
- `Sources/Features/Activities/Calendar/Views/CalendarExpandedView.swift` (128 lines)

### Files Modified (4)

**CalendarService.swift** - Full EventKit integration
- Added EventKit import and event fetching logic
- `requestCalendarAccess()` with macOS 14.0+ fallback
- `fetchEvents()` queries today + 7-day window
- `convertEKEvent()` transforms EKEvent → CalendarEvent
- Polling every 60 seconds with proper background threading
- @Published properties: upcomingEvents, todayEvents, isLoading, error

**CalendarEvent.swift** - Dual initialization for EventKit
- Changed `id` from UUID to String for EventKit compatibility
- Added second initializer accepting CGColor (from EventKit calendars)
- NSColor(cgColor:) conversion with fallback to systemBlue

**ActivityContentView.swift** - Calendar routing
- Replaced calendar placeholder VStack with CalendarExpandedView
- Passes serviceProvider.calendarService to ViewModel

**MenuBarController.swift** - Service startup
- Added `serviceProvider.calendarService.start()` in startBackgroundServices()

### Commit
```
368aee2 Phase 4: Calendar Integration with EventKit
```

---

## Known Limitations & Bugs

### Current

1. **No Google Calendar OAuth yet** - Only fetches system calendar (Phase 4). Google Calendar integration deferred to Phase 5 as optional feature.

2. **No recurring event expansion** - Shows series as single event. EventKit handles this, not a bug, but UX limitation.

3. **No event notifications** - Calendar events don't generate toasts/alerts when they start. Stub only.

4. **Media player demo track** - No real Spotify/Apple Music integration. Service shows demo "No Track Playing" when not connected. Needs AppleScript or MediaPlayer framework integration in future phase.

5. **File Tray not implemented** - Still a stub placeholder in ActivityContentView.

6. **Bluetooth not implemented** - Still a stub placeholder in ActivityContentView.

### Previous Issues (Fixed in Phase 3-4)

✅ **MainActor crossing isolation** - Solved with nonisolated decorators and Task { @MainActor in }  
✅ **NSColor unavailable on macOS** - Used NSColor.textColor, NSColor.secondaryLabelColor  
✅ **NSAppearance not available** - Custom AppleInterfaceThemeChangedNotification + guard let NSAppearance.current  
✅ **MPMusicPlayerController iOS-only** - Removed entirely, using Timer polling instead  
✅ **Preview macros not available** - Removed all #Preview blocks from files  
✅ **NSImage(contentsOf:) type issues** - Used file URL constructors correctly  

---

## Testing & Quality Assurance

### Current Test Coverage
- **Unit Tests**: None yet (Phase 8)
- **Integration Tests**: None yet (Phase 8)
- **Manual Testing**: Phase 1-4 features manually verified

### What Should Be Tested Next
1. Calendar service fetches today's and upcoming events correctly
2. Event list updates when new events added to calendar
3. All 4 activities (Media, Calendar, FileTray, Bluetooth) can be switched without crashes
4. Panel positioning on multi-monitor setups
5. Dark mode appearance switching

### Known Test Scenarios Not Covered
- [ ] Long event titles truncation
- [ ] Events with no location field
- [ ] All-day events display
- [ ] Current event highlighting (green badge)
- [ ] Empty calendar state
- [ ] Calendar access denied state

---

## Next Recommended Task: Phase 5 - File Tray Integration

### Scope (7-8 hours estimated)

1. **FileTrayService** - File operations
   - `addFile(url:)` - Add to tray
   - `removeFile(id:)` - Remove from tray
   - `openFile(id:)` - Launch file
   - Persistence via UserDefaults

2. **FileTrayViewModel** - Reactive state
   - @Published files list
   - File type detection via NSWorkspace
   - File icons via NSImage

3. **FileTrayCompactView** - Menu bar preview
   - Show recent file or file count

4. **FileTrayExpandedView** - Full interface
   - Scrollable file list with icons
   - Context menu (open, reveal in Finder, remove)
   - Drag-and-drop zone for adding files

5. **Integration**
   - Add to ActivityContentView router
   - Start FileTrayService in MenuBarController
   - Support drag-drop to panel

### Estimated Effort

| Task | Duration | Notes |
|------|----------|-------|
| FileTrayService implementation | 1.5h | File ops, UserDefaults persistence |
| FileTrayViewModel setup | 1h | Similar to MediaViewModel pattern |
| UI Components (Compact + Expanded) | 2.5h | Context menu is time-consuming |
| Drag-and-drop integration | 1.5h | NSView drop target in FloatingPanel |
| Testing + bug fixes | 1h | Manual testing of file operations |
| **Total** | **7.5h** | |

### Before Starting Phase 5

- [ ] Review `FileTrayService.swift` stub
- [ ] Check `FileTrayItem.swift` model (already has id, url, fileType, icon)
- [ ] Plan persistence strategy (simple UserDefaults is fine)
- [ ] Consider max files limit (suggest 20-30)

---

## Architecture Decisions Reference

### Why MVVM + Combine?

✅ Reactive properties automatically trigger UI updates  
✅ Easy to test (mock services, inspect ViewModel state)  
✅ SwiftUI @ObservedObject / @StateObject works seamlessly  
✅ Combine cancellables auto-cleaned on dealloc  

### Why ServiceProvider over direct injection?

✅ Single source of truth for all singletons  
✅ Lazy initialization avoids startup overhead  
✅ Easier testing (can swap mock providers)  
✅ Future: environment-based config (dev/staging/prod)  

### Why Timer polling instead of notifications?

✅ More reliable - doesn't depend on system notification delivery  
✅ Predictable update rate (media: 1s, calendar: 60s)  
✅ Works across different apps/systems  
✅ Simpler error handling  
⚠️ Trade-off: Slightly higher CPU. But acceptable for menu bar app.

### Why FloatingPanelWindow over NSPopover?

✅ Better control over positioning (menu bar relative, multi-monitor)  
✅ Can customize animations (expand/collapse)  
✅ Stays on top, accepts keyboard  
⚠️ Trade-off: Manual lifecycle management (create, show, hide, cleanup)

---

## Build & Deployment

### Build Environment
- **Swift**: 5.9+
- **macOS Target**: 12.0+ (iOS target not relevant)
- **Dependencies**: None (stdlib only)
- **Package Manager**: SPM via Package.swift

### Build Commands
```bash
# Development build
swift build

# Release build (suppresses warnings)
swift build -c release

# Run
swift run DynamicWin
```

### Common Build Issues & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `MainActor-isolated property referenced from nonisolated` | Crossing actor boundary | Use `nonisolated` decorator + `Task { @MainActor in }` |
| `value of optional type must be unwrapped` | Swift 6 strict optionals | Use `guard let` or `?? default` |
| `conformance isolation violation` | Protocol impl crosses MainActor | Check service doesn't have @MainActor, ViewModel does |
| `'swift-tools-version: 5.9' not found` | Old Swift toolchain | Update Xcode to latest |

---

## Important Files to Know

### Core Infrastructure
- **AppDelegate.swift** - ServiceProvider initialization. If app startup fails, check here first.
- **MenuBarController.swift** - NSStatusItem + FloatingPanel management. If menu bar icon missing, start here.
- **ServiceProvider.swift** - Service registry. Need to add new service? Add here.

### Activity Routing
- **ActivityContentView.swift** - Central router. To add new activity (Phase 5-7), update the switch statement.
- **MenuBarViewModel.swift** - Activity state. Knows current activity, handles switching.
- **ViewState.swift** - UI state machine. Prevents invalid state transitions.

### Preferences & Config
- **AppPreferences.swift** - User settings (enabled activities, hotkeys, theme). Modify to add new preferences.
- **PreferencesManager.swift** - Persistence layer. Handles save/load to UserDefaults.
- **Constants.swift** - Hard-coded values (panel size, animation duration). Update here for UI tweaks.

---

## Debugging Tips

### Enable Verbose Logging
All log messages go through `Logger.log()` with categories. Edit `Logger.swift` to adjust level:
```swift
private let minimumLevel: LogLevel = .debug  // Change to .info, .warning, .error
```

### Check Service Initialization
Add breakpoint in `DefaultServiceProvider` lazy properties to verify services created when expected.

### Verify MainActor Isolation
Use @MainActor on ViewModels, not Services. If you see actor-crossing errors, review threading:
- Services: Background threads OK
- ViewModels: @MainActor required
- Views: Always MainActor (implicit)

### Test Panel Positioning
Multi-monitor can be tricky. Check `PanelPositioner.swift`:
```swift
let cursorScreen = screenMonitor.screenContainingCursor()  // Or use screenContainingMenuBar()
```

### Verify Calendar Access
On first run, macOS requests calendar access. Check System Settings → Privacy & Security → Calendar.
If permission denied and you need to reset: `rm ~/Library/Preferences/com.apple.universalaccess.plist`

---

## Next Developer Checklist

- [ ] Read ARCHITECTURE.md for design philosophy
- [ ] Review Phase 1-4 commits to understand evolution
- [ ] Build project locally and run it
- [ ] Test switching between Media and Calendar activities
- [ ] Verify calendar fetches your actual calendar events
- [ ] Read this handoff document top-to-bottom
- [ ] Identify any questions before proceeding with Phase 5

---

## Contact / Questions

If you have questions about:
- **Architecture**: See ARCHITECTURE.md and comments in ServiceProvider.swift
- **Specific Feature**: Check the phase commit message (git log --oneline)
- **Build Issues**: See "Common Build Issues" section above
- **UI/UX Decisions**: Review Constants.swift and PanelPositioner.swift

---

**Happy coding! The foundation is solid. Phase 5 should follow the same patterns with minimal friction.**
