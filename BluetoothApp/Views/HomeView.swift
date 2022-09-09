//
//  HomeView.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 02/09/22.
//

import Foundation
import UIKit
import CoreBluetooth

final class HomeView: UIView {
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Code
    lazy var bluetoothImage: UIImageView = {
        let imagem = UIImageView()
        imagem.image = UIImage(named: "imageBluetooth")
        imagem.contentMode = .scaleAspectFit
        imagem.translatesAutoresizingMaskIntoConstraints = false
        return imagem
    }()
    
    lazy var connectToDeviceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.text = "Conecte-se a um dispositivo"
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(CustomCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        return table
    }()

}

// MARK: - View Code Contract
extension HomeView: ViewCodeContract {
    func setupHierarchy() {
        addSubview(bluetoothImage)
        addSubview(connectToDeviceLabel)
        addSubview(tableView)
    }
    
    func setupConstraints() {
        
        bluetoothImage
            .topAnchor(in: self, padding: 30)
            .centerX(in: self)
            .widthAnchor(144)
            .heightAnchor(144)
        
        connectToDeviceLabel
            .topAnchor(in: bluetoothImage, attribute: .bottom, padding: 30)
            .centerX(in: self)
        
        tableView
            .topAnchor(in: connectToDeviceLabel, attribute: .bottom, padding: 15)
            .leftAnchor(in: self, padding: 5)
            .rightAnchor(in: self, padding: 5)
            .bottomAnchor(in: self, padding: 15)
    }
    
    func setupConfiguration() {
        self.backgroundColor = .white
    }
}

// MARK: - Delegate and DataSource tableview
extension HomeView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
//        let item = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("alert")
    }
}
