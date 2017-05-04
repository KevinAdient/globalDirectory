//
//  PlaceTableViewCell.swift
//  Directory
//
//  Created by Kevin on 5/4/17.
//  Copyright © 2017 com.adient. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeImgView: UIImageView!
    
    @IBOutlet weak var placeLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
