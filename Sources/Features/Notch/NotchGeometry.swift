import AppKit

/// Notch sizing derived from the real hardware notch of the target display.
///
/// The overlay is intentionally larger than the physical notch: it is wider
/// (so it wraps around the hardware cutout with visible "ears") and taller
/// (so content sits *below* the physical bezel line and is never hidden).
struct NotchGeometry {
    /// Measured width of the physical notch (or a simulated value).
    let notchWidth: CGFloat
    /// Height of the physical notch / menu-bar band (safe-area top inset).
    let notchHeight: CGFloat
    /// Whether the target display actually has a hardware notch.
    let hasHardwareNotch: Bool

    /// Camouflage size — matches the hardware notch so the overlay is invisible while idle.
    let idle: CGSize
    let peek: CGSize
    let open: CGSize
    let windowSize: CGSize

    /// Y offset where drawable content must start so it clears the physical notch.
    let contentTopInset: CGFloat

    static func current(for screen: NSScreen?) -> NotchGeometry {
        let target = screen ?? NSScreen.main
        let safeTop = target?.safeAreaInsets.top ?? 0
        let hasNotch = safeTop > 0

        // Measure the hardware notch width from the two menu-bar areas that
        // flank it. The gap between them is the notch itself.
        var measuredWidth: CGFloat = 200
        if #available(macOS 12.0, *),
           let target,
           let left = target.auxiliaryTopLeftArea,
           let right = target.auxiliaryTopRightArea {
            let gap = right.minX - left.maxX
            if gap > 0 { measuredWidth = gap }
        }

        let notchHeight = hasNotch ? safeTop : 32
        let notchWidth = measuredWidth

        // Idle exactly matches the hardware notch so the overlay disappears into it.
        let idle = CGSize(width: notchWidth, height: notchHeight)
        // Reveal states wrap the hardware notch: wider on both sides, below the bezel.
        let peek = CGSize(width: notchWidth + 104, height: notchHeight + 52)
        let open = CGSize(width: max(620, notchWidth + 360), height: notchHeight + 178)

        // Fixed window big enough for the open state plus shadow / corner flares.
        let windowSize = CGSize(
            width: max(open.width, peek.width) + 200,
            height: open.height + 140
        )

        return NotchGeometry(
            notchWidth: notchWidth,
            notchHeight: notchHeight,
            hasHardwareNotch: hasNotch,
            idle: idle,
            peek: peek,
            open: open,
            windowSize: windowSize,
            contentTopInset: notchHeight
        )
    }
}
