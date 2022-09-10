//
//  PeripheralModel.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 10/09/22.
//

import CoreBluetooth

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
