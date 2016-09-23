//
//  TableImageTableViewCell.swift
//  Table Planner
//
//  Created by Alex Erviti on 6/3/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class TableImageTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var tableImageView: TableImageView!
    
    
    /*
    override func layoutSubviews() {
        let tableImageView = TableImageView();
        tableImageView.table = Table(name: "Tab", tableType: .oneSidedRect, numOfSeats: 4, tableGroup: nil);
        tableImageView.translatesAutoresizingMaskIntoConstraints = false;
        self.contentView.addSubview(tableImageView);
        
        let c1 = NSLayoutConstraint(item: tableImageView, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1, constant: 0);
        let c2 = NSLayoutConstraint(item: tableImageView, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1, constant: 0);
        let c3 = NSLayoutConstraint(item: tableImageView, attribute: .Leading, relatedBy: .Equal, toItem: self.contentView, attribute: .Leading, multiplier: 1, constant: 0);
        let c4 = NSLayoutConstraint(item: tableImageView, attribute: .Trailing, relatedBy: .Equal, toItem: self.contentView, attribute: .Trailing, multiplier: 1, constant: 0);
        self.contentView.addConstraints([c1, c2, c3, c4]);
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
