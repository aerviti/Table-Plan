//
//  TableImageView.swift
//  Table Planner
//
//  Created by Alex Erviti on 6/6/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class TableImageView: UIView {

    // MARK: Properties
    
    var table : Table? = nil;
    var seatImages : [UIImageView] = [UIImageView]();
    var seatLabels : [UILabel] = [UILabel]();
    var tableView : UIView = UIView();
    var tableImg : UIImageView = UIImageView();
    var emptyLabel : UILabel = UILabel();
    var maxChairs = 20;
    var roundMaxChairs = 12;
    var highlightedSeat : Int? = nil;
    
    //Reused UIImages
    let guestGray = UIImage(named: "guest");
    let guestBlack = UIImage(named: "guestBlack");
    let guestBlue = UIImage(named: "guestBlue");
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        self.addSubview(tableView);
        tableView.isUserInteractionEnabled = false;
        tableView.addSubview(tableImg);
        
        for index in 0..<maxChairs {
            let seatImg = UIImageView();
            seatImg.image = UIImage(named: "guest");
            seatImg.isHidden = true;
            seatImages += [seatImg];
            tableView.addSubview(seatImg);
            
            let seatLabel = UILabel();
            seatLabel.adjustsFontSizeToFitWidth = true;
            seatLabel.textAlignment = .center;
            seatLabel.textColor = UIColor.lightGray;
            seatLabel.text = String(index);
            seatLabel.isHidden = true;
            seatLabels += [seatLabel];
            tableView.addSubview(seatLabel);
        }
        
        tableView.bringSubview(toFront: tableImg);
        emptyLabel.textColor = UIColor.lightGray;
        self.addSubview(emptyLabel);
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.addSubview(tableView);
        tableView.isUserInteractionEnabled = false;
        tableView.addSubview(tableImg);
        
        for index in 0..<maxChairs {
            let seatImg = UIImageView();
            seatImg.image = UIImage(named: "guest");
            seatImg.isHidden = true;
            seatImages += [seatImg];
            tableView.addSubview(seatImg);
            
            let seatLabel = UILabel();
            seatLabel.adjustsFontSizeToFitWidth = true;
            seatLabel.textAlignment = .center;
            seatLabel.textColor = UIColor.lightGray;
            seatLabel.text = String(index);
            seatLabel.isHidden = true;
            seatLabels += [seatLabel];
            tableView.addSubview(seatLabel);
        }
        
        emptyLabel.textColor = UIColor.lightGray;
        self.addSubview(emptyLabel);
    }
    
    // MARK: View Loading
    
    override func draw(_ rect: CGRect) {
        if (table == nil) {
            emptyLabel.isHidden = false;
            tableView.isHidden = true;
            layoutNoTable();
        }else {
            emptyLabel.isHidden = true;
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
        // Resize outer tableView to house table image and chair images
        let tableSegmentSize = self.frame.width / CGFloat(maxChairs / 2);
        let viewWidth = tableSegmentSize * CGFloat(table!.numOfSeats);
        tableView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: self.frame.height)
        
        // Place rectangular table image view at tableView's center
        let tableHeight = tableView.frame.height / 3;
        tableImg.frame = CGRect(x: 0, y: 0, width: viewWidth, height: tableHeight);
        tableImg.image = UIImage(named: "rectTable");
        tableImg.center.x = tableView.frame.size.width / 2;
        tableImg.center.y = tableView.frame.size.height / 2;
        
        // Place seat image and label views for each seat
        let seatSpacing = CGFloat(6);
        let chairSize = tableSegmentSize - seatSpacing*2;
        for chairNum in 0..<table!.numOfSeats {
            
            // Place seat UIImageView
            let currentSeat = seatImages[chairNum];
            let seatStartX = seatSpacing * CGFloat(chairNum+1) + (chairSize+seatSpacing) * CGFloat(chairNum);
            let seatStartY = (tableView.frame.height / 2) - (tableHeight / 2) - chairSize;
            currentSeat.frame = CGRect(x: seatStartX, y: seatStartY, width: chairSize, height: chairSize);
            currentSeat.isHidden = false;
            
            // Place seat UILabel
            let currentLabel = seatLabels[chairNum];
            currentLabel.frame = CGRect(x: seatStartX, y: seatStartY - chairSize, width: chairSize, height: chairSize);
            currentLabel.text = String(chairNum + 1);
            currentLabel.isHidden = false;
        }
        
        // Place tableView
        tableView.center.x = self.frame.width / 2;
        tableView.center.y = self.frame.height / 2;
    }
    
    fileprivate func layoutRectTwoSided() {
        // Resize outer tableView to house table image and chair images
        var tableSegmentSize = self.frame.width / CGFloat(maxChairs / 2);
        let viewWidth = tableSegmentSize * CGFloat((table!.numOfSeats+1) / 2);
        tableView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: self.frame.height);
        
        // Place rectangular table image view at tableView's center
        let tableHeight = tableView.frame.height / 3;
        tableImg.frame = CGRect(x: 0, y: 0, width: viewWidth, height: tableHeight);
        tableImg.image = UIImage(named: "rectTable");
        tableImg.center.x = tableView.frame.size.width / 2;
        tableImg.center.y = tableView.frame.size.height / 2;
        
        // Place seat image and label views for each seat at the top of the table
        var seatSpacing = CGFloat(6);
        let chairSize = tableSegmentSize - seatSpacing*2;
        let firstHalf = (table!.numOfSeats+1) / 2;
        for chairNum in 0..<firstHalf {
            
            // Place seat UIImageView
            let currentSeat = seatImages[chairNum];
            let seatStartX = seatSpacing * CGFloat(chairNum+1) + (chairSize+seatSpacing) * CGFloat(chairNum);
            let seatStartY = (tableView.frame.height / 2) - (tableHeight / 2) - chairSize;
            currentSeat.frame = CGRect(x: seatStartX, y: seatStartY, width: chairSize, height: chairSize);
            currentSeat.isHidden = false;
            
            // Place seat UILabel
            let currentLabel = seatLabels[chairNum];
            currentLabel.frame = CGRect(x: seatStartX, y: seatStartY - chairSize, width: chairSize, height: chairSize);
            currentLabel.text = String(chairNum + 1);
            currentLabel.isHidden = false;
        }
        
        // Place seat image and label views for each seat at the bottom of the table
        let secondHalf = table!.numOfSeats - firstHalf;
        tableSegmentSize = viewWidth / CGFloat(secondHalf);
        seatSpacing = (tableSegmentSize - chairSize) / 2;
        for chairNum in firstHalf..<table!.numOfSeats {
            
            // Place seat UIImageView
            let currentSeat = seatImages[chairNum];
            let chairLoopIndex = chairNum - firstHalf;
            let secondHalf = table!.numOfSeats - firstHalf - 1;
            let seatStartX = seatSpacing * CGFloat(secondHalf-chairLoopIndex+1) + (chairSize+seatSpacing) * CGFloat(secondHalf-chairLoopIndex);
            let seatStartY = (tableView.frame.height / 2) + (tableHeight / 2);
            currentSeat.frame = CGRect(x: seatStartX, y: seatStartY, width: chairSize, height: chairSize);
            currentSeat.isHidden = false;
            //currentSeat.transform = CGAffineTransformMakeScale(1, -1);
            
            // Place seat UILabel
            let currentLabel = seatLabels[chairNum];
            currentLabel.frame = CGRect(x: seatStartX, y: seatStartY + chairSize, width: chairSize, height: chairSize);
            currentLabel.text = String(chairNum + 1);
            currentLabel.isHidden = false;
        }
        
        // Place tableView
        tableView.center.x = self.frame.width / 2;
        tableView.center.y = self.frame.height / 2;
    }
    
    fileprivate func layoutOval() {
        // Resize outer tableView to house table image and chair images
        var tableSegmentSize = self.frame.width / CGFloat(maxChairs / 2);
        let viewWidth = tableSegmentSize * CGFloat((table!.numOfSeats-1) / 2);
        tableView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: self.frame.height);
        
        // Place oval table image view at tableView's center
        let tableHeight = tableView.frame.height / 3;
        tableImg.frame = CGRect(x: 0, y: 0, width: viewWidth, height: tableHeight);
        tableImg.image = UIImage(named: "ovalTable");
        tableImg.center.x = tableView.frame.size.width / 2;
        tableImg.center.y = tableView.frame.size.height / 2;
        
        // Place seat image and label views for each seat at the top of the table
        var seatSpacing = CGFloat(6);
        let chairSize = tableSegmentSize - seatSpacing*2;
        var firstHalf = (table!.numOfSeats-1) / 2;
        for chairNum in 0..<firstHalf {
            
            // Place seat UIImageView
            let currentSeat = seatImages[chairNum];
            let seatStartX = seatSpacing * CGFloat(chairNum+1) + (chairSize+seatSpacing) * CGFloat(chairNum);
            let seatStartY = (tableView.frame.height / 2) - (tableHeight / 2) - chairSize;
            currentSeat.frame = CGRect(x: seatStartX, y: seatStartY, width: chairSize, height: chairSize);
            currentSeat.isHidden = false;
            
            // Place seat UILabel
            let currentLabel = seatLabels[chairNum];
            currentLabel.frame = CGRect(x: seatStartX, y: seatStartY - chairSize, width: chairSize, height: chairSize);
            currentLabel.text = String(chairNum + 1);
            currentLabel.isHidden = false;
        }
        
        // Place seat image and label on right of table
        let rightSeat = seatImages[firstHalf];
        var seatStartX = viewWidth;
        var seatStartY = (tableView.frame.height / 2) - (chairSize / 2);
        rightSeat.frame = CGRect(x: seatStartX, y: seatStartY, width: chairSize, height: chairSize);
        rightSeat.isHidden = false;
        var currentLabel = seatLabels[firstHalf];
        currentLabel.frame = CGRect(x: seatStartX, y: seatStartY - chairSize, width: chairSize, height: chairSize);
        currentLabel.text = String(firstHalf + 1);
        currentLabel.isHidden = false;
        firstHalf += 1;
        
        // Place seat image and label views for each seat at the bottom of the table
        let lastSeat = (table!.numOfSeats - 1);
        let secondHalf = lastSeat - firstHalf;
        tableSegmentSize = viewWidth / CGFloat(secondHalf);
        seatSpacing = (tableSegmentSize - chairSize) / 2;
        for chairNum in firstHalf..<lastSeat {
            
            // Place seat UIImageView
            let currentSeat = seatImages[chairNum];
            let chairLoopIndex = chairNum - firstHalf;
            let secondHalf = lastSeat - firstHalf - 1;
            let seatStartX = seatSpacing * CGFloat(secondHalf-chairLoopIndex+1) + (chairSize+seatSpacing) * CGFloat(secondHalf-chairLoopIndex);
            let seatStartY = (tableView.frame.height / 2) + (tableHeight / 2);
            currentSeat.frame = CGRect(x: seatStartX, y: seatStartY, width: chairSize, height: chairSize);
            currentSeat.isHidden = false;
            //currentSeat.transform = CGAffineTransformMakeScale(1, -1);
            
            // Place seat UILabel
            let currentLabel = seatLabels[chairNum];
            currentLabel.frame = CGRect(x: seatStartX, y: seatStartY + chairSize, width: chairSize, height: chairSize);
            currentLabel.text = String(chairNum + 1);
            currentLabel.isHidden = false;
        }
        
        // Place seat image and label on left of table
        let leftSeat = seatImages[lastSeat];
        seatStartX = -chairSize;
        seatStartY = (tableView.frame.height / 2) - (chairSize / 2);
        leftSeat.frame = CGRect(x: seatStartX, y: seatStartY, width: chairSize, height: chairSize);
        leftSeat.isHidden = false;
        currentLabel = seatLabels[lastSeat];
        currentLabel.frame = CGRect(x: seatStartX, y: seatStartY - chairSize, width: chairSize, height: chairSize);
        currentLabel.text = String(lastSeat + 1);
        currentLabel.isHidden = false;
        
        // Place tableView
        tableView.center.x = self.frame.width / 2;
        tableView.center.y = self.frame.height / 2;
    }
    
    fileprivate func layoutRound() {
        // Resize outer tableView to house table image and chair images
        let chairSize: CGFloat = 20;
        let maxCircumference = 2 * ((self.frame.height/2)-chairSize*2) * CGFloat(M_PI);
        let tableSegmentSize = maxCircumference / CGFloat(roundMaxChairs);
        let tableRadius = (tableSegmentSize*CGFloat(table!.numOfSeats)) / CGFloat(2*M_PI);
        let tableDimension = tableRadius*2;
        let viewDimension = tableDimension + chairSize*4;
        tableView.frame = CGRect(x: 0, y: 0, width: viewDimension, height: viewDimension);
        
        // Place round table image view at tableView's center
        tableImg.frame = CGRect(x: 0, y: 0, width: tableDimension, height: tableDimension);
        tableImg.image = UIImage(named: "roundTable");
        tableImg.center.x = tableView.frame.width / 2;
        tableImg.center.y = tableView.frame.height / 2;
        
        
        // Place seat image and label views for each seat around the table
        let tableCenterX: CGFloat = tableView.center.x;
        let tableCenterY: CGFloat = tableView.center.y;
        let chairRadius: CGFloat = tableRadius + chairSize/2;
        let labelRadius: CGFloat = chairRadius + chairSize;
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
            
            // Place seat UILabel
            let currentLabel = seatLabels[chairNum];
            let labelStartX = tableCenterX - labelRadius * cos(radianSegment * CGFloat(chairNum) + CGFloat(M_PI_2));
            let labelStartY = tableCenterY - labelRadius * sin(radianSegment * CGFloat(chairNum) + CGFloat(M_PI_2));
            currentLabel.frame = CGRect(x: 0, y: 0, width: chairSize, height: chairSize);
            currentLabel.center.x = labelStartX;
            currentLabel.center.y = labelStartY;
            currentLabel.text = String(chairNum + 1);
            currentLabel.isHidden = false;
        }
        
        // Place tableView
        tableView.center.x = self.frame.width / 2;
        tableView.center.y = self.frame.height / 2;
    }
    
    fileprivate func layoutNoTable() {
        let labelHeight = self.frame.height / 3;
        emptyLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: labelHeight);
        emptyLabel.text = "No Table";
        emptyLabel.center.y = self.frame.height / 2;
        emptyLabel.textAlignment = .center;
    }
    
    //Sets a seat image to black if there is a guest seated, gray if there is no guest, or blue if it is the highlighted seat
    fileprivate func setSeatImages(_ endIndex: Int) {
        for index in 0..<endIndex {
            let seat = table!.seats[index];
            let seatImage = seatImages[index];
            if (index == highlightedSeat) {
                seatImage.image = guestBlue;
            }else if (seat.hasGuest()) {
                seatImage.image = guestBlack;
            }else {
                seatImage.image = guestGray;
            }
        }
    }
    
    //Hides the seat images and labels in the view that are not currently being used by the table
    fileprivate func hideSeatsAndLabels(_ startIndex: Int) {
        for index in startIndex..<maxChairs {
            let seat = seatImages[index];
            let seatLabel = seatLabels[index];
            seat.isHidden = true;
            seatLabel.isHidden = true;
        }
    }

}
