import Foundation
import Combine

class UpdateCheckService {
    @Published var updateAvailable: Bool = false
    @Published var latestVersion: String = AppConstants.appVersion

    init() { Logger.log("UpdateCheckService initialized", category: "UpdateCheckService") }
    func checkForUpdates() async throws { Logger.log("Checking for updates", category: "UpdateCheckService") }
    func downloadUpdate() async throws { Logger.log("Downloading update", category: "UpdateCheckService") }
}
