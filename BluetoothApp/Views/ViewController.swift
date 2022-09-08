//
//  ViewController.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 02/09/22.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    private var centralManager: CBCentralManager?
    private lazy var rootView = HomeView()
    private var peripheral: CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getActionButton()
    }

    override func loadView() {
        super.loadView()
        view = rootView
    }
    
    func getActionButton() {
        rootView.actionConnect = { [ weak self ] in
            self?.centralManager = CBCentralManager(delegate: self, queue: nil)
            self?.centralManager?.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startScanning() {
      if let central = centralManager {
        central.scanForPeripherals(withServices: nil, options: nil)
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
        
        if peripheral.identifier.uuidString == "3C9C13BB-23BF-46FA-265F-36BA31B60DCB"{
            /// Atribui ao o periferico selecionado
            self.peripheral = peripheral
            
            /// para o escaneamento
            self.centralManager?.stopScan()
            
            ///Conecta com o disposivo
            self.centralManager?.connect(self.peripheral ?? peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        ///interrompe o escaneamento
        print("conectado")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //self.startScanning()
        print("desconectado")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("conexao falhou")
    }
    
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print(service.peripheral?.name)
    }
}

