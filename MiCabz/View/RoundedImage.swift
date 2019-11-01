//
//  RoundedImage.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-12.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit

class RoundedImage: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }

}
