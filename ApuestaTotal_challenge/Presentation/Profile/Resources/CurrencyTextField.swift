//
//  CurrencyTextField.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 19/03/26.
//

import UIKit

class CurrencyTextField: UITextField {
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = "S/ "
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .bettingTextSecondary
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        keyboardType = .decimalPad
        textAlignment = .left
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: frame.height))
        currencyLabel.frame = CGRect(x: 8, y: 0, width: 32, height: frame.height)
        paddingView.addSubview(currencyLabel)
        leftView = paddingView
        leftViewMode = .always
        
        borderStyle = .roundedRect
        backgroundColor = .bettingCardBackground
        textColor = .bettingTextPrimary
        font = .systemFont(ofSize: 17, weight: .semibold)
        
        attributedPlaceholder = NSAttributedString(
            string: "0.00",
            attributes: [.foregroundColor: UIColor.bettingTextMuted]
        )
        
        addDoneButton()
    }
    
    private func addDoneButton() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(
            title: "Listo",
            style: .done,
            target: self,
            action: #selector(dismissKeyboard)
        )
        doneButton.tintColor = .bettingAccent
        
        toolbar.items = [flexSpace, doneButton]
        toolbar.barTintColor = .bettingSurfaceBackground
        toolbar.tintColor = .bettingAccent
        
        inputAccessoryView = toolbar
    }
    
    @objc private func dismissKeyboard() {
        resignFirstResponder()
    }
    
    func getAmount() -> Double? {
        guard let text = text, !text.isEmpty else { return nil }
        
        let cleanedText = text
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: "")
        
        return Double(cleanedText)
    }
    
    /// Formatea el texto mientras se escribe
    func formatCurrency() {
        guard let text = text, !text.isEmpty else { return }
        
        let filtered = text.filter { "0123456789.".contains($0) }
        
        let components = filtered.components(separatedBy: ".")
        if components.count > 2 {
            self.text = components[0] + "." + components[1]
        } else {
            self.text = filtered
        }
        
        if let dotIndex = self.text?.firstIndex(of: ".") {
            let afterDot = self.text![self.text!.index(after: dotIndex)...]
            if afterDot.count > 2 {
                self.text = String(self.text!.prefix(self.text!.count - (afterDot.count - 2)))
            }
        }
    }
}
