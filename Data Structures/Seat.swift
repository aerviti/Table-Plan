//
//  Seat.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/20/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import Foundation
import FirebaseAnalytics

class Seat : NSObject, NSCoding {
    
    //MARK: - Properties
    
    weak var locatedAtTable: Table?;
    var seatNumOfTable: Int;
    weak var guestSeated: Guest?;
    weak var seatToLeft: Seat?;
    weak var seatToRight: Seat?;
    
    
    
    //MARK: - Initialization
    
    init(table: Table, seatNum: Int) {
        locatedAtTable = table;
        seatNumOfTable = seatNum;
    }
    
    
    init(table: Table, seatNum: Int, guestSeated: Guest?, seatToLeft: Seat?, seatToRight: Seat?) {
        self.locatedAtTable = table;
        self.seatNumOfTable = seatNum;
        self.guestSeated = guestSeated;
        self.seatToLeft = seatToLeft;
        self.seatToRight = seatToRight;
    }
    
    
    
    //MARK: - Functions
    
    func seatGuest(_ guest: Guest?) {
        guard let parentPlan = locatedAtTable?.plan else {
            print("No parent table set for seat or no parent plan for parent table set. (seatGuest)");
            FIRAnalytics.logEvent(withName: "Caught_Error", parameters: [
                "name": "seatGuest" as NSObject,
                "full_text": "No parent table set for seat or no parent plan for parent table set." as NSObject
                ]);
            return;
        }
        if (guestSeated != nil && guestSeated != guest) {
            parentPlan.unseated += 1;
        }
        if (guest != nil && !guest!.isSeated()) {
            parentPlan.unseated -= 1;
        }
        guestSeated?.seat = nil;
        guestSeated = guest;
        guest?.seat?.guestSeated = nil;
        guest?.table = self.locatedAtTable;
        guest?.seat = self;
    }
    
    
    func hasGuest() -> Bool {
        return guestSeated != nil;
    }
    
    
    
    //MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(locatedAtTable, forKey: "locatedAtTable");
        aCoder.encode(seatNumOfTable, forKey: "seatNumOfTable");
        aCoder.encode(guestSeated, forKey: "guestSeated");
        aCoder.encode(seatToLeft, forKey: "seatToLeft");
        aCoder.encode(seatToRight, forKey: "seatToRight");
    }
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        let locatedAtTable = aDecoder.decodeObject(forKey: "locatedAtTable") as! Table;
        let seatNumOfTable = aDecoder.decodeInteger(forKey: "seatNumOfTable");
        let guestSeated = aDecoder.decodeObject(forKey: "guestSeated") as? Guest;
        let seatToLeft = aDecoder.decodeObject(forKey: "seatToLeft") as? Seat;
        let seatToRight = aDecoder.decodeObject(forKey: "seatToRight") as? Seat;
        self.init(table: locatedAtTable, seatNum: seatNumOfTable, guestSeated: guestSeated, seatToLeft: seatToLeft, seatToRight: seatToRight);
    }
}
