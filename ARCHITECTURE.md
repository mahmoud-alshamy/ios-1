# DynamicWin Architecture

## Overview

DynamicWin is built on **MVVM** (Model-View-ViewModel) with **Protocol-Oriented Programming** and **Dependency Injection**.

## Core Principles

### 1. Separation of Concerns
- **Views** - UI only, no business logic
- **ViewModels** - Business logic, reactive state management
- **Models** - Pure, immutable data structures
- **Services** - External integrations, API calls, system interactions

### 2. Reactivity with Combine
- **@Published** properties trigger automatic UI updates
- **Combine.Publisher** for reactive data streams
- **@StateObject** for ViewModel lifecycle management
- No manual view updates needed

### 3. Dependency Injection via ServiceProvider
- **ServiceProvider** protocol defines all services
- **DefaultServiceProvider** provides real implementations
- **Environment** propagates services through view hierarchy
- Easy to replace with mocks for testing

### 4. Type Safety Throughout
- Enums for finite states (Activity, ViewState, DeviceType)
- Value types for models (immutability by default)
- Reference types for services (shared, mutable state)
- Strong typing prevents entire classes of bugs

## Project Structure

### Sources/App/
Entry points
- **DynamicWinApp.swift** - Main app with @main
- **AppDelegate.swift** - Lifecycle, initialization

### Sources/Core/
Infrastructure
- **AppCoordinator.swift** - High-level flow coordination
- **Preferences/** - User settings persistence
- **Configuration/** - Constants, theme colors, system config

### Sources/Services/
Business logic and integrations
- **Media/** - MediaPlayerService
- **Calendar/** - CalendarService
- **FileTray/** - FileTrayService
- **Bluetooth/** - BluetoothService
- **System/** - HotKeyManager, ScreenMonitor, DarkModeListener
- **Background/** - UpdateCheckService

All services are **lazy-initialized** singletons via ServiceProvider.

### Sources/Features/
Feature modules, each with MVVM structure
- **MenuBar/** - Menu bar UI
- **Activities/** - 4 main activity features
  - **Media/** - Music player (Models, ViewModels, Views)
  - **Calendar/** - Calendar events
  - **FileTray/** - File management
  - **Bluetooth/** - Device connectivity
  - **Navigation/** - Activity switching, state machine

### Sources/Models/
Data structures
- **ValueObjects/** - Activity, ViewState, DeviceType, Theme
- **DTOs/** (future) - Serializable data transfer objects

### Sources/Utilities/
Reusable helpers
- **Logger.swift** - Unified logging to console + os.log
- **Extensions/** - SwiftUI, AppKit, URL, Date, NSImage helpers
- **Helpers/** - FileSystemHelper, IconProvider, ImageCache

## Data Flow Architecture

```
System Event (e.g., Bluetooth device connects)
    ↓
Service receives notification / API response
    ↓
Service updates @Published property
    ↓
ViewModel subscribes to service publishers via Combine
    ↓
ViewModel updates its own @Published properties
    ↓
View observes ViewModel via @StateObject
    ↓
SwiftUI detects changes, re-renders affected views
    ↓
User sees updated UI
```

**Key**: Data flows one direction. Views never update services directly.

## Design Patterns

### 1. MVVM Pattern

```swift
// MODEL: Pure data
struct MediaTrack {
    let title: String
    let artist: String
}

// VIEWMODEL: Reactive business logic
@MainActor
class MediaViewModel: ObservableObject {
    @Published var track: MediaTrack?
    @Published var isPlaying: Bool = false
    
    private let service: MediaPlayerService
    
    func setup() {
        service.trackPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$track)
    }
}

// VIEW: UI only, read-only
struct MediaView: View {
    @StateObject var viewModel = MediaViewModel()
    
    var body: some View {
        VStack {
            Text(viewModel.track?.title ?? "No track")
            Button("Play") { /* calls viewModel */ }
        }
    }
}
```

### 2. Service Locator Pattern

ServiceProvider centralizes service creation and access:

```swift
protocol ServiceProvider {
    var mediaService: MediaPlayerService { get }
    var calendarService: CalendarService { get }
    // ...
}

class DefaultServiceProvider: ServiceProvider {
    lazy var mediaService = MediaPlayerService()  // Single instance
    lazy var calendarService = CalendarService()
}

// Injected via environment
@Environment(\.serviceProvider) var serviceProvider
```

### 3. Publisher Pattern

Services expose reactive streams:

```swift
class MediaPlayerService {
    let trackPublisher = PassthroughSubject<MediaTrack, Never>()
    
    private func observeMediaPlayer() {
        // Listen for system notifications
        trackPublisher.send(newTrack)
    }
}
```

### 4. State Machine Pattern

ViewState controls UI flow:

```swift
enum ViewState {
    case compact
    case expanded(Activity)
    case transitioning
}

// Prevents invalid state combinations
func toggleExpanded() {
    switch viewState {
    case .compact:
        viewState = .expanded(.media)  // Valid
    case .expanded:
        viewState = .compact           // Valid
    case .transitioning:
        break                          // Ignore during animation
    }
}
```

## Threading Strategy

**Golden Rule**: All UI updates must happen on the main thread.

```swift
func observeMediaPlayer() {
    backgroundQueue.async { [weak self] in
        // Listen for AVPlayer notifications (background thread)
        self?.mediaPlayer.trackPublisher
            .receive(on: DispatchQueue.main)  // ← Switch to main
            .assign(to: &self?.$currentTrack)  // Now safe to update UI
    }
}
```

## Memory Management

### ViewModels
- Held by `@StateObject` in views
- Lifecycle tied to view hierarchy
- Cancellables automatically cleaned up on deallocation

### Services
- Singletons via ServiceProvider
- Weak self in closure captures
- Auto-cancellable background tasks

### Views
- Value types (structs), recreated on state changes
- No strong references to services
- Access services only via environment

## Error Handling

Services throw typed errors:

```swift
enum MediaPlayerError: Error {
    case playerNotFound
    case commandFailed
    case authorizationDenied
}

func play() async throws {
    try await service.play()
}
```

ViewModels handle gracefully:

```swift
@Published var errorAlert: AlertState?

@MainActor
func handleError(_ error: Error) {
    errorAlert = AlertState(
        title: "Error",
        message: error.localizedDescription
    )
}
```

## Testing Strategy

### Unit Tests
- ViewModels tested with mock services
- Services tested in isolation
- No UI framework required
- Easy to parallelize

### Integration Tests
- Activity switching behavior
- State persistence
- Service coordination

### Mocks
Protocol-based services enable easy mocking:

```swift
// Real
class MediaPlayerService: MediaPlayerServiceProtocol { }

// Mock for testing
class MockMediaPlayerService: MediaPlayerServiceProtocol {
    var playWasCalled = false
    func play() async throws { playWasCalled = true }
}
```

## Performance Optimizations

### Lazy Initialization
Services created only when accessed:

```swift
lazy var mediaService: MediaPlayerService = {
    Logger.log("Initializing MediaPlayerService")
    return MediaPlayerService()
}()
```

### Image Caching
NSImages cached in memory:

```swift
class ImageCache {
    private var cache: [String: NSImage] = [:]
    func image(forURL url: URL) -> NSImage? { cache[url.path] }
}
```

### Combine Subscriptions
Auto-cleanup on ViewModel deallocation:

```swift
private var cancellables = Set<AnyCancellable>()

func setup() {
    service.publisher
        .assign(to: &$state)  // Stored in set, auto-cancelled
}
```

### Event-Driven Architecture
No polling loops. Services use system notifications:
- AVPlayer notifications for media
- EventKit notifications for calendar
- IOBluetooth notifications for devices
- DistributedNotificationCenter for appearance

## Scalability

Adding a new activity:
1. Create folder in `Features/Activities/NewFeature/`
2. Create Model, ViewModel, Views
3. Create Service with protocol
4. Register in ServiceProvider
5. Add to Activity enum
6. Add view in ActivityManager

The modular structure enables:
- Independent feature teams
- Parallel development
- Easy code review
- Simple testing

---

**Design Goal**: Build a production-grade macOS app that feels native, performs efficiently, and remains maintainable as it grows.
