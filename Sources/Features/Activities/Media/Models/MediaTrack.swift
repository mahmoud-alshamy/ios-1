import Foundation
import AppKit

struct MediaTrack: Identifiable {
    let id: UUID = UUID()
    let title: String
    let artist: String
    let album: String
    let artwork: NSImage?
    let duration: TimeInterval
    let isPlaying: Bool
    var isFavorite: Bool = false

    init(title: String, artist: String, album: String, artwork: NSImage? = nil, duration: TimeInterval = 0, isPlaying: Bool = false, isFavorite: Bool = false) {
        self.title = title
        self.artist = artist
        self.album = album
        self.artwork = artwork
        self.duration = duration
        self.isPlaying = isPlaying
        self.isFavorite = isFavorite
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
