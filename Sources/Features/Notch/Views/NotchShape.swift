import SwiftUI

/// The signature notch outline: flat top edge flush with the screen,
/// concave flares at the top corners that blend into the display,
/// straight sides, and convex rounded bottom corners.
struct NotchShape: Shape {
    var topCornerRadius: CGFloat = 8
    var bottomCornerRadius: CGFloat = 12

    // Allow the radii to animate as the notch grows/shrinks.
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(topCornerRadius, bottomCornerRadius) }
        set {
            topCornerRadius = newValue.first
            bottomCornerRadius = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let top = min(topCornerRadius, rect.height / 2)
        let bottom = min(bottomCornerRadius, rect.height / 2)

        var path = Path()

        // Start on the screen surface, just left of the notch.
        path.move(to: CGPoint(x: rect.minX - top, y: rect.minY))
        // Concave curve diving down into the notch (top-left).
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.minY + top),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        // Left wall.
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - bottom))
        // Convex bottom-left corner.
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + bottom, y: rect.maxY),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        // Bottom edge.
        path.addLine(to: CGPoint(x: rect.maxX - bottom, y: rect.maxY))
        // Convex bottom-right corner.
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY - bottom),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        // Right wall.
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + top))
        // Concave curve climbing back out to the screen (top-right).
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX + top, y: rect.minY),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        // Top edge across the screen surface back to the start.
        path.closeSubpath()

        return path
    }
}

/// Fixed geometry for the notch across its states.
enum NotchMetrics {
    /// Idle — approximates the physical MacBook notch.
    static let closed = CGSize(width: 210, height: 32)
    /// Hover peek — a subtle grow to signal interactivity.
    static let peek = CGSize(width: 250, height: 42)
    /// Fully open panel hanging below the top edge.
    static let open = CGSize(width: 600, height: 200)

    /// The window is fixed at the open bounding box plus room for shadow/flares.
    static let windowSize = CGSize(width: 760, height: 320)
}
