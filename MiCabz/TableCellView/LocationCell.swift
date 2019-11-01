//
//  LocationCell.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-07.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    var addressLbl:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addressLbl = UILabel()
        addressLbl.frame = CGRect(x: 10, y: 10.0, width: contentView.frame.width - 20, height: 30.0)
        addressLbl.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        addressLbl.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)
        contentView.addSubview(addressLbl)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6)
            addressLbl.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            contentView.backgroundColor = UIColor.clear
            addressLbl.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    func configureCell(title: String) {
        addressLbl.text = title
    }
    
}
