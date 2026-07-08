import Foundation
import Combine
import AppKit

class MediaPlayerService: BackgroundService, ObservableObject {
    @Published var currentTrack: MediaTrack?
    @Published var isPlaying: Bool = false
    @Published var isFavorite: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private var updateTimer: Timer?

    init() {
        Logger.log("MediaPlayerService initialized", category: "MediaService")
    }

    func start() {
        Logger.log("MediaPlayerService started", category: "MediaService")
        startPolling()
    }

    func stop() {
        updateTimer?.invalidate()
        updateTimer = nil
        Logger.log("MediaPlayerService stopped", category: "MediaService")
    }

    // MARK: - Public Methods

    func play() async throws {
        Logger.log("Play command", category: "MediaService")
        await MainActor.run {
            self.isPlaying = true
        }
    }

    func pause() async throws {
        Logger.log("Pause command", category: "MediaService")
        await MainActor.run {
            self.isPlaying = false
        }
    }

    func nextTrack() async throws {
        Logger.log("Next track command", category: "MediaService")
    }

    func previousTrack() async throws {
        Logger.log("Previous track command", category: "MediaService")
    }

    func toggleFavorite(_ track: MediaTrack) async throws {
        Logger.log("Toggle favorite for: \(track.title)", category: "MediaService")
        await MainActor.run {
            self.isFavorite.toggle()
        }
    }

    // MARK: - Private Methods

    private func startPolling() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateNowPlaying()
        }
    }

    private func updateNowPlaying() {
        // Create a sample track for demonstration
        if currentTrack == nil && !isPlaying {
            DispatchQueue.main.async {
                self.currentTrack = MediaTrack(
                    title: "No Track Playing",
                    artist: "Not connected to a media player",
                    album: "Phase 3 Demo",
                    artwork: nil,
                    duration: 0,
                    isPlaying: false,
                    isFavorite: false
                )
            }
        }
    }
}
