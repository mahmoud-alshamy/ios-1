import AppKit

/// Lightweight logic verification that runs without XCTest (unavailable under
/// Command Line Tools). Launch with `--self-test` to exercise the notch state
/// machine, activity navigation, preferences sync, file-tray logic, and
/// geometry, printing PASS/FAIL per case and exiting with the failure count.
///
/// IMPORTANT: this runs against the real UserDefaults, so it snapshots the
/// user's preferences at the start and restores them before exiting.
enum SelfTest {
    @MainActor
    static func run() -> Int {
        var failures = 0
        func check(_ name: String, _ condition: Bool) {
            print("\(condition ? "PASS" : "FAIL")  \(name)")
            if !condition { failures += 1 }
        }
        /// Drains main-queue work scheduled by services / Task { @MainActor }.
        func pump(_ seconds: TimeInterval = 0.2) {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }

        let services = DefaultServiceProvider()
        services.preferencesManager.loadPreferences()
        let originalPreferences = services.preferencesManager.preferences
        defer {
            // Never leave test values in the user's real preferences.
            services.preferencesManager.updatePreferences { $0 = originalPreferences }
        }

        services.preferencesManager.updatePreferences {
            $0.enabledActivities = [.media, .calendar, .fileTray, .bluetooth]
        }

        // MARK: Notch state machine
        let vm = NotchViewModel(services: services)

        check("starts idle (hidden under hardware notch)", vm.state == .idle)

        vm.hoverBegan()
        check("hover reveals the notch", vm.state == .hover)

        vm.hoverEnded()
        check("mouse leaves -> back to idle", vm.state == .idle)

        vm.hoverBegan()
        vm.open()
        check("click opens full panel", vm.state == .open)

        vm.hoverEnded()
        check("hover-end does NOT close an open panel", vm.state == .open)

        vm.close()
        check("close returns to idle", vm.state == .idle)

        vm.toggle()
        check("toggle idle -> open", vm.state == .open)
        vm.toggle()
        check("toggle open -> idle", vm.state == .idle)

        // MARK: Activity navigation
        vm.currentActivity = .media
        vm.next()
        check("next: media -> calendar", vm.currentActivity == .calendar)
        vm.previous()
        check("previous: calendar -> media", vm.currentActivity == .media)

        vm.close()
        vm.switchTo(.bluetooth)
        check("switchTo sets activity", vm.currentActivity == .bluetooth)
        check("switchTo opens the panel", vm.state == .open)

        // MARK: Preferences live-sync
        services.preferencesManager.updatePreferences {
            $0.enabledActivities = [.media, .fileTray]
        }
        pump()
        check("enabled filter respects preferences", vm.enabledActivities == [.media, .fileTray])
        check("disabling the current activity falls back to first enabled", vm.currentActivity == .media)

        services.preferencesManager.updatePreferences { $0.enabledActivities = [] }
        pump()
        check("empty preferences falls back to all activities", vm.enabledActivities.count == 4)

        // MARK: File tray logic (add / duplicate / remove)
        let tray = services.fileTrayService
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("dynamicwin-selftest-\(ProcessInfo.processInfo.processIdentifier).txt")
        try? "selftest".write(to: tmp, atomically: true, encoding: .utf8)

        try? tray.addFile(tmp)
        pump()
        check("file tray: dropped file is stored", tray.items.contains { $0.url == tmp })
        check("file tray: duplicate add is rejected", (try? tray.addFile(tmp)) == nil)

        if let item = tray.items.first(where: { $0.url == tmp }) {
            try? tray.removeFile(item)
            pump()
        }
        check("file tray: remove deletes the item", !tray.items.contains { $0.url == tmp })
        try? FileManager.default.removeItem(at: tmp)

        // MARK: Geometry
        let geo = NotchGeometry.current(for: nil)
        check("idle width <= peek width", geo.idle.width <= geo.peek.width)
        check("peek width < open width", geo.peek.width < geo.open.width)
        check("idle height <= peek height", geo.idle.height <= geo.peek.height)
        check("content inset clears the notch", geo.contentTopInset == geo.notchHeight)
        check("window fits the open panel",
              geo.windowSize.width >= geo.open.width && geo.windowSize.height >= geo.open.height)

        print(failures == 0
              ? "\n✅ ALL CHECKS PASSED — logic OK"
              : "\n❌ \(failures) FAILURE(S)")
        return failures
    }
}
