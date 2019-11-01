//
//  FavouritesCell.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-08-02.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit

class FavouritesCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var addressNameLbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
    func updateUIView(favourites: FavouritesModel) {
        addressNameLbl.text = favourites.address
    }

}
