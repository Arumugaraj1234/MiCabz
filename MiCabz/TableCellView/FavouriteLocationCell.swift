//
//  FavouriteLocationCell.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-08-04.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit

class FavouriteLocationCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var favouriteAddressLbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    func configureCell(favourite: FavouritesModel) {
        favouriteAddressLbl.text = favourite.address
    }



}
