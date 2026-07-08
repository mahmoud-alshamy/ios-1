import Foundation
import AppKit
import Combine

/// Controls the real system music players (Apple Music / Spotify) via AppleScript.
/// Public API is unchanged from the Phase 3 service, so ViewModels/Views are untouched.
class MediaPlayerService: BackgroundService, ObservableObject {
    @Published var currentTrack: MediaTrack?
    @Published var isPlaying: Bool = false
    @Published var isFavorite: Bool = false

    private enum Player: String {
        case spotify = "Spotify"
        case music = "Music"

        var bundleID: String {
            switch self {
            case .spotify: return "com.spotify.client"
            case .music: return "com.apple.Music"
            }
        }
    }

    private struct Snapshot {
        let player: Player
        let title: String
        let artist: String
        let album: String
        let duration: TimeInterval
        let isPlaying: Bool
        let isFavorite: Bool?
        let artworkURL: String?
    }

    private var updateTimer: Timer?
    private let scriptQueue = DispatchQueue(label: "com.dynamicwin.media.osascript", qos: .userInitiated)
    private var activePlayer: Player?
    private var artworkKey: String?
    private var artworkImage: NSImage?

    init() {
        Logger.log("MediaPlayerService initialized", category: "MediaService")
    }

    func start() {
        Logger.log("MediaPlayerService started", category: "MediaService")
        startPolling()
        refreshAsync()
    }

    func stop() {
        updateTimer?.invalidate()
        updateTimer = nil
        Logger.log("MediaPlayerService stopped", category: "MediaService")
    }

    // MARK: - Public Commands (API unchanged)

    func play() async throws {
        await MainActor.run { self.isPlaying = true }
        command("play")
    }

    func pause() async throws {
        await MainActor.run { self.isPlaying = false }
        command("pause")
    }

    func nextTrack() async throws {
        command("next track")
    }

    func previousTrack() async throws {
        command("previous track")
    }

    func toggleFavorite(_ track: MediaTrack) async throws {
        Logger.log("Toggle favorite for: \(track.title)", category: "MediaService")
        if activePlayer == .music {
            // Music supports favorites; newer systems use `favorited`, older `loved`.
            let script = """
            tell application "Music"
                try
                    set favorited of current track to not (favorited of current track)
                on error
                    try
                        set loved of current track to not (loved of current track)
                    end try
                end try
            end tell
            """
            scriptQueue.async { [weak self] in
                _ = self?.runScript(script)
                self?.fetchAndPublish()
            }
        }
        // Spotify exposes no favorite API via AppleScript; keep a local toggle.
        await MainActor.run { self.isFavorite.toggle() }
    }

    // MARK: - Polling

    private func startPolling() {
        updateTimer = Timer.scheduledTimer(
            withTimeInterval: AppConstants.RefreshIntervals.media,
            repeats: true
        ) { [weak self] _ in
            self?.refreshAsync()
        }
    }

    private func refreshAsync() {
        scriptQueue.async { [weak self] in
            self?.fetchAndPublish()
        }
    }

    private func command(_ verb: String) {
        let player = activePlayer ?? .music
        scriptQueue.async { [weak self] in
            _ = self?.runScript("tell application \"\(player.rawValue)\" to \(verb)")
            self?.fetchAndPublish()
        }
    }

    // MARK: - Now Playing

    /// Runs on `scriptQueue`.
    private func fetchAndPublish() {
        let snapshot = fetchSnapshot()
        let artwork = loadArtwork(for: snapshot)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.activePlayer = snapshot?.player
            self.isPlaying = snapshot?.isPlaying ?? false
            if let favorite = snapshot?.isFavorite { self.isFavorite = favorite }

            guard let snap = snapshot else {
                if self.currentTrack != nil { self.currentTrack = nil }
                return
            }

            // Only republish when something visible actually changed.
            let changed = self.currentTrack?.title != snap.title
                || self.currentTrack?.artist != snap.artist
                || self.currentTrack?.album != snap.album
                || self.currentTrack?.isPlaying != snap.isPlaying
                || (self.currentTrack?.artwork == nil) != (artwork == nil)

            if changed {
                self.currentTrack = MediaTrack(
                    title: snap.title,
                    artist: snap.artist,
                    album: snap.album,
                    artwork: artwork,
                    duration: snap.duration,
                    isPlaying: snap.isPlaying,
                    isFavorite: self.isFavorite
                )
            }
        }
    }

    /// Prefers a currently *playing* player; falls back to any running player with a track.
    private func fetchSnapshot() -> Snapshot? {
        let running = Set(NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier))
        var candidates: [Player] = []
        if running.contains(Player.spotify.bundleID) { candidates.append(.spotify) }
        if running.contains(Player.music.bundleID) { candidates.append(.music) }
        guard !candidates.isEmpty else { return nil }

        var fallback: Snapshot?
        for player in candidates {
            guard let snap = query(player) else { continue }
            if snap.isPlaying { return snap }
            if fallback == nil { fallback = snap }
        }
        return fallback
    }

    private func query(_ player: Player) -> Snapshot? {
        let script: String
        switch player {
        case .spotify:
            script = """
            tell application "Spotify"
                if player state is stopped then return "stopped"
                set t to current track
                return (player state as text) & "||" & (name of t) & "||" & (artist of t) & "||" & (album of t) & "||" & ((duration of t) as text) & "||" & (artwork url of t)
            end tell
            """
        case .music:
            script = """
            tell application "Music"
                if player state is stopped then return "stopped"
                set t to current track
                set fav to "?"
                try
                    set fav to (favorited of t) as text
                on error
                    try
                        set fav to (loved of t) as text
                    end try
                end try
                return (player state as text) & "||" & (name of t) & "||" & (artist of t) & "||" & (album of t) & "||" & ((duration of t) as text) & "||" & fav
            end tell
            """
        }

        guard let output = runScript(script), output != "stopped", !output.isEmpty else { return nil }
        let parts = output.components(separatedBy: "||")
        guard parts.count >= 6 else { return nil }

        let playing = parts[0] == "playing"
        var duration = TimeInterval(parts[4].replacingOccurrences(of: ",", with: ".")) ?? 0

        switch player {
        case .spotify:
            duration /= 1000 // Spotify reports milliseconds.
            return Snapshot(
                player: .spotify, title: parts[1], artist: parts[2], album: parts[3],
                duration: duration, isPlaying: playing, isFavorite: nil, artworkURL: parts[5]
            )
        case .music:
            let favorite: Bool? = parts[5] == "true" ? true : (parts[5] == "false" ? false : nil)
            return Snapshot(
                player: .music, title: parts[1], artist: parts[2], album: parts[3],
                duration: duration, isPlaying: playing, isFavorite: favorite, artworkURL: nil
            )
        }
    }

    /// Runs on `scriptQueue`. Downloads Spotify artwork once per track and caches it.
    private func loadArtwork(for snapshot: Snapshot?) -> NSImage? {
        guard let key = snapshot?.artworkURL, let url = URL(string: key) else {
            return snapshot?.player == .music ? artworkForCurrentMusicTrack() : nil
        }
        if key == artworkKey { return artworkImage }
        guard let data = try? Data(contentsOf: url), let image = NSImage(data: data) else { return nil }
        artworkKey = key
        artworkImage = image
        return image
    }

    /// Music has no artwork URL; leave nil (UI shows its placeholder).
    private func artworkForCurrentMusicTrack() -> NSImage? { nil }

    // MARK: - osascript

    private func runScript(_ source: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", source]
        let out = Pipe()
        process.standardOutput = out
        process.standardError = Pipe()
        do {
            try process.run()
        } catch {
            Logger.log("osascript launch failed: \(error)", level: .error, category: "MediaService")
            return nil
        }
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { return nil }
        let data = out.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
