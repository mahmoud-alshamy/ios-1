import AppKit

/// Hosts the SwiftUI notch and makes the transparent surround click-through.
/// Only points inside `interactiveFrame` (the live notch bounds) are captured;
/// everything else passes clicks to whatever is behind the overlay.
final class NotchContainerView: NSView {
    /// Live interactive region in this view's (flipped, top-left origin) coordinates.
    var interactiveFrame: CGRect = .zero

    override var isFlipped: Bool { true }

    override func hitTest(_ point: NSPoint) -> NSView? {
        // `point` arrives in the superview's coordinate system.
        let local = convert(point, from: superview)
        guard interactiveFrame.contains(local) else { return nil }
        return super.hitTest(point)
    }
}
