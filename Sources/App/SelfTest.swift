import AppKit

/// Lightweight logic verification that runs without XCTest (unavailable under
/// Command Line Tools). Launch with `--self-test` to exercise the notch state
/// machine and geometry, print PASS/FAIL per case, and exit with the failure count.
enum SelfTest {
    @MainActor
    static func run() -> Int {
        var failures = 0
        func check(_ name: String, _ condition: Bool) {
            print("\(condition ? "PASS" : "FAIL")  \(name)")
            if !condition { failures += 1 }
        }

        let services = DefaultServiceProvider()
        services.preferencesManager.loadPreferences()
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

        // MARK: Enabled-activity filtering
        services.preferencesManager.updatePreferences {
            $0.enabledActivities = [.media, .fileTray]
        }
        check("enabled filter respects preferences", vm.enabledActivities == [.media, .fileTray])

        services.preferencesManager.updatePreferences { $0.enabledActivities = [] }
        check("empty preferences falls back to all activities", vm.enabledActivities.count == 4)

        // MARK: Geometry
        let geo = NotchGeometry.current(for: nil)
        check("idle width <= peek width", geo.idle.width <= geo.peek.width)
        check("peek width < open width", geo.peek.width < geo.open.width)
        check("idle height <= peek height", geo.idle.height <= geo.peek.height)
        check("content inset clears the notch", geo.contentTopInset == geo.notchHeight)
        check("window fits the open panel",
              geo.windowSize.width >= geo.open.width && geo.windowSize.height >= geo.open.height)

        print(failures == 0
              ? "\n✅ ALL \(0) FAILURES — logic OK"
              : "\n❌ \(failures) FAILURE(S)")
        return failures
    }
}
