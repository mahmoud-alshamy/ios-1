import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// The entire visual application: the notch itself.
///
/// Idle → invisible, camouflaged over the hardware notch.
/// Hover → reveals the compact programmed notch.
/// Open → full activity panel.
struct NotchRootView: View {
    @ObservedObject var vm: NotchViewModel
    let geometry: NotchGeometry
    var onOpenPreferences: () -> Void

    @State private var isDropTargeted = false

    private var size: CGSize {
        switch vm.state {
        case .idle: return geometry.idle
        case .hover: return geometry.peek
        case .open: return geometry.open
        }
    }

    private var topRadius: CGFloat {
        switch vm.state {
        case .idle: return 2
        case .hover: return 8
        case .open: return 10
        }
    }

    private var bottomRadius: CGFloat {
        switch vm.state {
        case .idle: return 10
        case .hover: return 14
        case .open: return 22
        }
    }

    private var shape: NotchShape {
        NotchShape(topCornerRadius: topRadius, bottomCornerRadius: bottomRadius)
    }

    var body: some View {
        ZStack(alignment: .top) {
            shape
                .fill(Color.black)
                .overlay(
                    Group {
                        switch vm.state {
                        case .idle:
                            Color.clear
                        case .hover:
                            NotchCompactView(vm: vm, topInset: geometry.contentTopInset)
                        case .open:
                            NotchExpandedView(vm: vm, topInset: geometry.contentTopInset)
                        }
                    }
                    .clipShape(shape)
                )
                .frame(width: size.width, height: size.height)
                .shadow(color: .black.opacity(vm.state == .open ? 0.55 : 0.0),
                        radius: vm.state == .open ? 16 : 0,
                        x: 0, y: vm.state == .open ? 8 : 0)
                .contentShape(shape)
                .onTapGesture { vm.toggle() }
                .onHover { isHovering in
                    if isHovering { vm.hoverBegan() } else { vm.hoverEnded() }
                }
                .contextMenu {
                    Button("Preferences…") { onOpenPreferences() }
                    Divider()
                    Button("Quit DynamicWin") { NSApplication.shared.terminate(nil) }
                }
                // Dragging a file over the notch reveals the File Tray; dropping adds it.
                .onDrop(of: [UTType.fileURL], isTargeted: $isDropTargeted) { providers in
                    FileDropHandler.handle(providers) { urls in
                        for url in urls {
                            try? vm.services.fileTrayService.addFile(url)
                        }
                    }
                }
                .onChange(of: isDropTargeted) { targeted in
                    if targeted { vm.switchTo(.fileTray) }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.spring(response: 0.4, dampingFraction: 0.82), value: vm.state)
    }
}
