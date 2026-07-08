import SwiftUI

@main
struct DynamicWinApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        if CommandLine.arguments.contains("--self-test") {
            let failures = SelfTest.run()
            exit(Int32(failures == 0 ? 0 : 1))
        }
    }

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
