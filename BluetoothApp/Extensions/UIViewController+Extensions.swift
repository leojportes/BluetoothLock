//
//  UIViewController+Extensions.swift
//  BarberVip
//
//  Created by Renilson Moreira on 24/08/22.
//

import UIKit

extension UIViewController {
     func showAlert(title: String = "Funcionalidade não disponível!", messsage: String = "Estamos trabalhando nisso.") {
        let alert = UIAlertController(title: title, message: messsage, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertLoading() {
        let alert = UIAlertController(title: "conectando...", message: nil, preferredStyle: .actionSheet)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "[TV] Samsung AU770050 TV"
        
        alert.view.addSubview(label)
        alert.view.addSubview(activityIndicator)
        alert.view.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        label.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50).isActive = true
        
        activityIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor).isActive = true
        activityIndicator.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15).isActive = true
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
