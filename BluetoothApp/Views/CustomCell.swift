//
//  CustomCell.swift
//  BluetoothApp
//
//  Created by Renilson Moreira on 09/09/22.
//

import UIKit

class CustomCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Code
    lazy var container: UIView = {
        let container = UIView()
        container.backgroundColor = .systemGray
        container.layer.cornerRadius = 10
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    lazy var namePeripheral: UILabel = {
        let label = UILabel()
        label.text = "[TV] Samsung AU7700 50 TV"
        label.font = .boldSystemFont(ofSize: 12)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var uuidPeripheral: UILabel = {
        let label = UILabel()
        label.text = "UUID: 3C9C13BB-23BF-46FA-265F-36BA31B60DCB36BA3"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var rssiPeripheral: UILabel = {
        let label = UILabel()
        label.text = "RSSI: -95"
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}

extension CustomCell: ViewCodeContract {
    func setupHierarchy() {
        addSubview(container)
        container.addSubview(namePeripheral)
        container.addSubview(uuidPeripheral)
        container.addSubview(rssiPeripheral)
    }
    
    func setupConstraints() {
        container
            .pin(toEdgesOf: self, padding: .vertical(5))
        
        namePeripheral
            .topAnchor(in: container, attribute: .top, padding: 10)
            .leftAnchor(in: container, attribute: .left, padding: 10)
            .rightAnchor(in: container, attribute: .right, padding: 10)
        
        uuidPeripheral
            .topAnchor(in: namePeripheral, attribute: .bottom, padding: 4)
            .leftAnchor(in: container, attribute: .left, padding: 10)
            .rightAnchor(in: container, attribute: .right, padding: 10)
        
        rssiPeripheral
            .topAnchor(in: uuidPeripheral, attribute: .bottom, padding: 4)
            .leftAnchor(in: container, attribute: .left, padding: 10)
            .rightAnchor(in: container, attribute: .right, padding: 10)
            .bottomAnchor(in: container, attribute: .bottom, padding: 10)
    }
    
    func setup(name: String, uuid: String, rssi: String) {
        namePeripheral.text = name
        uuidPeripheral.text = uuid
        rssiPeripheral.text = rssi
    }
}
