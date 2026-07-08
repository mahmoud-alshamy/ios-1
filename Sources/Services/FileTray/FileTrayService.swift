import Foundation
import AppKit
import Combine

enum FileTrayError: Error, LocalizedError {
    case fileNotFound
    case fileAlreadyExists
    case maxFilesExceeded
    case invalidFile
    case persistenceError(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound: return "File not found"
        case .fileAlreadyExists: return "File already in tray"
        case .maxFilesExceeded: return "Tray is full (max 30 files)"
        case .invalidFile: return "Invalid or inaccessible file"
        case .persistenceError(let msg): return "Storage error: \(msg)"
        }
    }
}

class FileTrayService: BackgroundService {
    @Published private(set) var items: [FileTrayItem] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?

    private static let storageKey = "com.dynamicwin.filetray.items"
    private static let maxFiles = 30
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        Logger.log("FileTrayService initialized", category: "FileTrayService")
    }

    func start() {
        Logger.log("FileTrayService started", category: "FileTrayService")
        loadItems()
    }

    func stop() {
        Logger.log("FileTrayService stopped", category: "FileTrayService")
        saveItems()
    }

    func addFile(_ url: URL) throws {
        guard url.isFileURL else {
            throw FileTrayError.invalidFile
        }

        guard FileManager.default.fileExists(atPath: url.path) else {
            throw FileTrayError.fileNotFound
        }

        guard !items.contains(where: { $0.url == url }) else {
            throw FileTrayError.fileAlreadyExists
        }

        guard items.count < Self.maxFiles else {
            throw FileTrayError.maxFilesExceeded
        }

        let newItem = FileTrayItem(url: url)
        DispatchQueue.main.async {
            self.items.insert(newItem, at: 0)
            self.saveItems()
        }

        Logger.log("File added to tray: \(url.lastPathComponent)", category: "FileTrayService")
    }

    func removeFile(_ item: FileTrayItem) throws {
        DispatchQueue.main.async {
            self.items.removeAll { $0.id == item.id }
            self.saveItems()
        }

        Logger.log("File removed from tray: \(item.name)", category: "FileTrayService")
    }

    func openFile(_ item: FileTrayItem) throws {
        guard FileManager.default.fileExists(atPath: item.url.path) else {
            throw FileTrayError.fileNotFound
        }

        let success = NSWorkspace.shared.open(item.url)
        guard success else {
            throw FileTrayError.invalidFile
        }

        Logger.log("File opened: \(item.name)", category: "FileTrayService")
    }

    func revealInFinder(_ item: FileTrayItem) throws {
        guard FileManager.default.fileExists(atPath: item.url.path) else {
            throw FileTrayError.fileNotFound
        }

        NSWorkspace.shared.selectFile(item.url.path, inFileViewerRootedAtPath: "")
        Logger.log("File revealed in Finder: \(item.name)", category: "FileTrayService")
    }

    func clearAll() {
        DispatchQueue.main.async {
            self.items.removeAll()
            self.saveItems()
        }

        Logger.log("File tray cleared", category: "FileTrayService")
    }

    private func loadItems() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = true
            }

            if let data = self.userDefaults.data(forKey: Self.storageKey) {
                do {
                    let decoder = JSONDecoder()
                    let decodedItems = try decoder.decode([FileTrayItem].self, from: data)
                    DispatchQueue.main.async {
                        self.items = decodedItems.filter { FileManager.default.fileExists(atPath: $0.url.path) }
                        self.isLoading = false
                    }
                    Logger.log("Loaded \(self.items.count) file tray items", category: "FileTrayService")
                } catch {
                    DispatchQueue.main.async {
                        self.error = FileTrayError.persistenceError(error.localizedDescription)
                        self.isLoading = false
                    }
                    Logger.log("Failed to load file tray: \(error)", level: .error, category: "FileTrayService")
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                Logger.log("No saved file tray items found", category: "FileTrayService")
            }
        }
    }

    private func saveItems() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(items)
            userDefaults.set(data, forKey: Self.storageKey)
            Logger.log("File tray saved (\(items.count) items)", category: "FileTrayService")
        } catch {
            Logger.log("Failed to save file tray: \(error)", level: .error, category: "FileTrayService")
            DispatchQueue.main.async {
                self.error = FileTrayError.persistenceError(error.localizedDescription)
            }
        }
    }
}
