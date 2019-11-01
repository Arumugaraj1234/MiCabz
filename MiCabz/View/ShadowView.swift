//
//  ShadowView.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-07.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    override func awakeFromNib() {
        setupView()
    }
    
    func setupView() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
}
