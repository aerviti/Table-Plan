//
//  TableTableViewCell.swift
//  Table Planner
//
//  Created by Alex Erviti on 6/3/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class TableTableViewCell: UITableViewCell {

    @IBOutlet weak var tableName: UILabel!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var seatedLabel: UILabel!
    @IBOutlet weak var openTableButton: TableButton!
    var opened : Bool = false;

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
