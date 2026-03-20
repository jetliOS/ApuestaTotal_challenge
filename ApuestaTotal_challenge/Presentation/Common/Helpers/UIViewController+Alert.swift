//
//  UIViewController+Alert.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
