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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.centralManager?.delegate = self
    }

    override func loadView() {
        super.loadView()
        view = rootView
    }
    
//    func getActionsView() {
//        rootView.didSelectPeripheral = { [ weak self ] indexs in
//
////            self?.showAlertLoading()
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startScanning() {
        if let central = centralManager {
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
        
        var consoleMsg = ""
        
        switch (central.state) {
        case .poweredOff: consoleMsg = "-> Bluetooth is powered off"
        case .unknown: consoleMsg = "-> Bluetooth is unknown"
        case .resetting: consoleMsg = "-> Bluetooth resetting"
        case .unsupported: consoleMsg = "-> Bluetooth unsupported"
        case .unauthorized: consoleMsg = "-> Bluetooth unauthorized"
        case .poweredOn:
            consoleMsg = "-> Bluetooth is powered on"
            startScanning()
        @unknown default:
            break
        }
        print(consoleMsg)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        let doesNotContainPeripheral = rootView.items.map(\.name?.description).doesNotContain(peripheral.name?.description)
        let doesNotContainRSSI = rootView.rssi.map(\.stringValue).doesNotContain(RSSI.stringValue)

        if doesNotContainPeripheral && doesNotContainRSSI {
            rootView.items.append(peripheral)
            rootView.rssi.removeAll()
            rootView.rssi.append(RSSI)
        }

        self.rootView.didSelectPeripheral = { [ weak self ] indexs in
            self?.conectBLE(indexPath: indexs.item, peripheral: self?.rootView.items ?? [])
            
            switch peripheral.state {
            case .disconnected:
                self?.showAlertLoading(title: "Desconectado!", peripheral: self?.rootView.items[indexs.item].name ?? "" )
            case .connecting:
                self?.showAlertLoading(title: "Conectando...!", peripheral: self?.rootView.items[indexs.item].name ?? "" )
            case .connected:
                self?.showAlertLoading(title: "Conectado!", peripheral: self?.rootView.items[indexs.item].name ?? "" )
            case .disconnecting:
                self?.showAlertLoading(title: "Desconectando...", peripheral: self?.rootView.items[indexs.item].name ?? "" )
            @unknown default:
                break
            }
        }
        
       
        
//
        
        
        
    }
    
    func conectBLE(indexPath: Int, peripheral: [CBPeripheral]) {
        self.centralManager?.connect(peripheral[indexPath])
        print(peripheral[indexPath])
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // guard let namePeripheral = peripheral.name else { return }

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
        print(service.peripheral?.name)
    }
}

