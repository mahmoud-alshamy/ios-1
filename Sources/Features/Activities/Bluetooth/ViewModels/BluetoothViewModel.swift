import Foundation
import Combine

@MainActor
class BluetoothViewModel: ObservableObject {
    @Published var devices: [BluetoothDevice] = []
    @Published var primaryDevice: BluetoothDevice?
    @Published var isLoading: Bool = false
    @Published var error: String?

    private let service: BluetoothService
    private var cancellables = Set<AnyCancellable>()

    init(service: BluetoothService) {
        self.service = service
        setupBindings()
    }

    private func setupBindings() {
        service.$connectedDevices
            .receive(on: DispatchQueue.main)
            .assign(to: &$devices)

        service.$primaryDevice
            .receive(on: DispatchQueue.main)
            .assign(to: &$primaryDevice)

        service.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)

        service.$error
            .receive(on: DispatchQueue.main)
            .map { $0?.localizedDescription }
            .assign(to: &$error)
    }

    func disconnect(_ device: BluetoothDevice) {
        do {
            try service.disconnect(device: device)
        } catch {
            self.error = error.localizedDescription
            Logger.log("Failed to disconnect device: \(error)", level: .error, category: "BluetoothViewModel")
        }
    }

    func reconnect(_ device: BluetoothDevice) {
        do {
            try service.reconnect(device: device)
        } catch {
            self.error = error.localizedDescription
            Logger.log("Failed to reconnect device: \(error)", level: .error, category: "BluetoothViewModel")
        }
    }

    var connectedCount: Int {
        devices.filter { $0.isConnected }.count
    }

    var disconnectedCount: Int {
        devices.filter { !$0.isConnected }.count
    }

    var connectedDevices: [BluetoothDevice] {
        devices.filter { $0.isConnected }
    }

    var disconnectedDevices: [BluetoothDevice] {
        devices.filter { !$0.isConnected }
    }
}
