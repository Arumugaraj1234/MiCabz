//
//  HistoryCell.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-08-04.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var carImgView: UIImageView!
    @IBOutlet weak var travelDateLbl: UILabel!
    @IBOutlet weak var carTypeLbl: UILabel!
    @IBOutlet weak var fromLocationLbl: UILabel!
    @IBOutlet weak var destinationLocationLbl: UILabel!
    @IBOutlet weak var driverImg: UIImageView!
    @IBOutlet weak var tripStatusImg: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(history: RideHistoryModel) {
        travelDateLbl.text = history.travelDate
        carTypeLbl.text = history.carType + " " + "\(history.rideId!)"
        fromLocationLbl.text = history.fromLocation
        destinationLocationLbl.text = history.toLocation
        driverImg.downloadedFrom(link: history.driverProfile)
    }

}
