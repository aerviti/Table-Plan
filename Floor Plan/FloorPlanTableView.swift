//
//  FloorPlanTableView.swift
//  Table Planner
//
//  Created by Alex Erviti on 6/29/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class FloorPlanTableView: UIView {
    
    // MARK: Properties

    // UIView dimensions to keep consistency between tables
    static fileprivate let MAXTABLECIRCUMFERENCE: CGFloat = 280;
    static fileprivate let IMAGEWIDTH: CGFloat = 200;
    static fileprivate let IMAGEHEIGHT: CGFloat = 70;
    static fileprivate let SEATSPACING: CGFloat = 3;
    static fileprivate var TABLESEGMENT: CGFloat {
        return IMAGEWIDTH / 10;
    }
    static fileprivate var TABLEHEIGHT: CGFloat {
        return IMAGEHEIGHT / 2;
    }
    static fileprivate var CHAIRSIZE: CGFloat {
        return TABLESEGMENT - SEATSPACING*2;
    }
    
    // UIView dimensions to be instanced locally when initialized
    let maxTableCircumference = FloorPlanTableView.MAXTABLECIRCUMFERENCE;
    let seatSpacing = FloorPlanTableView.SEATSPACING;
    let tableSegment = FloorPlanTableView.TABLESEGMENT;
    let tableHeight = FloorPlanTableView.TABLEHEIGHT;
    let chairSize = FloorPlanTableView.CHAIRSIZE;
    
    // View Properties
    var table : Table? = nil;
    var seatImages: [UIImageView] = [UIImageView]();
    var tableView: UIView = UIView();
    var tableImg: UIImageView = UIImageView();
    var nameLabel: UILabel = UILabel();
    var groupLabel: UILabel = UILabel();
    var maxChairs = 20;
    
    // Reused UIImages
    let guestGray = UIImage(named: "guest");
    let guestBlack = UIImage(named: "guestBlack");
    
    
    
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        self.addSubview(tableView);
        tableView.isUserInteractionEnabled = false;
        tableView.addSubview(tableImg);
        nameLabel.textAlignment = .center;
        tableView.addSubview(nameLabel);
        groupLabel.textColor = UIColor.lightGray;
        groupLabel.textAlignment = .center;
        tableView.addSubview(groupLabel);
        
        for _ in 0..<maxChairs {
            let seatImg = UIImageView();
            seatImg.image = UIImage(named: "guest");
            seatImg.isHidden = true;
            seatImages += [seatImg];
            tableView.addSubview(seatImg);
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.addSubview(tableView);
        tableView.isUserInteractionEnabled = false;
        tableView.addSubview(tableImg);
        nameLabel.adjustsFontSizeToFitWidth = true;
        nameLabel.textAlignment = .center;
        tableView.addSubview(nameLabel);
        groupLabel.adjustsFontSizeToFitWidth = true;
        groupLabel.textColor = UIColor.lightGray;
        groupLabel.textAlignment = .center;
        tableView.addSubview(groupLabel);
        
        for _ in 0..<maxChairs {
            let seatImg = UIImageView();
            seatImg.image = UIImage(named: "guest");
            seatImg.isHidden = true;
            seatImages += [seatImg];
            tableView.addSubview(seatImg);
        }
        tableView.bringSubview(toFront: tableImg);
        tableView.bringSubview(toFront: nameLabel);
        tableView.bringSubview(toFront: groupLabel);
    }
    
    
    convenience init(table: Table) {
        
        let frame : CGRect!;
        let viewWidth: CGFloat!;
        let viewHeight: CGFloat!;
        
        switch (table.tableType) {
        case .oneSidedRect:
            viewWidth = FloorPlanTableView.TABLESEGMENT * CGFloat(table.numOfSeats);
            viewHeight = FloorPlanTableView.TABLEHEIGHT + FloorPlanTableView.CHAIRSIZE;
            
        case .twoSidedRect:
            viewWidth = FloorPlanTableView.TABLESEGMENT * CGFloat((table.numOfSeats+1) / 2);
            viewHeight = FloorPlanTableView.TABLEHEIGHT + FloorPlanTableView.CHAIRSIZE*2;
            
        case .oval:
            let tableWidth = FloorPlanTableView.TABLESEGMENT * CGFloat((table.numOfSeats+1)/2 - 1);
            viewWidth = tableWidth + FloorPlanTableView.CHAIRSIZE*2;
            viewHeight = FloorPlanTableView.TABLEHEIGHT + FloorPlanTableView.CHAIRSIZE*2;
            
        case .round:
            let tableCircumference = FloorPlanTableView.MAXTABLECIRCUMFERENCE/12 * CGFloat(table.numOfSeats);
            let tableRadius = tableCircumference / CGFloat(2*M_PI);
            viewWidth = tableRadius*2 + FloorPlanTableView.CHAIRSIZE*2;
            viewHeight = tableRadius*2 + FloorPlanTableView.CHAIRSIZE*2;
        }
        
        frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight);
        self.init(frame: frame);
    }
    
    

    // MARK: - View Loading
    
    override func draw(_ rect: CGRect) {
        if (table != nil) {
            tableView.isHidden = false;
            switch (table!.tableType) {
                case .oneSidedRect: layoutRectOneSided();
                case .twoSidedRect: layoutRectTwoSided();
                case .round: layoutRound();
                case .oval: layoutOval();
            }
            setSeatImages(table!.numOfSeats);
            hideSeatsAndLabels(table!.numOfSeats);
        }
    }
    
    
    fileprivate func layoutRectOneSided() {
        // Set self's frame in case of table edit
        if let frameDimensions = getDimensions(table!) {
            self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: frameDimensions.width, height: frameDimensions.height);
        }
        
        // Set view's frame to follow the given table
        tableView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height);
        nameLabel.text = table!.name;
        groupLabel.text = table!.tableGroup;
        nameLabel.frame = CGRect(x: 0, y: chairSize, width: self.bounds.width, height: tableHeight/2);
        groupLabel.frame = CGRect(x: 0, y: chairSize+tableHeight/2, width: self.bounds.width, height: tableHeight/2);
        
        // Set the table image's frame and image
        tableImg.frame = CGRect(x: 0, y: chairSize, width: self.bounds.width, height: tableHeight);
        tableImg.image = UIImage(named: "rectTable");
        
        // Place seat image views for each seat
        for chairNum in 0..<table!.numOfSeats {
            let currentSeat = seatImages[chairNum];
            let seatStartX = seatSpacing * CGFloat(chairNum+1) + (chairSize+seatSpacing) * CGFloat(chairNum);
            currentSeat.frame = CGRect(x: seatStartX, y: 0, width: chairSize, height: chairSize);
            currentSeat.isHidden = false;
        }
    }
    
    
    fileprivate func layoutRectTwoSided() {
        // Set self's frame in case of table edit
        if let frameDimensions = getDimensions(table!) {
            self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: frameDimensions.width, height: frameDimensions.height);
        }
        
        // Set view's frame to follow the given table
        tableView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height);
        nameLabel.text = table!.name;
        groupLabel.text = table!.tableGroup;
        nameLabel.frame = CGRect(x: 0, y: chairSize, width: self.bounds.width, height: tableHeight/2);
        groupLabel.frame = CGRect(x: 0, y: chairSize+tableHeight/2, width: self.bounds.width, height: tableHeight/2);
        
        // Set the table image's frame and image
        tableImg.frame = CGRect(x: 0, y: chairSize, width: self.bounds.width, height: tableHeight);
        tableImg.image = UIImage(named: "rectTable");
        
        // Place seat image views for each seat at the top of the table
        let firstHalf = (table!.numOfSeats+1) / 2;
        for chairNum in 0..<firstHalf {
            
            // Place seat UIImageView
            let currentSeat = seatImages[chairNum];
            let seatStartX = seatSpacing * CGFloat(chairNum+1) + (chairSize+seatSpacing) * CGFloat(chairNum);
            currentSeat.frame = CGRect(x: seatStartX, y: 0, width: chairSize, height: chairSize);
            currentSeat.isHidden = false;
        }
        
        // Place seat image views for each seat at the bottom of the table
        let secondHalf = table!.numOfSeats - firstHalf;
        let bottomSegment = self.bounds.width / CGFloat(secondHalf);
        let bottomSeatSpacing = (bottomSegment - chairSize) / 2;
        for chairNum in firstHalf..<table!.numOfSeats {
            
            // Place seat UIImageView
            let currentSeat = seatImages[chairNum];
            let chairLoopIndex = chairNum - firstHalf;
            let secondHalf = table!.numOfSeats - firstHalf - 1;
            let seatStartX = bottomSeatSpacing * CGFloat(secondHalf-chairLoopIndex+1) + (chairSize+bottomSeatSpacing) * CGFloat(secondHalf-chairLoopIndex);
            let seatStartY = chairSize + tableHeight;
            currentSeat.frame = CGRect(x: seatStartX, y: seatStartY, width: chairSize, height: chairSize);
            currentSeat.isHidden = false;
        }
    }
    
    
    fileprivate func layoutOval() {
        // Set self's frame in case of table edit
        if let frameDimensions = getDimensions(table!) {
            self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: frameDimensions.width, height: frameDimensions.height);
        }
        
        // Set view's frame to follow the given table
        let tableWidth = tableSegment * CGFloat((table!.numOfSeats+1)/2 - 1);
        tableView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height);
        nameLabel.text = table!.name;
        groupLabel.text = table!.tableGroup;
        nameLabel.frame = CGRect(x: chairSize, y: chairSize, width: tableWidth, height: tableHeight/2);
        groupLabel.frame = CGRect(x: chairSize, y: chairSize+tableHeight/2, width: tableWidth, height: tableHeight/2);
        
        // Set the table image's frame and image
        tableImg.frame = CGRect(x: chairSize, y: chairSize, width: tableWidth, height: tableHeight);
        tableImg.image = UIImage(named: "ovalTable");
        
        // Place seat image views for each seat at the top of the table
        var firstHalf = (table!.numOfSeats-1) / 2;
        for chairNum in 0..<firstHalf {
            
            // Place seat UIImageView
            let currentSeat = seatImages[chairNum];
            let seatStartX = seatSpacing * CGFloat(chairNum+1) + (chairSize+seatSpacing) * CGFloat(chairNum);
            currentSeat.frame = CGRect(x: seatStartX+chairSize, y: 0, width: chairSize, height: chairSize);
            currentSeat.isHidden = false;
        }
        
        // Place seat image on right of table
        let rightSeat = seatImages[firstHalf];
        let seatStartX = tableWidth + chairSize;
        var seatStartY = (self.bounds.height / 2) - (chairSize / 2);
        rightSeat.frame = CGRect(x: seatStartX, y: seatStartY, width: chairSize, height: chairSize);
        rightSeat.isHidden = false;
        firstHalf += 1;
        
        // Place seat image views for each seat at the bottom of the table
        let lastSeat = (table!.numOfSeats - 1);
        let secondHalf = table!.numOfSeats - firstHalf;
        let bottomSegment = tableWidth / CGFloat(secondHalf-1);
        let bottomSeatSpacing = (bottomSegment - chairSize) / 2;
        for chairNum in firstHalf..<lastSeat {
            
            // Place seat UIImageView
            let currentSeat = seatImages[chairNum];
            let chairLoopIndex = chairNum - firstHalf;
            let secondHalf = lastSeat - firstHalf - 1;
            let seatStartX = bottomSeatSpacing * CGFloat(secondHalf-chairLoopIndex+1) + (chairSize+bottomSeatSpacing) * CGFloat(secondHalf-chairLoopIndex);
            let seatStartY = chairSize + tableHeight;
            currentSeat.frame = CGRect(x: seatStartX+chairSize, y: seatStartY, width: chairSize, height: chairSize);
            currentSeat.isHidden = false;
        }
        
        // Place seat image and label on left of table
        let leftSeat = seatImages[lastSeat];
        seatStartY = (self.bounds.height / 2) - (chairSize / 2);
        leftSeat.frame = CGRect(x: 0, y: seatStartY, width: chairSize, height: chairSize);
        leftSeat.isHidden = false;
    }
    
    
    fileprivate func layoutRound() {
        // Set self's frame in case of table edit
        if let frameDimensions = getDimensions(table!) {
            self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: frameDimensions.width, height: frameDimensions.height);
        }
        
        // Set view's frame to follow the given table
        let tableCircumference = maxTableCircumference/12 * CGFloat(table!.numOfSeats);
        let tableRadius = tableCircumference / CGFloat(2*M_PI);
        tableView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height);
        nameLabel.text = table!.name;
        groupLabel.text = table!.tableGroup;
        nameLabel.frame = CGRect(x: chairSize, y: tableView.center.y-tableHeight/2, width: tableRadius*2, height: tableHeight/2);
        groupLabel.frame = CGRect(x: chairSize, y: tableView.center.y, width: tableRadius*2, height: tableHeight/2);
        
        // Set the table image's frame and image
        tableImg.frame = CGRect(x: chairSize, y: chairSize, width: tableRadius*2, height: tableRadius*2);
        tableImg.image = UIImage(named: "roundTable");
        //tableImg.center.x = tableView.frame.width / 2;
        //tableImg.center.y = tableView.frame.height / 2;
        
        // Place seat image views for each seat around the table
        let tableCenterX: CGFloat = tableView.center.x;
        let tableCenterY: CGFloat = tableView.center.y;
        let chairRadius: CGFloat = tableRadius + chairSize/2;
        let radianSegment: CGFloat = CGFloat(2*M_PI) / CGFloat(table!.numOfSeats);
        for chairNum in 0..<table!.numOfSeats {
            
            // Place seat UIImageView
            let currentSeat = seatImages[chairNum];
            let seatStartX = tableCenterX - chairRadius * cos(radianSegment * CGFloat(chairNum) + CGFloat(M_PI_2));
            let seatStartY = tableCenterY - chairRadius * sin(radianSegment * CGFloat(chairNum) + CGFloat(M_PI_2));
            currentSeat.frame = CGRect(x: 0, y: 0, width: chairSize, height: chairSize);
            currentSeat.center.x = seatStartX;
            currentSeat.center.y = seatStartY;
            currentSeat.isHidden = false;
        }
    }
    
    
    /* Helper function that returns a tuple with the appropriate width and height of a table only if it has been recently edited. Otherwise, returns nil. */
    fileprivate func getDimensions(_ table: Table) -> (width: CGFloat, height: CGFloat)? {
        if !table.edited {
            return nil;
        }
        
        let viewWidth: CGFloat!;
        let viewHeight: CGFloat!;
        
        switch (table.tableType) {
        case .oneSidedRect:
            viewWidth = FloorPlanTableView.TABLESEGMENT * CGFloat(table.numOfSeats);
            viewHeight = FloorPlanTableView.TABLEHEIGHT + FloorPlanTableView.CHAIRSIZE;
            
        case .twoSidedRect:
            viewWidth = FloorPlanTableView.TABLESEGMENT * CGFloat((table.numOfSeats+1) / 2);
            viewHeight = FloorPlanTableView.TABLEHEIGHT + FloorPlanTableView.CHAIRSIZE*2;
            
        case .oval:
            let tableWidth = FloorPlanTableView.TABLESEGMENT * CGFloat((table.numOfSeats+1)/2 - 1);
            viewWidth = tableWidth + FloorPlanTableView.CHAIRSIZE*2;
            viewHeight = FloorPlanTableView.TABLEHEIGHT + FloorPlanTableView.CHAIRSIZE*2;
            
        case .round:
            let tableCircumference = FloorPlanTableView.MAXTABLECIRCUMFERENCE/12 * CGFloat(table.numOfSeats);
            let tableRadius = tableCircumference / CGFloat(2*M_PI);
            viewWidth = tableRadius*2 + FloorPlanTableView.CHAIRSIZE*2;
            viewHeight = tableRadius*2 + FloorPlanTableView.CHAIRSIZE*2;
        }
        
        table.edited = false;
        return (viewWidth, viewHeight);
    }
    
    
    /* Sets a seat image to black if there is a guest seated, gray if there is no guest, or blue if it is the highlighted seat */
    fileprivate func setSeatImages(_ endIndex: Int) {
        for index in 0..<endIndex {
            let seat = table!.seats[index];
            let seatImage = seatImages[index];
            if (seat.hasGuest()) {
                seatImage.image = guestBlack;
            }else {
                seatImage.image = guestGray;
            }
        }
    }
    
    
    /* Hides the seat images and labels in the view that are not currently being used by the table */
    fileprivate func hideSeatsAndLabels(_ startIndex: Int) {
        for index in startIndex..<maxChairs {
            let seat = seatImages[index];
            seat.isHidden = true;
        }
    }

}
