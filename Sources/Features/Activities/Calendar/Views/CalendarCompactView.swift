import SwiftUI

struct CalendarCompactView: View {
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if let event = viewModel.currentEvent {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(nsColor: event.color))
                            .frame(width: 8, height: 8)
                        Text("Now: \(event.title)")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                } else if let event = viewModel.nextEvent {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(nsColor: event.color))
                            .frame(width: 8, height: 8)
                        Text(event.formattedTime)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                        Text(event.title)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12, weight: .medium))
                        Text("No Events Today")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.8, anchor: .center)
                    .frame(width: 16, height: 16)
            }
        }
        .frame(height: 32)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
