//
//  UIViewController+Extensions.swift
//  BarberVip
//
//  Created by Renilson Moreira on 24/08/22.
//

import UIKit

extension UIViewController {
    func showAlert(title: String = "Funcionalidade não disponível!", messsage: String = "", hasButton: Bool = false) {
        let alert = UIAlertController(title: title, message: messsage, preferredStyle: .alert)
        
        if hasButton {
            let cancel = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(cancel)
        }

        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertLoading(title: String = "Titulo", peripheral: String, isOnActivity: Bool = true, hasButton: Bool = false) {
        UIAlertController.findCurrentController()?.dismiss(animated: true)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(label)
        alert.view.heightAnchor.constraint(equalToConstant: 170).isActive = true
        label.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50).isActive = true
        
        if isOnActivity {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.isUserInteractionEnabled = false
            alert.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            activityIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor).isActive = true
            activityIndicator.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15).isActive = true
        }
        
        if peripheral.isEmpty {
            label.text = "Desconhecido"
        } else {
            label.text = peripheral
        }
        
        if hasButton {
            let cancel = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(cancel)
        }
       
        alert.view.tintColor = .black
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

public extension UIViewController {

    static func findCurrentController(file: String = #file, line: Int = #line) -> UIViewController? {
        let window = UIWindow.keyWindow
        let controller = findCurrentController(base: window?.rootViewController)

        if controller == nil {
//            log.error("Unable to find current controller: \(file):\(line)")
        }

        return controller
    }

    static func findCurrentController(base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return findCurrentController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return findCurrentController(base: selected)
        } else if let presented = base?.presentedViewController {
            return findCurrentController(base: presented)
        }

        return base
    }

}

extension UIWindow {
    public static var keyWindow: UIWindow? {
        UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    }
}
