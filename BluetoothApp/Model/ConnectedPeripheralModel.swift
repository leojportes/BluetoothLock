//
//  ConnectedPeripheralModel.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 10/09/22.
//

import Foundation

struct ConnectedPeripheralModel {
    let name: String
    let uuid: String
    
    init(name: String, uuid: String = "") {
        self.name = name
        self.uuid = uuid
    }
}
