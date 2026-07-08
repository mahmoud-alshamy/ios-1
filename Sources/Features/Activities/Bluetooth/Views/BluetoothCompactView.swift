import SwiftUI

struct BluetoothCompactView: View {
    @ObservedObject var viewModel: BluetoothViewModel

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if let primary = viewModel.primaryDevice {
                    HStack(spacing: 6) {
                        Image(systemName: primary.deviceType.systemImage)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.green)
                        Text(primary.name)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                    if let battery = primary.batteryText {
                        HStack(spacing: 4) {
                            Image(systemName: batteryIcon(for: primary.batteryLevel ?? 0))
                                .font(.system(size: 10, weight: .medium))
                            Text(battery)
                                .font(.system(.caption2, design: .monospaced))
                        }
                        .foregroundColor(.secondary)
                    }
                } else if viewModel.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8, anchor: .center)
                        Text("Scanning...")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.secondary)
                } else if let _ = viewModel.error {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 12, weight: .medium))
                        Text("BT Error")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.orange)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "bluetooth")
                            .font(.system(size: 12, weight: .medium))
                        Text("No Devices")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.connectedCount > 1 {
                HStack(spacing: 4) {
                    Text("+\(viewModel.connectedCount - 1)")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(height: 32)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func batteryIcon(for level: Int) -> String {
        switch level {
        case 75...100: return "battery.100percent"
        case 50...74: return "battery.75percent"
        case 25...49: return "battery.50percent"
        case 0...24: return "battery.25percent"
        default: return "battery.0percent"
        }
    }
}
