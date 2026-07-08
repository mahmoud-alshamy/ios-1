import SwiftUI

struct ActivityDots: View {
    let activities: [Activity]
    let currentActivity: Activity
    let onActivitySelected: (Activity) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(activities, id: \.self) { activity in
                Circle()
                    .fill(
                        activity == currentActivity ?
                        Color.accentColor :
                        Color.secondary.opacity(0.3)
                    )
                    .frame(width: 6, height: 6)
                    .scaleEffect(activity == currentActivity ? 1.2 : 1.0)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            onActivitySelected(activity)
                        }
                    }
            }
        }
    }
}
