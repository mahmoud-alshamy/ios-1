# Build Guide - DynamicWin macOS

Complete instructions for building, testing, and developing DynamicWin.

---

## Prerequisites

| Requirement | Version | Check |
|---|---|---|
| macOS | 12.0+ | `sw_vers` |
| Swift | 5.9+ | `swift --version` |
| Xcode | 14.0+ | `xcode-select --version` |

Install Xcode Command Line Tools:
```bash
xcode-select --install
```

---

## Building

### Via Swift CLI

```bash
# Navigate to project
cd DynamicWin-macOS

# Build (debug)
swift build

# Build (release)
swift build -c release

# Run
swift run DynamicWin

# Clean build
rm -rf .build
swift build
```

### Via Xcode

```bash
# Open project
open Package.swift

# In Xcode:
# 1. Select scheme "DynamicWin"
# 2. Product → Build (Cmd+B)
# 3. Product → Run (Cmd+R)
```

---

## Troubleshooting Build Issues

### Swift version error
```
Error: Swift 5.9 or later is required
```
**Fix**: Update Xcode
```bash
xcode-select --install
swift --version
```

### Module not found errors
```
Error: no such file or directory: 'DynamicWin'
```
**Fix**: Clean and rebuild
```bash
rm -rf .build Package.resolved
swift build
```

### MainActor isolation errors
These are **expected** - they represent proper Swift 6 strictness.
- Use `nonisolated` decorator for non-isolated methods
- Use `Task { @MainActor in }` to cross actor boundaries
- Keep services off MainActor, ViewModels on it

### Missing framework errors
Ensure you have Xcode command line tools:
```bash
sudo xcode-select --reset
```

---

## Running

### Development Run
```bash
swift run DynamicWin
```
App launches and sits in menu bar. Click icon to expand panel.

### Headless (background)
```bash
swift run DynamicWin &
```

### With Logging
```bash
# In separate terminal
log stream --predicate 'process == "DynamicWin"' --level debug

# Then run app
swift run DynamicWin
```

---

## Testing

### Run All Tests
```bash
swift test
```

### Run Specific Test
```bash
swift test MediaViewModelTests
```

### Test Output
Tests print to console:
```
Test Suite 'DynamicWinTests.xctest' started at 2026-07-08 10:00:00.000
Test Case 'MediaViewModelTests.testInitialState' started.
Test Case 'MediaViewModelTests.testInitialState' passed (0.001 seconds).
...
Test Suite 'DynamicWinTests.xctest' passed at 2026-07-08 10:00:00.500.
```

### Add New Tests
1. Create file in `Tests/`
2. Follow naming: `*Tests.swift`
3. Inherit from `XCTestCase`
4. Add `@testable import DynamicWin`

---

## Development Workflow

### Making Changes
1. Edit source files in `Sources/`
2. Build: `swift build`
3. Run: `swift run DynamicWin`
4. Iterate

### Code Organization
- One concept per file
- Keep files under 300 lines
- Use descriptive names
- Comment non-obvious decisions only

### Before Committing
```bash
# Verify clean build
swift build

# Run tests
swift test

# Check git status
git status

# Review changes
git diff

# Commit with message
git commit -m "Description"
```

---

## Debugging

### Enable Verbose Logging
Edit `Sources/Utilities/Logger.swift`:
```swift
private let minimumLevel: LogLevel = .debug  // Change from .info
```

### View Logs
```bash
log stream --predicate 'process == "DynamicWin"' --level debug
```

### Common Log Patterns
| Pattern | Meaning |
|---|---|
| `[DEBUG]` | Low-level details |
| `[INFO]` | Normal operations |
| `[WARN]` | Unexpected conditions |
| `[ERROR]` | Failed operations |

### Debugger
Use Xcode:
1. Open Package.swift in Xcode
2. Set breakpoint (click line number)
3. Run (Cmd+R)
4. Debugger stops at breakpoint

---

## Project Configuration

### Package.swift
- Swift version: 5.9
- Min macOS: 12.0
- Executable target: DynamicWin
- Test target: DynamicWinTests

### SwiftUI Compatibility
- Deployment: macOS 12+
- Framework: SwiftUI (iOS 13.0+)
- AppKit interop: NSWindow, NSPanel

---

## Performance Profiling

### Check CPU Usage
```bash
# While app running
ps aux | grep DynamicWin
```

### Memory Profiling
In Xcode:
1. Debug → Gauges
2. Memory gauge shows real-time usage
3. Should stay under 50MB

### Background Service Intervals
- Media polling: 1 second
- Calendar polling: 60 seconds
- Bluetooth polling: 5 seconds
- Adjust in Constants.swift if needed

---

## Code Quality

### Static Analysis
Swift compiler does this automatically. Watch for:
- Unused variables (warnings)
- Type mismatches (errors)
- Actor isolation violations (errors)

### Style
- Use Swift naming conventions (camelCase)
- Max line length: 100 chars (soft)
- Use SwiftUI over UIKit where possible
- Prefer value types (structs) over reference (classes)

### Comments
Only comment **WHY**, not WHAT:
```swift
// ✗ Bad - states what the code does
// Initialize the view model
let viewModel = MediaViewModel(service: service)

// ✓ Good - explains why
// Create ViewModel after service loads (async operation)
let viewModel = MediaViewModel(service: service)
```

---

## Release Build

### Optimize for Distribution
```bash
swift build -c release
```

This:
- Enables optimizations
- Removes debug symbols
- Smaller binary size

### Binary Location
```bash
ls -lh .build/release/DynamicWin
```

---

## Git Workflow

### Before Starting
```bash
git pull origin main
```

### While Developing
```bash
git add Sources/
git commit -m "Describe change"
git push origin feature-branch
```

### Create Pull Request
```bash
# Via GitHub web UI or gh CLI
gh pr create --title "Feature: ..." --body "Description"
```

---

## Troubleshooting Runtime Issues

### App Won't Launch
Check logs:
```bash
log stream --predicate 'process == "DynamicWin"' --level error
```

### Panel Won't Show
- Verify MenuBarController initialized
- Check screen detection (ScreenMonitor)
- Ensure NSPanel created properly

### Preferences Not Saving
- Check UserDefaults permissions
- Verify JSON encoding/decoding
- Check PreferencesManager logic

### Services Not Starting
- Verify MenuBarController calls startBackgroundServices()
- Check service.start() implementations
- Look for initialization order issues

---

## Performance Tuning

### Reduce CPU Usage
```swift
// Decrease polling frequency in Constants.swift
let mediaRefreshInterval: TimeInterval = 2.0  // Increase from 1.0
let bluetoothRefreshInterval: TimeInterval = 10.0  // Increase from 5.0
```

### Reduce Memory
```swift
// Adjust image cache size in ImageCache.swift
let cacheSizeLimit = 50 * 1024 * 1024  // 50MB instead of 100MB
```

### Reduce Disk I/O
- File tray loads/saves less frequently
- Calendar events cached longer
- Preferences only saved on changes

---

## CI/CD Setup

For GitHub Actions (optional):

```yaml
name: Build & Test
on: [push, pull_request]
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: swift build
      - name: Test
        run: swift test
```

---

## Deployment Checklist

Before v1.0 release:
- [ ] All phases complete
- [ ] Clean build passes
- [ ] All tests pass
- [ ] No compiler warnings
- [ ] Documentation complete
- [ ] README updated
- [ ] Git history clean
- [ ] Code reviewed

---

**Happy building! 🚀**
