import SwiftUI

struct FadeThroughTransition {
    static var transition: AnyTransition {
        .asymmetric(
            insertion: .opacity.animation(.easeIn(duration: 0.1)),
            removal: .opacity.animation(.easeOut(duration: 0.1))
        )
    }
}

struct SlideTransition {
    static var transition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
    }
}
