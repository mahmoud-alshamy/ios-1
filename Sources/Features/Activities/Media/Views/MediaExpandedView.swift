import SwiftUI

struct MediaExpandedView: View {
    @ObservedObject var viewModel: MediaViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Large Album Art
            if let artwork = viewModel.track?.artwork {
                Image(nsImage: artwork)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .cornerRadius(8)
                    .clipped()
            } else {
                VStack {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }

            // Track Information
            VStack(spacing: 4) {
                Text(viewModel.track?.title ?? "No Track Playing")
                    .font(.headline)
                    .lineLimit(2)

                Text(viewModel.track?.artist ?? "Unknown Artist")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(viewModel.track?.album ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            // Player Controls
            HStack(spacing: 16) {
                // Favorite Button
                Button(action: { viewModel.toggleFavorite() }) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundColor(viewModel.isFavorite ? .red : .secondary)
                }
                .buttonStyle(.plain)
                .help("Toggle favorite")

                Spacer()

                // Previous Button
                Button(action: { viewModel.previousTrack() }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                .help("Previous track")

                // Play/Pause Button (Large)
                Button(action: { viewModel.togglePlayPause() }) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.accentColor)
                        .cornerRadius(20)
                }
                .buttonStyle(.plain)
                .help(viewModel.isPlaying ? "Pause" : "Play")

                // Next Button
                Button(action: { viewModel.nextTrack() }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                .help("Next track")

                Spacer()

                // Volume Indicator
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)

            Spacer()

            if let error = viewModel.error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .lineLimit(2)
            }
        }
        .padding(16)
    }
}
