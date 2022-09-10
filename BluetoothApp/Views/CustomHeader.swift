//
//  CustomHeader.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 10/09/22.
//

import UIKit

class CustomHeader: UITableViewHeaderFooterView, ViewCodeContract {

    static let reuseIdentifier = "CustomHeader"

    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Dispositivo conectado:"
        label.textColor = .darkGray
        label.font = .boldSystemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var peripheralConnectedLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .gray
        label.numberOfLines = .zero
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var uuidConnectedLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = .zero
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    func setupHierarchy() {
        addSubview(label)
        addSubview(peripheralConnectedLabel)
        addSubview(uuidConnectedLabel)
    }

    func setupConstraints() {
        label
            .topAnchor(in: self, padding: 5)
            .leftAnchor(in: self, padding: 5)
            .heightAnchor(20)
        
        peripheralConnectedLabel
            .topAnchor(in: label, attribute: .bottom, padding: 5)
            .leftAnchor(in: self, padding: 5)
        
        uuidConnectedLabel
            .topAnchor(in: peripheralConnectedLabel, attribute: .bottom, padding: 5)
            .leftAnchor(in: self, padding: 5)
            .bottomAnchor(in: self, padding: 2)
     
    }

    override init(reuseIdentifier: String?) {
        super .init(reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
