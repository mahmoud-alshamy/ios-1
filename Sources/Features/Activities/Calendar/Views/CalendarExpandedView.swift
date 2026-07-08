import SwiftUI

struct CalendarExpandedView: View {
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading calendar...")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .controlBackgroundColor))
            } else if let error = viewModel.error {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.red)
                    Text("Calendar Error")
                        .font(.system(.headline, design: .rounded))
                    Text(error)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .controlBackgroundColor))
            } else if viewModel.allEvents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text("No Events")
                        .font(.system(.headline, design: .rounded))
                    Text("Your calendar is empty")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .controlBackgroundColor))
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.allEvents) { event in
                            CalendarEventRow(event: event)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                            Divider()
                                .padding(.horizontal, 12)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .background(Color(nsColor: .controlBackgroundColor))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CalendarEventRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10, weight: .medium))
                        Text(event.formattedTime)
                            .font(.system(.caption2, design: .monospaced))
                    }
                    .foregroundColor(.secondary)

                    if let location = event.location, !location.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 10, weight: .medium))
                            Text(location)
                                .font(.system(.caption2, design: .rounded))
                                .lineLimit(1)
                        }
                        .foregroundColor(.secondary)
                    }

                    if !event.attendees.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 10, weight: .medium))
                            Text("\(event.attendees.count)")
                                .font(.system(.caption2, design: .monospaced))
                        }
                        .foregroundColor(.secondary)
                    }
                }

                if event.isInProgress {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        Text("In Progress")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.green)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Circle()
                .fill(Color(nsColor: event.color))
                .frame(width: 12, height: 12)
        }
        .padding(.vertical, 8)
    }
}
