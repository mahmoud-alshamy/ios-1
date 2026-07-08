import Foundation
import Combine
import IOBluetooth
import IOKit

enum BluetoothError: Error, LocalizedError {
    case bluetoothUnavailable
    case deviceNotFound
    case connectionFailed
    case operationFailed(String)

    var errorDescription: String? {
        switch self {
        case .bluetoothUnavailable: return "Bluetooth is not available"
        case .deviceNotFound: return "Device not found"
        case .connectionFailed: return "Connection failed"
        case .operationFailed(let msg): return msg
        }
    }
}

class BluetoothService: BackgroundService {
    @Published private(set) var connectedDevices: [BluetoothDevice] = []
    @Published private(set) var primaryDevice: BluetoothDevice?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?

    private var updateTimer: Timer?
    private let updateInterval: TimeInterval = 5.0

    init() {
        Logger.log("BluetoothService initialized", category: "BluetoothService")
    }

    func start() {
        Logger.log("BluetoothService started", category: "BluetoothService")
        DispatchQueue.main.async {
            self.fetchConnectedDevices()
        }
        startPeriodicUpdates()
    }

    func stop() {
        Logger.log("BluetoothService stopped", category: "BluetoothService")
        updateTimer?.invalidate()
        updateTimer = nil
    }

    private func startPeriodicUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.fetchConnectedDevices()
        }
    }

    func fetchConnectedDevices() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = true
            }

            var devices: [BluetoothDevice] = []
            let batteryLevels = self.batteryLevelsByAddress()

            if let pairedDevices = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] {
                for device in pairedDevices {
                    if let connectedDevice = self.convertIOBluetoothDevice(device, batteryLevels: batteryLevels) {
                        devices.append(connectedDevice)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.error = BluetoothError.bluetoothUnavailable
                }
            }

            DispatchQueue.main.async {
                self.connectedDevices = devices.sorted { $0.isConnected && !$1.isConnected }
                self.primaryDevice = devices.first(where: { $0.isConnected })
                self.isLoading = false
            }
        }
    }

    private func convertIOBluetoothDevice(_ device: IOBluetoothDevice) -> BluetoothDevice? {
        guard let name = device.name, let address = device.addressString else {
            return nil
        }

        let deviceType = detectDeviceType(name: name, classOfDevice: device.classOfDevice)

        return BluetoothDevice(
            name: name,
            address: address,
            isConnected: device.isConnected(),
            batteryLevel: nil,
            deviceType: deviceType
        )
    }

    private func detectDeviceType(name: String, classOfDevice: UInt32) -> DeviceType {
        let lowerName = name.lowercased()

        if lowerName.contains("airpods") || lowerName.contains("beats") {
            return .headphones
        } else if lowerName.contains("watch") {
            return .watch
        } else if lowerName.contains("mouse") || lowerName.contains("trackpad") {
            return .mouse
        } else if lowerName.contains("keyboard") {
            return .keyboard
        } else if lowerName.contains("speaker") || lowerName.contains("audio") {
            return .speaker
        }

        let majorClassCode = (classOfDevice >> 8) & 0x1F
        switch majorClassCode {
        case 0x04: return .headphones
        case 0x05: return .speaker
        case 0x08: return .watch
        case 0x0D: return .mouse
        default: return .unknown
        }
    }

    func disconnect(device: BluetoothDevice) throws {
        guard let ioDevice = IOBluetoothDevice(addressString: device.address) else {
            throw BluetoothError.deviceNotFound
        }

        let result = ioDevice.closeConnection()
        if result == kIOReturnSuccess {
            Logger.log("Device disconnected: \(device.name)", category: "BluetoothService")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.fetchConnectedDevices()
            }
        } else {
            throw BluetoothError.connectionFailed
        }
    }

    func reconnect(device: BluetoothDevice) throws {
        guard let ioDevice = IOBluetoothDevice(addressString: device.address) else {
            throw BluetoothError.deviceNotFound
        }

        let result = ioDevice.openConnection()
        if result == kIOReturnSuccess {
            Logger.log("Device reconnected: \(device.name)", category: "BluetoothService")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.fetchConnectedDevices()
            }
        } else {
            throw BluetoothError.connectionFailed
        }
    }
}
