import SwiftUI

struct BluetoothExpandedView: View {
    @ObservedObject var viewModel: BluetoothViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Scanning for devices...")
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
                    Text("Bluetooth Error")
                        .font(.system(.headline, design: .rounded))
                    Text(error)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .controlBackgroundColor))
            } else if viewModel.devices.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bluetooth")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text("No Bluetooth Devices")
                        .font(.system(.headline, design: .rounded))
                    Text("No paired devices found")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .controlBackgroundColor))
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        if !viewModel.connectedDevices.isEmpty {
                            Text("CONNECTED")
                                .font(.system(.caption2, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)

                            ForEach(viewModel.connectedDevices) { device in
                                BluetoothDeviceRow(device: device, viewModel: viewModel, isConnected: true)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                Divider()
                                    .padding(.horizontal, 12)
                            }
                        }

                        if !viewModel.disconnectedDevices.isEmpty {
                            Text("PAIRED")
                                .font(.system(.caption2, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)

                            ForEach(viewModel.disconnectedDevices) { device in
                                BluetoothDeviceRow(device: device, viewModel: viewModel, isConnected: false)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                Divider()
                                    .padding(.horizontal, 12)
                            }
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

struct BluetoothDeviceRow: View {
    let device: BluetoothDevice
    @ObservedObject var viewModel: BluetoothViewModel
    let isConnected: Bool
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: device.deviceType.systemImage)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isConnected ? .green : .secondary)
                    Text(device.name)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "network")
                            .font(.system(size: 10, weight: .medium))
                        Text(isConnected ? "Connected" : "Paired")
                            .font(.system(.caption2, design: .rounded))
                    }
                    .foregroundColor(isConnected ? .green : .secondary)

                    if let battery = device.batteryText {
                        HStack(spacing: 4) {
                            Image(systemName: batteryIcon(for: device.batteryLevel ?? 0))
                                .font(.system(size: 10, weight: .medium))
                            Text(battery)
                                .font(.system(.caption2, design: .monospaced))
                        }
                        .foregroundColor(.secondary)
                    }

                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if isHovering {
                Menu {
                    if isConnected {
                        Button(action: { viewModel.disconnect(device) }) {
                            Label("Disconnect", systemImage: "bolt.slash")
                        }
                    } else {
                        Button(action: { viewModel.reconnect(device) }) {
                            Label("Connect", systemImage: "bolt")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            }
        }
        .padding(.vertical, 8)
        .onHover { hovering in
            isHovering = hovering
        }
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
