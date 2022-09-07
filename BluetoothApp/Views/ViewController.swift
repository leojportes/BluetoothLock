//
//  ViewController.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 02/09/22.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate {

    private var manager: CBCentralManager?
    private lazy var rootView = HomeView()

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
        manager?.delegate = self
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func loadView() {
        super.loadView()
        view = rootView
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var consoleMsg = ""
        
        switch (central.state) {
        case .poweredOff:
            consoleMsg = "-> Bluetooth is powered off"
        case .unknown:
            consoleMsg = "-> Bluetooth is unknown"
        case .resetting:
            consoleMsg = "-> Bluetooth resetting"
        case .unsupported:
            consoleMsg = "-> Bluetooth unsupported"
        case .unauthorized:
            consoleMsg = "-> Bluetooth unauthorized"
        case .poweredOn:
            consoleMsg = "-> Bluetooth is powered on"
        @unknown default:
            break
        }
        
        print(consoleMsg)
        
        print(central.scanForPeripherals(withServices: nil, options: nil))
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Periférico: \(String(describing: peripheral.name))")
        //rootView.items = peripheral
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral.state == .disconnected {
//            UIApplication.shared.tim
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

