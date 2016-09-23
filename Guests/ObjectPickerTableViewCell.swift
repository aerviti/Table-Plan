//
//  ObjectPickerTableViewCell.swift
//  Table Planner
//
//  Created by Alex Erviti on 7/23/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class ObjectPickerTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var objectImage: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
