//
//  SeatTableViewCell.swift
//  Table Planner
//
//  Created by Alex Erviti on 6/20/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class SeatTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var seatNumberLabel: UILabel!
    @IBOutlet weak var seatGuestLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
