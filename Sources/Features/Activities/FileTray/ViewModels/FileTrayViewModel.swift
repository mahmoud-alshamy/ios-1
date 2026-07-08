import Foundation
import Combine

@MainActor
class FileTrayViewModel: ObservableObject {
    @Published var items: [FileTrayItem] = []
    @Published var isLoading: Bool = false
    @Published var error: String?

    private let service: FileTrayService
    private var cancellables = Set<AnyCancellable>()

    init(service: FileTrayService) {
        self.service = service
        setupBindings()
    }

    private func setupBindings() {
        service.$items
            .receive(on: DispatchQueue.main)
            .assign(to: &$items)

        service.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)

        service.$error
            .receive(on: DispatchQueue.main)
            .map { $0?.localizedDescription }
            .assign(to: &$error)
    }

    func addFiles(_ urls: [URL]) {
        for url in urls {
            do {
                try service.addFile(url)
            } catch {
                self.error = error.localizedDescription
                Logger.log("Failed to add file: \(error)", level: .error, category: "FileTrayViewModel")
            }
        }
    }

    func removeFile(_ item: FileTrayItem) {
        do {
            try service.removeFile(item)
        } catch {
            self.error = error.localizedDescription
            Logger.log("Failed to remove file: \(error)", level: .error, category: "FileTrayViewModel")
        }
    }

    func openFile(_ item: FileTrayItem) {
        do {
            try service.openFile(item)
        } catch {
            self.error = error.localizedDescription
            Logger.log("Failed to open file: \(error)", level: .error, category: "FileTrayViewModel")
        }
    }

    func revealInFinder(_ item: FileTrayItem) {
        do {
            try service.revealInFinder(item)
        } catch {
            self.error = error.localizedDescription
            Logger.log("Failed to reveal file: \(error)", level: .error, category: "FileTrayViewModel")
        }
    }

    func clearAll() {
        service.clearAll()
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    var recentFile: FileTrayItem? {
        items.first
    }

    var fileCount: Int {
        items.count
    }
}
