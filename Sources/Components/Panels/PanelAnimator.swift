import AppKit

struct PanelAnimator {
    static func animateExpand(
        window: NSWindow,
        from origin: NSPoint,
        to destination: NSPoint,
        size: NSSize,
        duration: TimeInterval = AppConstants.Animation.expandDuration
    ) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(
                name: .easeOut
            )

            window.animator().setFrame(
                NSRect(origin: destination, size: size),
                display: true
            )
        }

        Logger.log("Panel expanded", category: "PanelAnimator")
    }

    static func animateCollapse(
        window: NSWindow,
        to menuBarPoint: NSPoint,
        compactSize: NSSize,
        duration: TimeInterval = AppConstants.Animation.collapseDuration
    ) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(
                name: .easeIn
            )

            window.animator().setFrame(
                NSRect(origin: menuBarPoint, size: compactSize),
                display: true
            )
        }

        Logger.log("Panel collapsed", category: "PanelAnimator")
    }
}
