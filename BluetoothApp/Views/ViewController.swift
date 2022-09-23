//
//  ViewController.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 02/09/22.
//

import UIKit
import CoreBluetooth
import AVFoundation
import CoreLocation

class ViewController: UIViewController {

    // MARK: - Private properties
    private var centralManager: CBCentralManager?
    private lazy var rootView = HomeView()
    private var peripheral: CBPeripheral?
    private var lastConnected: [LastPeripheralModel] = []
    private var timer: Timer?
    private let locationService = CLLocationManager()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationServices()
        setupCoreBluetooth()
        self.rootView.didPullRefresh = pullToRefresh
        self.rootView.didTapLastConnectedAction = openLastsConnected
    }

    override func loadView() {
        super.loadView()
        view = rootView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private methods

    /// Clears the entire list and starts scanning again.
    private func startScanning() {
        self.rootView.peripherics.removeAll()
        if let central = self.centralManager {
            central.scanForPeripherals(
                withServices: nil,
                options: [
                    CBCentralManagerScanOptionAllowDuplicatesKey: false,
                    CBConnectPeripheralOptionNotifyOnConnectionKey: false,
                    CBConnectPeripheralOptionNotifyOnDisconnectionKey: false,
                    CBConnectPeripheralOptionNotifyOnNotificationKey: false
                ]
            )
        }
    }

    /// When pulling the tableView, it is scanned again, and after 5 seconds, the tableView activity is stopped.
    private func pullToRefresh() {
        self.showPowerOffAlert()
        self.startScanning()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.rootView.tableView.refreshControl?.endRefreshing()
            self.rootView.tableView.reloadData()
        }
    }

    /// Shows the alert warning that bluetooth is off.
    private func showPowerOffAlert() {
        if centralManager?.state == .poweredOff {
            self.showAlert(
                title: "Bluetooth desligado!",
                messsage: "Habilite no menu do seu iPhone.",
                hasButton: true
            )
        }
    }
    
    private func openLastsConnected() {
        if self.lastConnected.isEmpty {
            showAlert(title: "Histórico vazio!", messsage: "", hasButton: true)
        } else {
            let controller = LastConnectedListView()
            /// Clear list button action on history screen
            controller.didTapRemoveAllAction = weakify { weakSelf in
                if weakSelf.lastConnected.isEmpty {
                    UIViewController.findCurrentController()?.showAlert(title: "Histórico já é vazio.")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        UIViewController.findCurrentController()?.dismiss(animated: true)
                    }
                } else {
                    if let appDomain = Bundle.main.bundleIdentifier {
                        UserDefaults.standard.removePersistentDomain(forName: appDomain)
                        UIViewController.findCurrentController()?.showAlert(title: "Histórico esvaziado.")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            UIViewController.findCurrentController()?.dismiss(animated: true)
                        }
                    }
                    weakSelf.lastConnected.removeAll()
                    controller.peripherics = self.lastConnected
                    controller.tableView.reloadData()
                }
            }
            controller.peripherics = self.lastConnected
            controller.tableView.reloadData()
            controller.modalPresentationStyle = .pageSheet
            present(controller, animated: true)
        }
    }

    /// Sets the current connection date to show on the history screen
    private func makeCurrentDate() -> String {
        let date = Date()
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "pt_BR")
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return "\(day)/\(month)/\(year) - \(hour):\(minute)"
    }

    /// Historic's initial value, retrieved from UserDefaults.
    private func initialLastConnectedValuesFromUserDefault() {
        if let data = UserDefaults.standard.object(forKey: "LastConnected") as? Data {
            let decoder = JSONDecoder()
            if let items = try? decoder.decode([LastPeripheralModel].self, from: data) {
                lastConnected = items
            }
        }
    }

    /// CoreBluetooth setup.
    private func setupCoreBluetooth() {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.centralManager?.delegate = self
        self.showPowerOffAlert()
        self.startScanning()
        self.initialLastConnectedValuesFromUserDefault()
    }

}

// MARK: - CBCentralManager Delegate
extension ViewController: CBCentralManagerDelegate {
    
    /// Check bluetooth status
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOff:
            print("-> Bluetooth is powered off")
            rootView.connectedValue = ConnectedPeripheralModel(name: "Nenhum", uuid: "")
        case .unknown: print("-> Bluetooth is unknown")
        case .resetting: print("-> Bluetooth resetting")
        case .unsupported: print("-> Bluetooth unsupported")
        case .unauthorized: print("-> Bluetooth unauthorized")
        case .poweredOn:
            print("-> Bluetooth is powered on")
            startScanning()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if central.state != .poweredOn {
                    if UIAlertController.findCurrentController() == self {
                        UIAlertController.findCurrentController()?.dismiss(animated: true)
                    }
                }
            }
        @unknown default:
            break
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        let doesNotContainPeripheral = rootView.peripherics.map(\.uuid).doesNotContain(peripheral.identifier.uuidString)
        peripheral.delegate = self
        
        /// If the object requested by the scan does not yet exist in the list of the "rootView.peripherics" view
        /// The item will be added in the struct "PeripheralModel".
        if doesNotContainPeripheral {
            rootView.peripherics.append(
                PeripheralModel(
                    name: peripheral.name?.description ?? "Desconhecido",
                    uuid: peripheral.identifier.uuidString,
                    rssi: RSSI.stringValue,
                    peripheral: peripheral
                )
            )
        }

        /// By clicking on each cell, we retrieve the indexpath clicked by the 'didSelectPeripheral' closure
        /// and we make the bluetooth connection by the method "self?.connectBLE"
        self.rootView.didSelectPeripheral = weakify {
            $0.showPowerOffAlert()
            $0.connectBLE(indexPath: $1.item, item: $0.rootView.peripherics, CBperipheral: peripheral)
        }
        
    }
    
    func connectBLE(indexPath: Int, item: [PeripheralModel], CBperipheral: CBPeripheral) {
        self.centralManager?.connect(item[indexPath].peripheral)
        let periphericName = self.rootView.peripherics[indexPath].name
        
        switch CBperipheral.state {
        case .disconnected: print("Desconectado")
        case .connecting:
            self.centralManager?.stopScan()
            self.showAlertLoading(title: "Conectando...", peripheral: periphericName)
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                UIAlertController.findCurrentController()?.dismiss(animated: true)
            }
        case .connected:
            self.centralManager?.stopScan()
        case .disconnecting:
            self.centralManager?.stopScan()
            self.showAlertLoading(title: "Desconectando...", peripheral: periphericName)
        @unknown default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.showAlert(title: "Dispositivo conectado!")
        rootView.connectedValue = ConnectedPeripheralModel(
            name: peripheral.name?.description ?? "Desconhecido",
            uuid: peripheral.identifier.uuidString
        )

        /// Adds items to the last logged in screen
        self.lastConnected.append(
            LastPeripheralModel(
                name: peripheral.name?.description ?? "Desconhecido",
                uuid: peripheral.identifier.uuidString,
                rssi: "",
                date: makeCurrentDate()
            )
        )
        
        /// Saves the last connected list in UserDefaults.
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.lastConnected) {
            UserDefaults.standard.set(encoded, forKey: "LastConnected")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.showAlert(title: "Dispositivo desconectado!")
        rootView.connectedValue = ConnectedPeripheralModel(name: "Nenhum", uuid: "")
        startSong(id: 1005, count: 10000)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect didFailToConnectPeripheral: CBPeripheral, error: Error?) {
        self.showAlert(title: "Conexão falhou")
    }

    /// Activate the audible alert.
    func startSong(id: SystemSoundID, count: Int){
        AudioServicesPlaySystemSoundWithCompletion(id) {
            if count > 0 {
                self.startSong(id: id, count: count - 1)
            }
        }
    }
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    }
}

// MARK: - CLLocationManager Delegate
extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            fetchAddress(from: location) { city, country, street, areasOfInterest, subLocality, error in
                
                guard let city = city, let country = country, error == nil else { return }
                let coordinate = location.coordinate

                FirebaseManager.shared.updateLocation(
                    longitude: "\(coordinate.longitude)",
                    latitude: "\(coordinate.latitude)",
                    country: country,
                    city: city,
                    street: street ?? "Endereço indisponível",
                    areasOfInterest: areasOfInterest ?? [],
                    subLocality: subLocality ?? "Bairro indisponível"
                )
            }
        }
    }

    private func initializeLocationServices() {
        locationService.delegate = self
        locationService.requestAlwaysAuthorization()
        locationService.startUpdatingLocation()
        locationService.delegate = self
        locationService.allowsBackgroundLocationUpdates = true
    }

    /// Fetch the attributes of the current address.
    func fetchAddress(
        from location: CLLocation,
        completion: @escaping (
            _ city: String?,
            _ country:  String?,
            _ street:  String?,
            _ areasInterest: [String]?,
            _ subLocality: String?,
            _ error: Error?) -> ()
    ) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(
                placemarks?.first?.locality,
                placemarks?.first?.country,
                placemarks?.first?.name,
                placemarks?.first?.areasOfInterest,
                placemarks?.first?.subLocality,
                error
            )
        }
    }
}
