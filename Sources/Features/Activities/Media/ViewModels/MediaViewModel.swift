import Foundation
import Combine

@MainActor
class MediaViewModel: ObservableObject {
    @Published var track: MediaTrack?
    @Published var isPlaying: Bool = false
    @Published var isFavorite: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String?

    private let service: MediaPlayerService
    private var cancellables = Set<AnyCancellable>()

    init(service: MediaPlayerService) {
        self.service = service
        setupSubscriptions()
    }

    private func setupSubscriptions() {
        service.$currentTrack
            .assign(to: &$track)

        service.$isPlaying
            .assign(to: &$isPlaying)

        service.$isFavorite
            .assign(to: &$isFavorite)

        Logger.log("MediaViewModel initialized", category: "MediaViewModel")
    }

    func togglePlayPause() {
        Task {
            do {
                if isPlaying {
                    try await service.pause()
                } else {
                    try await service.play()
                }
            } catch {
                self.error = error.localizedDescription
                Logger.logError(error, category: "MediaViewModel")
            }
        }
    }

    func nextTrack() {
        Task {
            do {
                try await service.nextTrack()
            } catch {
                self.error = error.localizedDescription
                Logger.logError(error, category: "MediaViewModel")
            }
        }
    }

    func previousTrack() {
        Task {
            do {
                try await service.previousTrack()
            } catch {
                self.error = error.localizedDescription
                Logger.logError(error, category: "MediaViewModel")
            }
        }
    }

    func toggleFavorite() {
        guard let track = track else { return }
        Task {
            do {
                try await service.toggleFavorite(track)
            } catch {
                self.error = error.localizedDescription
                Logger.logError(error, category: "MediaViewModel")
            }
        }
    }
}
