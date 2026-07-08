import SwiftUI
import AppKit

/// The entire visual application: the notch itself.
struct NotchRootView: View {
    @ObservedObject var vm: NotchViewModel
    let geometry: NotchGeometry
    var onOpenPreferences: () -> Void

    @State private var hovering = false

    private var size: CGSize {
        switch vm.state {
        case .open: return geometry.open
        case .closed: return hovering ? geometry.peek : geometry.closed
        }
    }

    private var bottomRadius: CGFloat {
        vm.state == .open ? 22 : 10
    }

    private var shape: NotchShape {
        NotchShape(topCornerRadius: 9, bottomCornerRadius: bottomRadius)
    }

    var body: some View {
        ZStack(alignment: .top) {
            shape
                .fill(Color.black)
                .overlay(
                    Group {
                        if vm.state == .open {
                            NotchExpandedView(vm: vm, topInset: geometry.contentTopInset)
                        } else {
                            NotchCompactView(vm: vm, hovering: hovering, topInset: geometry.contentTopInset)
                        }
                    }
                    .clipShape(shape)
                )
                .frame(width: size.width, height: size.height)
                .shadow(color: .black.opacity(vm.state == .open ? 0.55 : 0.25),
                        radius: vm.state == .open ? 16 : 6,
                        x: 0, y: vm.state == .open ? 8 : 3)
                .contentShape(shape)
                .onTapGesture { vm.toggle() }
                .onHover { isHovering in
                    hovering = isHovering
                }
                .contextMenu {
                    Button("Preferences…") { onOpenPreferences() }
                    Divider()
                    Button("Quit DynamicWin") { NSApplication.shared.terminate(nil) }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: vm.state)
        .animation(.spring(response: 0.32, dampingFraction: 0.78), value: hovering)
    }
}
