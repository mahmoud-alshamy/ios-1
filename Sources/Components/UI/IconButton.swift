import SwiftUI

struct IconButton: View {
    let icon: String
    let action: () -> Void
    let isActive: Bool
    let helpText: String?

    init(
        icon: String,
        isActive: Bool = false,
        helpText: String? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.isActive = isActive
        self.helpText = helpText
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(isActive ? .accentColor : .primary)
                .frame(height: 20)
        }
        .help(helpText ?? "")
        .buttonStyle(.plain)
    }
}
