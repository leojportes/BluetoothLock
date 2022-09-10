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
    
    var didSelectPeripheral: ((IndexPath) -> Void)?
    var didPullRefresh: (() -> Void)?
    var didTapLastConnectedAction: (() -> Void)?

    var peripherics: [PeripheralModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var connectedValue: ConnectedPeripheralModel = .init(name: "Nenhum", uuid: "") {
        didSet {
            tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                UIAlertController.findCurrentController()?.dismiss(animated: true)
            }
        }
    }

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(callPullToRefresh), for: .valueChanged)
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
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(CustomCell.self, forCellReuseIdentifier: "cell")
        table.register(CustomHeader.self, forHeaderFooterViewReuseIdentifier: "CustomHeader")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    lazy var lastsConnectedButton: UIButton = {
        let button = UIButton()
        button.setTitle("Últimos conectados", for: .normal)
        button.backgroundColor = .black
        button.roundCorners(cornerRadius: 15)
        button.addShadow(
            color: UIColor.black,
            size: CGSize(width: -3, height: 3),
            opacity: 0.2,
            radius: 2.0
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(nil, action: #selector(didTapLastConnected), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func didTapLastConnected() {
        self.didTapLastConnectedAction?()
    }

}

// MARK: - View Code Contract
extension HomeView: ViewCodeContract {
    func setupHierarchy() {
        addSubview(bluetoothImage)
        addSubview(tableView)
        addSubview(lastsConnectedButton)
    }
    
    func setupConstraints() {
        
        bluetoothImage
            .topAnchor(in: self, padding: 30)
            .centerX(in: self)
            .widthAnchor(144)
            .heightAnchor(144)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: bluetoothImage.bottomAnchor, constant: 15),
            tableView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5),
            tableView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5),
            tableView.bottomAnchor.constraint(equalTo: lastsConnectedButton.topAnchor, constant: -15),
        ])

        lastsConnectedButton
            .leftAnchor(in: self, padding: 10)
            .rightAnchor(in: self, padding: 10)
            .bottomAnchor(in: self, padding: 20)
            .heightAnchor(45)
    }
    
    func setupConfiguration() {
        self.backgroundColor = .white
    }
    
    // MARK: - Actions
    @objc private func callPullToRefresh() {
        self.didPullRefresh?()
    }
    
}

// MARK: - Delegate and DataSource tableview
extension HomeView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        cell.selectionStyle = .none
        let item = peripherics[indexPath.row]
        let rssiItem = item.rssi

        cell.setup(
            name: item.name,
            uuid: "uuid: \(item.uuid)",
            rssi: "rssi: \(rssiItem)"
        )

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectPeripheral?(indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomHeader") as! CustomHeader
        if connectedValue.name != "Nenhum"{
            headerView.peripheralConnectedLabel.textColor = .systemGreen
            headerView.uuidConnectedLabel.text = "uuid: \(connectedValue.uuid)"
        } else {
            headerView.peripheralConnectedLabel.textColor = .systemRed
            headerView.uuidConnectedLabel.text = "\(connectedValue.uuid)"
        }
        headerView.peripheralConnectedLabel.text = connectedValue.name
        return headerView
    }

    // Tamanho em altura da Headerview `CustomHeader`.
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

}
