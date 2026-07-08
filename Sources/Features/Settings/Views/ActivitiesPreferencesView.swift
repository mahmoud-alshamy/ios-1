import SwiftUI

struct ActivitiesPreferencesView: View {
    @ObservedObject var preferencesManager: PreferencesManager

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Enable/Disable Activities")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Activity.allCases, id: \.self) { activity in
                    HStack(spacing: 12) {
                        Image(systemName: activity.systemImage)
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 24, height: 24)
                            .foregroundColor(.accentColor)

                        Toggle(isOn: binding(for: activity)) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(activity.displayName)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                Text(activityDescription(for: activity))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .toggleStyle(.checkbox)
                    }
                    .padding(12)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                }
            }

            Spacer()

            Text("At least one activity must be enabled")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private func binding(for activity: Activity) -> Binding<Bool> {
        Binding(
            get: { preferencesManager.preferences.enabledActivities.contains(activity) },
            set: { isEnabled in
                if isEnabled {
                    preferencesManager.updatePreferences { prefs in
                        prefs.enabledActivities.insert(activity)
                    }
                } else if preferencesManager.preferences.enabledActivities.count > 1 {
                    preferencesManager.updatePreferences { prefs in
                        prefs.enabledActivities.remove(activity)
                    }
                }
            }
        )
    }

    private func activityDescription(for activity: Activity) -> String {
        switch activity {
        case .media: return "Control music and media playback"
        case .calendar: return "View today's and upcoming events"
        case .fileTray: return "Quick access to your files"
        case .bluetooth: return "Monitor Bluetooth devices"
        }
    }
}
