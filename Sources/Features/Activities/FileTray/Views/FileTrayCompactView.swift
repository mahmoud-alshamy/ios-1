import SwiftUI

struct FileTrayCompactView: View {
    @ObservedObject var viewModel: FileTrayViewModel

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if viewModel.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.system(size: 12, weight: .medium))
                        Text("Empty Tray")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.secondary)
                } else if let recent = viewModel.recentFile {
                    HStack(spacing: 6) {
                        if let icon = recent.icon {
                            Image(nsImage: icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        } else {
                            Image(systemName: "doc.fill")
                                .font(.system(size: 12, weight: .medium))
                        }
                        Text(recent.name)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                    if viewModel.fileCount > 1 {
                        HStack(spacing: 4) {
                            Text("+\(viewModel.fileCount - 1)")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.8, anchor: .center)
                    .frame(width: 16, height: 16)
            }
        }
        .frame(height: 32)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
