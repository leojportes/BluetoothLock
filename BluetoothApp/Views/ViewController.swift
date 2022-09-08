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
    
    private var timerForScanning: Timer?
    var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    let reconnectInterval = 15 // seconds
    
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
        // Teste Léo.
       // if peripheral.name == "[TV] Samsung 7 Series (50)" {
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
        tryReconnect(central, to: peripheral)
        showAlert(title: "Parabéns", messsage: "Dispositivo foi conectado com sucesso!!")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //self.startScanning()
        tryReconnect(central, to: peripheral)
        showAlert(title: "Atenção", messsage: "Dispositivo foi desconectado")
        startSong(id: 1005)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        tryReconnect(central, to: peripheral)
        print("conexao falhou")
        showAlert(title: "Atenção", messsage: "Conexao falhou")
    }

    // MARK: - Aux methods
    
    private func tryReconnect(_ central: CBCentralManager, to peripheral: CBPeripheral) {
        DispatchQueue.main.async { // while in background mode Timer would work only being in main queue
            self.backgroundTaskId = UIApplication.shared.beginBackgroundTask (withName: "reconnectAgain") {
                UIApplication.shared.endBackgroundTask(self.backgroundTaskId)
                self.backgroundTaskId = .invalid
            }
            
            self.timerForScanning?.invalidate()
            self.timerForScanning = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.reconnectInterval), repeats: false) { _ in
                central.connect(peripheral, options: [:])
                
                UIApplication.shared.endBackgroundTask(self.backgroundTaskId)
                self.backgroundTaskId = .invalid
            }
        }
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

