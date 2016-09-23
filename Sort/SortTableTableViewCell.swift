//
//  SortTableTableViewCell.swift
//  Table Planner
//
//  Created by Alex Erviti on 7/27/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class SortTableTableViewCell: UITableViewCell {
    
    // MARK: Properties

    @IBOutlet weak var tableNameLabel: UILabel!
    
    
    
    // MARK: View Prep
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
