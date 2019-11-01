//
//  CancelReasonCell.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-08-06.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit

class CancelReasonCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var reasonLbl: UILabel!
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var conView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView() {
        //statusImg.image = DESELECTED_CIRCLE
        conView.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(cancelReason: CancelReasonModel) {
        reasonLbl.text = cancelReason.reason
    }

}
