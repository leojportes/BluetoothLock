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
        label.font = .boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var peripheralConnectedLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .gray
        label.numberOfLines = .zero
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var uuidConnectedLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .gray
        label.numberOfLines = .zero
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var connectAnPeripheralLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .darkGray
        label.text = "Conecte-se a um dispositivo"
        label.numberOfLines = .zero
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var baseView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "lightGray")
        view.roundCorners(cornerRadius: 15, typeCorners: [.topLeft, .topRight])
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    func setupHierarchy() {
        addSubview(baseView)
        
        baseView.addSubview(label)
        baseView.addSubview(peripheralConnectedLabel)
        baseView.addSubview(uuidConnectedLabel)
        baseView.addSubview(connectAnPeripheralLabel)
    }

    func setupConstraints() {
        baseView
            .pin(toEdgesOf: self)
        
        label
            .topAnchor(in: baseView, padding: 10)
            .leftAnchor(in: baseView, padding: 11)
            .heightAnchor(20)
        
        peripheralConnectedLabel
            .topAnchor(in: label, attribute: .bottom, padding: 4)
            .leftAnchor(in: baseView, padding: 11)
        
        uuidConnectedLabel
            .topAnchor(in: peripheralConnectedLabel, attribute: .bottom, padding: 4)
            .leftAnchor(in: baseView, padding: 11)
        
        connectAnPeripheralLabel
            .topAnchor(in: uuidConnectedLabel, attribute: .bottom, padding: 12)
            .leftAnchor(in: baseView, padding: 11)
            .bottomAnchor(in: baseView, padding: 2)
     
    }

    override init(reuseIdentifier: String?) {
        super .init(reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
