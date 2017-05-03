//
//  PeopleTableViewCell.swift
//  Directory
//
//  Created by Kevin on 5/3/17.
//  Copyright © 2017 com.adient. All rights reserved.
//

import UIKit

class PeopleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImgView: UIImageView!
    
    @IBOutlet weak var nameLbl: UILabel!

    @IBOutlet weak var positionLbl: UILabel!
    
    @IBOutlet weak var locationImgView: UIImageView!
    
    @IBOutlet weak var locationNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
