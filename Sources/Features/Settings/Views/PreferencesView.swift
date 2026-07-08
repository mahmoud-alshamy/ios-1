import SwiftUI

struct PreferencesView: View {
    @ObservedObject var preferencesManager: PreferencesManager
    @State private var selectedTab: PreferencesTab = .activities

    enum PreferencesTab {
        case activities, general, about
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ActivitiesPreferencesView(preferencesManager: preferencesManager)
                .tabItem {
                    Label("Activities", systemImage: "square.grid.2x2")
                }
                .tag(PreferencesTab.activities)

            GeneralPreferencesView(preferencesManager: preferencesManager)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(PreferencesTab.general)

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(PreferencesTab.about)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 350)
    }
}
