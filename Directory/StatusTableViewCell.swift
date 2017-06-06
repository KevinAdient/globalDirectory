//
//  StatusTableViewCell.swift
//  Directory
//
//  Created by Kun Huang on 6/5/17.
//  Copyright © 2017 com.adient. All rights reserved.
//

import UIKit



class StatusTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statusImgView: UIImageView!
    
    @IBOutlet weak var statusLbl: UILabel!

    @IBOutlet weak var isSelectedImgView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
