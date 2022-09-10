//
//  ViewController.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 02/09/22.
//

import UIKit
import CoreBluetooth
import AVFoundation

class ViewController: UIViewController {

    private var centralManager: CBCentralManager?
    private lazy var rootView = HomeView()
    private var peripheral: CBPeripheral?
    private var lastConnected: [PeripheralModel] = []
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.centralManager?.delegate = self
        self.showPowerOffAlert()
        self.startScanning()
        self.rootView.didPullRefresh = pullRefresh
        self.rootView.didTapLastConnectedAction = openLastsConnected
    }

    override func loadView() {
        super.loadView()
        view = rootView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Limpa toda a lista e começa escaneando novamente.
    func startScanning() {
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
                messsage: "Habilite no menu do seu iPhone.",
                hasButton: true
            )
        }
    }
    
    private func openLastsConnected() {
        if self.lastConnected.isEmpty {
            showAlert(title: "Histórico vazio", messsage: "", hasButton: true)
        } else {
            let controller = LastConnectedListView()
            controller.didTapRemoveAllAction = weakify { weakSelf in
                weakSelf.lastConnected.removeAll()
                controller.peripherics = self.lastConnected
                controller.tableView.reloadData()
            }
            controller.peripherics = self.lastConnected
            controller.tableView.reloadData()
            controller.modalPresentationStyle = .pageSheet
            present(controller, animated: true)
        }
    }
    
    private func didTapRemoveAll() {
      
    }

}

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
        @unknown default:
            break
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        let doesNotContainPeripheral = rootView.peripherics.map(\.uuid).doesNotContain(peripheral.identifier.uuidString)
        
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
        self.rootView.didSelectPeripheral = { [ weak self ] indexpath in
            self?.showPowerOffAlert()
            self?.connectBLE(indexPath: indexpath.item, item: self?.rootView.peripherics ?? [], CBperipheral: peripheral)
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
        case .connected:
            self.centralManager?.stopScan()
//            self.showAlertLoading(title: "Dispositivo conectado!", peripheral: periphericName, isOnActivity: false)
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
            PeripheralModel(
                name: peripheral.name?.description ?? "Desconhecido",
                uuid: peripheral.identifier.uuidString,
                rssi: "",
                peripheral: peripheral
            )
        )
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.showAlert(title: "Dispositivo desconectado!")
        rootView.connectedValue = ConnectedPeripheralModel(name: "Nenhum", uuid: "")
        startSong(id: 1005)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
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
