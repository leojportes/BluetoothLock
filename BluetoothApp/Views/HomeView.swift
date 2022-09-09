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
    
    var clickInCell: ((IndexPath) -> Void)?
    
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
        addSubview(tableView)
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
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15),


        ])
    }
    
    func setupConfiguration() {
        self.backgroundColor = .white
    }
}

// MARK: - Delegate and DataSource tableview
extension HomeView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
//        let item = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clickInCell?(indexPath)
    }
    
    
    // TEM QUE AJUSTAR ESSA PARTE
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Conecte-se a um dispositivo"
    }
}
