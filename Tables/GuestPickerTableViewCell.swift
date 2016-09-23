//
//  GuestPickerTableViewCell.swift
//  Table Planner
//
//  Created by Alex Erviti on 6/28/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class GuestPickerTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var guestImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
