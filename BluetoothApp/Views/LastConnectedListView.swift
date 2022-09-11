//
//  LastConnectedListView.swift
//  BluetoothApp
//
//  Created by Leonardo Portes on 10/09/22.
//

import Foundation
import UIKit

class LastConnectedListView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var didTapRemoveAllAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        view.backgroundColor = UIColor(named: "lightGray")
    }
    
    var peripherics: [LastPeripheralModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .darkGray
        label.text = "Últimos conectados"
        return label
    }()
    
    lazy var removeAllButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = UIColor(named: "darkGray")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(nil, action: #selector(didTapRemoveAll), for: .touchUpInside)
        return button
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
    
    @objc
    private func didTapRemoveAll() {
        self.didTapRemoveAllAction?()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        cell.selectionStyle = .none
        let item = peripherics[indexPath.row]

        cell.setup(
            name: "Dispositivo: \(item.name)",
            uuid: "uuid: \(item.uuid)",
            rssi: "",
            date: item.date
        )

        return cell
    }
    

}

// MARK: - View Code Contract
extension LastConnectedListView: ViewCodeContract {
    
    func setupHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(removeAllButton)
    }
    
    func setupConstraints() {
        titleLabel
            .centerX(in: view, layoutOption: .useSafeArea)
            .topAnchor(in: view, padding: 15)

        removeAllButton
            .topAnchor(in: view, padding: 50)
            .rightAnchor(in: view, padding: 15)
            .heightAnchor(30)
            .widthAnchor(30)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: removeAllButton.topAnchor, constant: 40),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15),
        ])
    }
    
}
