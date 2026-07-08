import SwiftUI

struct FileTrayExpandedView: View {
    @ObservedObject var viewModel: FileTrayViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading files...")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .controlBackgroundColor))
            } else if let error = viewModel.error {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.red)
                    Text("File Tray Error")
                        .font(.system(.headline, design: .rounded))
                    Text(error)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .controlBackgroundColor))
            } else if viewModel.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text("File Tray Empty")
                        .font(.system(.headline, design: .rounded))
                    Text("Drag files here or add from Finder")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .controlBackgroundColor))
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.items) { item in
                            FileTrayItemRow(item: item, viewModel: viewModel)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                            Divider()
                                .padding(.horizontal, 12)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .background(Color(nsColor: .controlBackgroundColor))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FileTrayItemRow: View {
    let item: FileTrayItem
    @ObservedObject var viewModel: FileTrayViewModel
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 12) {
            if let icon = item.icon {
                Image(nsImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            } else {
                Image(systemName: "doc.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 10, weight: .medium))
                        Text(item.fileType.isEmpty ? "file" : item.fileType)
                            .font(.system(.caption2, design: .monospaced))
                    }
                    .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: "internaldrive")
                            .font(.system(size: 10, weight: .medium))
                        Text(item.formattedSize)
                            .font(.system(.caption2, design: .monospaced))
                    }
                    .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if isHovering {
                Menu {
                    Button(action: { viewModel.openFile(item) }) {
                        Label("Open", systemImage: "doc.richtext")
                    }
                    Button(action: { viewModel.revealInFinder(item) }) {
                        Label("Reveal in Finder", systemImage: "folder")
                    }
                    Divider()
                    Button(action: { viewModel.removeFile(item) }, label: {
                        Label("Remove", systemImage: "trash")
                    })
                    .foregroundColor(.red)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            }
        }
        .padding(.vertical, 8)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
