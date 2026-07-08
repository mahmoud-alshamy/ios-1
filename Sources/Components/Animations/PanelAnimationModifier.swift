import SwiftUI

struct ScaleAndFadeModifier: ViewModifier {
    var isVisible: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1.0 : 0.95)
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.2), value: isVisible)
    }
}

struct SlideAndFadeModifier: ViewModifier {
    var isVisible: Bool
    var direction: Edge = .top

    func body(content: Content) -> some View {
        content
            .offset(y: isVisible ? 0 : (direction == .top ? -20 : 20))
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.3), value: isVisible)
    }
}

struct SpringBounceModifier: ViewModifier {
    var trigger: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(trigger ? 1.05 : 1.0)
            .animation(
                .spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.0),
                value: trigger
            )
    }
}

extension View {
    func scaleAndFade(_ isVisible: Bool) -> some View {
        modifier(ScaleAndFadeModifier(isVisible: isVisible))
    }

    func slideAndFade(_ isVisible: Bool, direction: Edge = .top) -> some View {
        modifier(SlideAndFadeModifier(isVisible: isVisible, direction: direction))
    }

    func springBounce(_ trigger: Bool) -> some View {
        modifier(SpringBounceModifier(trigger: trigger))
    }
}
