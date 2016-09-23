//
//  GuestTableViewCell.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/30/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class GuestTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var seatLabel: UILabel!
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
