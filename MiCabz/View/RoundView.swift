//
//  RoundView.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-07.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit

class RoundView: UIView {

    override func awakeFromNib() {
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = self.frame.width / 2
    }

}
