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
    
    var actionConnect: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .white
        setupView()
    }
    
    lazy var bluetoothImage: UIImageView = {
        let imagem = UIImageView()
        imagem.image = UIImage(named: "imageBluetooth")
        imagem.contentMode = .scaleAspectFit
        imagem.translatesAutoresizingMaskIntoConstraints = false
        return imagem
    }()

    lazy var connectButton: UIButton = {
        let button = UIButton()
        button.setTitle("Conectar", for: .normal)
        button.setImage(UIImage(named: "iconBluetooth"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleConnectButton), for: .touchUpInside)
        return button
    }()
    
    @objc func handleConnectButton() {
        actionConnect?()
    }

    func setupHierarchy() {
        addSubview(bluetoothImage)
        addSubview(connectButton)
    }
    
    func setupConstraints() {
        
        bluetoothImage
            .topAnchor(in: self, padding: 200)
            .centerX(in: self)
            .widthAnchor(114)
            .heightAnchor(114)
        
        connectButton
            .topAnchor(in: bluetoothImage, attribute: .bottom, padding: 65)
            .leftAnchor(in: self, padding: 10)
            .rightAnchor(in: self, padding: 10)
            .heightAnchor(40)
    }
    
    func setupConfiguration() {
        
    }
}
