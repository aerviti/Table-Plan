//
//  TitleTableViewCell.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/24/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class TitleTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
