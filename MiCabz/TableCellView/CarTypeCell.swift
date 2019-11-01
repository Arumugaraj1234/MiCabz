//
//  CarTypeCell.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-11.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit

class CarTypeCell: UICollectionViewCell {
    //Outlets
    @IBOutlet weak var cellBgView: UIView!
    @IBOutlet weak var carNameLbl: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var rideCostLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    
    func setupView() {
        cellBgView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cellBgView.layer.borderWidth = 1.0
        cellBgView.layer.cornerRadius = 5.0
    }
    
    func configureCell(carType: CarType) {
        carNameLbl.text = carType.carName
        rideCostLbl.text = "Ride Cost Rs.\(carType.rideCost!)/- aprox"
    }
    
    
}
