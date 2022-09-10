//
//  ViewController.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 02/09/22.
//

import UIKit
import CoreBluetooth
import AVFoundation

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
    }

    override func loadView() {
        super.loadView()
        view = rootView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // A cada 7 segundos, é esvaziada a lista de items de periféricos e de rssi e feito o scan novamente.
    // a propriedade self.timer é chamada em alguns momentos que não é para fazer o request novamente.
    // Para parar o request, é usado self.timer.invalidate(), assim garantimos que quando está `conectando...`, não fique buscando novos requests e atualizando a lista.
    func startScanning() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 7, repeats: true) { _ in
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
            self.rootView.tableView.reloadData()
        }
    }

}

extension ViewController: CBCentralManagerDelegate {
    
    // MARK: - Verifica o estado do bluetooth
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOff:
            print("-> Bluetooth is powered off")
            timer?.invalidate()
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

        let doesNotContainPeripheral = rootView.peripherics.map(\.name).doesNotContain(peripheral.name ?? "")

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

        self.rootView.didSelectPeripheral = { [ weak self ] indexs in
            self?.connectBLE(indexPath: indexs.item, item: self?.rootView.peripherics ?? [], CBperipheral: peripheral)
        }
        
    }
    
    func connectBLE(indexPath: Int, item: [PeripheralModel], CBperipheral: CBPeripheral) {
        self.centralManager?.connect(item[indexPath].peripheral)
        let periphericName = self.rootView.peripherics[indexPath].name
        
        switch CBperipheral.state {
        case .disconnected:
            self.startScanning()
            self.showAlertLoading(title: "Desconectado!", peripheral: periphericName)
        case .connecting:
            self.centralManager?.stopScan()
            self.timer?.invalidate()
            self.showAlertLoading(title: "Conectando...", peripheral: periphericName)
        case .connected:
            self.centralManager?.stopScan()
            self.showAlertLoading(title: "Conectado!", peripheral: periphericName)
        case .disconnecting:
            self.centralManager?.stopScan()
            self.timer?.invalidate()
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
        self.startScanning()
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

