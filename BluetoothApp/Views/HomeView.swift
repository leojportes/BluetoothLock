//
//  HomeView.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 02/09/22.
//

import Foundation
import UIKit
import CoreBluetooth

final class HomeView: UIView, ViewCodeContract {

    var items: [CBPeripheral] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .yellow
        setupView()
    }

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        return table
    }()

    func setupHierarchy() {
        addSubview(tableView)
    }
    
    func setupConstraints() {
        tableView
            .topAnchor(in: self, padding: 10)
            .leftAnchor(in: self, padding: 10)
            .rightAnchor(in: self, padding: 10)
            .bottomAnchor(in: self, padding: 10)
    }
    
    func setupConfiguration() {
        
    }
}

extension HomeView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UITableViewCell else { return UITableViewCell() }
//        let item = items[indexPath.row]
        cell.textLabel?.text = "kk"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
}
