//
//  RoundedButton.swift
//  Cinema
//
//  Created by Кирилл Кузнецов on 24.04.2022.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {

    @IBInspectable var borderRadius: CGFloat = 4.0 {
        didSet { self.layer.cornerRadius = borderRadius }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet { self.layer.borderColor = borderColor.cgColor }
    }
    
    @IBInspectable var borderLine: CGFloat = 1.0 {
        didSet { self.layer.borderWidth = borderLine }
    }

}
