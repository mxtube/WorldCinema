//
//  RoundedTextField.swift
//  Cinema
//
//  Created by Кирилл Кузнецов on 24.04.2022.
//

import UIKit

@IBDesignable
class RoundedTextField: UITextField {
    
    @IBInspectable var borderRadius: CGFloat = 4.0 {
        didSet { self.layer.cornerRadius = borderRadius }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor(named: "TextFieldBorderColor") ?? .clear {
        didSet { self.layer.borderColor = borderColor.cgColor }
    }
    
    @IBInspectable var borderLine: CGFloat = 1.0 {
        didSet { self.layer.borderWidth = borderLine }
    }
    
    @IBInspectable var placeholderColor: UIColor = UIColor(named: "TextFieldPlaceholderTextColor") ?? .clear {
        didSet {
            self.attributedPlaceholder = NSAttributedString(
                string: self.placeholder?.description ?? "",
                attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
            )
        }
    }
    
    @IBInspectable var placeholderTextEdgeLeft: CGFloat = 16.0 {
        didSet {
            self.leftViewMode = .always
            self.leftView = UIView(frame: CGRect(x: self.frame.minX, y: self.frame.maxY, width: placeholderTextEdgeLeft, height: self.frame.height))
        }
    }
}
