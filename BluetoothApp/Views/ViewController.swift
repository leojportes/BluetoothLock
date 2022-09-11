//
//  ViewController.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 02/09/22.
//

import UIKit
import CoreBluetooth
import AVFoundation
import MobileCoreServices

class ViewController: UIViewController {

    // MARK: - Private properties
    private lazy var rootView = HomeView()
    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var lastConnected: [LastPeripheralModel] = []
    private var imageTaked: UIImage?
    private var labelTime = UILabel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.centralManager?.delegate = self
        self.showPowerOffAlert()
        self.startScanning()
        self.rootView.didPullRefresh = pullRefresh
        self.rootView.didTapLastConnectedAction = openLastsConnected
        
        self.initialLastConnectedValuesFromUserDefault()
    }

    override func loadView() {
        super.loadView()
        view = rootView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private methods
    // Limpa toda a lista e começa escaneando novamente.
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
    
    // Ao fazer o pull na tableView, é feito o scan novamente, e após 5 segundos, o activity da tableView é parado.
    private func pullRefresh() {
        self.showPowerOffAlert()
        self.startScanning()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.rootView.tableView.refreshControl?.endRefreshing()
            self.rootView.tableView.reloadData()
        }
    }
    
    // Mostra o alert avisando que o bluetooth está desligado.
    private func showPowerOffAlert() {
        if centralManager?.state == .poweredOff {
            self.showAlert(
                title: "Bluetooth desligado!",
                messsage: "Habilite nas configurações do seu iPhone.",
                hasButton: true
            )
        }
    }
    
    private func openLastsConnected() {
        if self.lastConnected.isEmpty {
            showAlert(title: "Histórico vazio", messsage: "", hasButton: true)
        } else {
            let controller = LastConnectedListView()
            // Action do botão de limpar lista na tela de histórico
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

    // Monta a data atual da conexão para mostrar na tela de histórico
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

    private func initialLastConnectedValuesFromUserDefault() {
        // Valor inicial do hitórico, recuperado do UserDefaults.
        if let data = UserDefaults.standard.object(forKey: "LastConnected") as? Data {
            let decoder = JSONDecoder()
            if let items = try? decoder.decode([LastPeripheralModel].self, from: data) {
                lastConnected = items
                print(items)
            }
        }
    }

}

// MARK: - CBCentralManager Delegate
extension ViewController: CBCentralManagerDelegate {
    
    // MARK: - Verifica o estado do bluetooth
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
        // Se o objeto requisitado pelo scan ainda não existir na lista da view "rootView.peripherics" ...
        // ... o item será adicionado na struct "PeripheralModel".
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

        // Ao clicar em cada celula, recuperamos o indexpath clicado pela closure 'didSelectPeripheral' e fazemos a conexão do ...
        // bluetooth pelo método "self?.connectBLE"
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
        print("Item clicado: ", item[indexPath])
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.showAlert(title: "Dispositivo conectado!")
        rootView.connectedValue = ConnectedPeripheralModel(
            name: peripheral.name?.description ?? "Desconhecido",
            uuid: peripheral.identifier.uuidString
        )
        // Adiciona os items para a tela de últimos conectados
        self.lastConnected.append(
            LastPeripheralModel(
                name: peripheral.name?.description ?? "Desconhecido",
                uuid: peripheral.identifier.uuidString,
                rssi: "",
                date: makeCurrentDate()
            )
        )
        
        // Salva no UserDefaults a lista de ultimos conectados.
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.lastConnected) {
            UserDefaults.standard.set(encoded, forKey: "LastConnected")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        self.showAlert(title: "Dispositivo desconectado!")
        rootView.connectedValue = ConnectedPeripheralModel(name: "Nenhum", uuid: "")
        self.takePicture()
//        startSong(id: 1005)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect didFailToConnectPeripheral: CBPeripheral, error: Error?) {
        self.showAlert(title: "Conexão falhou")
    }

    private func startSong(id: UInt32) {
        AudioServicesPlaySystemSound(SystemSoundID(id))
    }
    
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        //        print(service.peripheral?.name)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc
    func takePicture() {
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                imagePicker.showsCameraControls = false
                imagePicker.cameraDevice = .front
                self.present(imagePicker, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        imagePicker.takePicture()
                    }
                }
                
            }
        }
    }

    // Método que salva a foto na galeria do device.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[.originalImage] as? UIImage {
            imageTaked = image
            UIImageWriteToSavedPhotosAlbum(image, self, nil, .none)
            picker.dismiss(animated: true)
            return
        }
    }
}
