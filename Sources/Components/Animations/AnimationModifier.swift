import SwiftUI

struct ScaleAndFadeAnimation: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.0 : 0.95)
            .opacity(isAnimating ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.easeOut(duration: AppConstants.Animation.expandDuration)) {
                    isAnimating = true
                }
            }
    }
}

extension View {
    func scaleAndFadeIn() -> some View {
        modifier(ScaleAndFadeAnimation())
    }
}

struct SlideAnimation: ViewModifier {
    @State private var isAnimating = false
    let direction: SlideDirection

    enum SlideDirection {
        case fromLeft, fromRight, fromTop, fromBottom
    }

    func body(content: Content) -> some View {
        content
            .offset(offset)
            .opacity(isAnimating ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.easeOut(duration: AppConstants.Animation.expandDuration)) {
                    isAnimating = true
                }
            }
    }

    var offset: CGSize {
        guard !isAnimating else { return .zero }
        switch direction {
        case .fromLeft:
            return CGSize(width: -50, height: 0)
        case .fromRight:
            return CGSize(width: 50, height: 0)
        case .fromTop:
            return CGSize(width: 0, height: -50)
        case .fromBottom:
            return CGSize(width: 0, height: 50)
        }
    }
}

extension View {
    func slideInAnimation(direction: SlideAnimation.SlideDirection) -> some View {
        modifier(SlideAnimation(direction: direction))
    }
}
