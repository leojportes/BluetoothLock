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
        container.backgroundColor = .white
        container.addShadow(
            color: UIColor.lightGray,
            size: CGSize(width: -3, height: 3),
            opacity: 0.2,
            radius: 2.0
        )
        container.layer.cornerRadius = 15
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    lazy var namePeripheral: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var uuidPeripheral: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var rssiPeripheral: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
}

extension CustomCell: ViewCodeContract {
    func setupHierarchy() {
        self.backgroundColor = UIColor(named: "lightGray")
        addSubview(container)
        container.addSubview(namePeripheral)
        container.addSubview(uuidPeripheral)
        container.addSubview(rssiPeripheral)
        container.addSubview(dateLabel)
    }
    
    func setupConstraints() {
        container
            .pin(toEdgesOf: self, padding: .init(vertical: 5, horizontal: 10))
        
        namePeripheral
            .topAnchor(in: container, attribute: .top, padding: 10)
            .leftAnchor(in: container, attribute: .left, padding: 10)
            .rightAnchor(in: container, attribute: .right, padding: 10)
        
        dateLabel
            .topAnchor(in: container, padding: 10)
            .rightAnchor(in: container, padding: 10)
        
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
    
    func setup(name: String, uuid: String, rssi: String, date: String = "") {
        namePeripheral.text = name
        uuidPeripheral.text = uuid
        rssiPeripheral.text = rssi
        dateLabel.text = date
    }
}
