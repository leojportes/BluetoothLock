//
//  ViewController.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 02/09/22.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    private var manager: CBCentralManager?
    private lazy var rootView = HomeView()
    private var bluefruitPeripheral: CBPeripheral?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
        manager?.delegate = self
    }

    override func loadView() {
        super.loadView()
        view = rootView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        case .poweredOn: consoleMsg = "-> Bluetooth is powered on"
        @unknown default:
            break
        }
        print(consoleMsg)
        
        print(central.scanForPeripherals(withServices: nil, options: nil))
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "[TV] Samsung AU7700 50 TV"{
            
            ///interrompe o escaneamento
            manager?.stopScan()
            
            /// Atribui ao o periferico selecionado
            bluefruitPeripheral = peripheral
            
            ///Conecta com o disposivo
            manager?.connect(bluefruitPeripheral ?? peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
       print("desconectado")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("conectado")
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

