//
//  ViewController.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 02/09/22.
//

import UIKit
import CoreBluetooth
import AVFoundation

// Struct que é populada na linha 103, conforme o response recebido do scan.
// Posteriormente daria pra mover ela para um arquivo separado.
struct PeripheralModel {
      let name: String
      let uuid: String
      let rssi: String
      let peripheral: CBPeripheral

      init(name: String, uuid: String, rssi: String, peripheral: CBPeripheral) {
          let rssi = rssi
              .replacingOccurrences(of: "[", with: "")
              .replacingOccurrences(of: "]", with: "")
          self.name = name
          self.uuid = uuid
          self.rssi = rssi
          self.peripheral = peripheral
      }
}

class ViewController: UIViewController {

    private var centralManager: CBCentralManager?
    private lazy var rootView = HomeView()
    private var peripheral: CBPeripheral?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.centralManager?.delegate = self
        self.startScanning()
        self.rootView.didPullRefresh = pullRefresh
    }
    
    // Ao fazer o pull na tableView, é feito o scan novamente, e após 5 segundos, o activity da tableView é parado.
    private func pullRefresh() {
        self.startScanning()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.rootView.tableView.refreshControl?.endRefreshing()
            self.rootView.tableView.reloadData()
        }
    }

    override func loadView() {
        super.loadView()
        view = rootView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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

}

extension ViewController: CBCentralManagerDelegate {
    
    // MARK: - Verifica o estado do bluetooth
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOff:
            print("-> Bluetooth is powered off")
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
            self?.connectBLE(indexPath: indexpath.item, item: self?.rootView.peripherics ?? [], CBperipheral: peripheral)
        }
        
    }
    
    func connectBLE(indexPath: Int, item: [PeripheralModel], CBperipheral: CBPeripheral) {
        self.centralManager?.connect(item[indexPath].peripheral)
        let periphericName = self.rootView.peripherics[indexPath].name
        
        switch CBperipheral.state {
        case .disconnected:
            self.showAlertLoading(title: "Desconectado!", peripheral: periphericName)
        case .connecting:
            self.centralManager?.stopScan()
            self.showAlertLoading(title: "Conectando...", peripheral: periphericName)
        case .connected:
            self.centralManager?.stopScan()
            self.showAlertLoading(title: "Conectado!", peripheral: periphericName)
        case .disconnecting:
            self.centralManager?.stopScan()
            self.showAlertLoading(title: "Desconectando...", peripheral: periphericName)
        @unknown default:
            break
        }
        print(item[indexPath])
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.showAlert(title: "Dispositivo conectado")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.showAlert(title: "Dispositivo desconectado")
        startSong(id: 1005)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.showAlert(title: "Conexao falhou")
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

