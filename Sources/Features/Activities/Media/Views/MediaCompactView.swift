import SwiftUI

struct MediaCompactView: View {
    @ObservedObject var viewModel: MediaViewModel

    var body: some View {
        HStack(spacing: 8) {
            // Album Art Thumbnail
            if let artwork = viewModel.track?.artwork {
                Image(nsImage: artwork)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .cornerRadius(4)
            } else {
                Image(systemName: "music.note")
                    .font(.system(size: 14))
                    .frame(width: 32, height: 32)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
            }

            // Track Info
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.track?.title ?? "No Track")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Text(viewModel.track?.artist ?? "Unknown Artist")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Play/Pause Button
            Button(action: { viewModel.togglePlayPause() }) {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}
