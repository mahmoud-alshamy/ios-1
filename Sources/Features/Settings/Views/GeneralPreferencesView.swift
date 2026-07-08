import SwiftUI

struct GeneralPreferencesView: View {
    @ObservedObject var preferencesManager: PreferencesManager
    @State private var selectedTheme: Theme

    init(preferencesManager: PreferencesManager) {
        self.preferencesManager = preferencesManager
        _selectedTheme = State(initialValue: preferencesManager.preferences.theme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("General Settings")
                .font(.headline)

            // Theme Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Appearance")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Picker("Theme", selection: $selectedTheme) {
                    Text("Auto").tag(Theme.auto)
                    Text("Light").tag(Theme.light)
                    Text("Dark").tag(Theme.dark)
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedTheme) { newTheme in
                    preferencesManager.updatePreferences { prefs in
                        prefs.theme = newTheme
                    }
                }
            }
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)

            // Startup Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Launch Behavior")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Toggle(isOn: binding(for: \.autoLaunchOnStartup)) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Launch at Login")
                            .font(.body)
                        Text("Automatically start DynamicWin when you log in")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(.checkbox)

                Toggle(isOn: binding(for: \.startMinimized)) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Start in Background")
                            .font(.body)
                        Text("Hide the panel when the app starts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(.checkbox)
            }
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)

            Spacer()

            Text("Changes are saved automatically")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private func binding<T>(for keyPath: WritableKeyPath<AppPreferences, T>) -> Binding<T> {
        Binding(
            get: { preferencesManager.preferences[keyPath: keyPath] },
            set: { newValue in
                preferencesManager.updatePreferences { prefs in
                    prefs[keyPath: keyPath] = newValue
                }
            }
        )
    }
}
