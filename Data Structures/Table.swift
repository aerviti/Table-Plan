//
//  Table.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/20/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import Foundation

class Table : NSObject, NSCoding {
    
    //MARK: - Enumerations
    enum TableType : String {
        case round = "Round";
        case oval = "Oval";
        case twoSidedRect = "Rectangular Two-Sided";
        case oneSidedRect = "Rectangular One-Sided";
    }
    
    static let tableTypeList = [TableType.round, TableType.oval, TableType.twoSidedRect, TableType.oneSidedRect];
    
    
    
    //MARK: - Properties
    
    var name: String;
    var tableGroup: String?;
    var tableType: TableType;
    var numOfSeats: Int;
    var seats: [Seat];
    var tableFull: Bool;
    var plan : TablePlan; //Table plan this table belongs to
    
    // UI properties
    var open : Bool = false;
    var x : Double = 0;
    var y : Double = 0;
    fileprivate var placed : Bool = false;
    var rotated: Bool = false;
    fileprivate var _edited: Bool = false;
    var edited: Bool {
        get {
            return _edited;
        }
        set (newVal) {
            if (placed != false) {
                _edited = newVal; //Ensures unnecessary edit checks won't occur on newly placed tables
            }
        }
    }
    
    
    
    //MARK: - Initialization
    
    init(name: String, tableType: TableType, numOfSeats: Int, tableGroup: String?, plan: TablePlan) {
        self.name = name;
        self.tableType = tableType;
        self.numOfSeats = numOfSeats;
        self.tableGroup = tableGroup;
        self.plan = plan;
        tableFull = false;
        //Make seat array based off of number of seats given and add their neighbors
        seats = [];
        super.init();
        var prevSeat : Seat? = nil;
        for seatNumber in 0..<numOfSeats {
            let seat = Seat(table: self, seatNum: seatNumber);
            seat.seatToLeft = prevSeat;
            prevSeat?.seatToRight = seat;
            prevSeat = seat;
            seats += [seat];
        }
        seats[numOfSeats - 1].seatToRight = seats[0];
        seats[0].seatToLeft = seats[numOfSeats - 1];
    }
    
    
    init(name: String, tableType: TableType, numOfSeats: Int, tableGroup: String?, plan: TablePlan, seats: [Seat], tableFull: Bool, x: Double, y: Double, placed: Bool, rotated: Bool) {
        self.name = name;
        self.tableType = tableType;
        self.numOfSeats = numOfSeats;
        self.tableGroup = tableGroup;
        self.plan = plan;
        self.seats = seats;
        self.tableFull = tableFull
        self.x = x;
        self.y = y;
        self.placed = placed;
        self.rotated = rotated;
    }
    
    
    
    //MARK: - Functions
    
    /* Function that returns the number of seats that currently have a guest seated in them. */
    func takenSeats() -> Int {
        var takenSeats = 0;
        for seat in seats {
            if seat.hasGuest() {
                takenSeats += 1;
            }
        }
        return takenSeats;
    }
    
    
    
    //MARK: - Data Methods
    
    /* Function that changes the number of seats at the table to the given Int. Adds or removes seats from the SEATS array as well as modifying the appropriate neighbor pointers of the seats in the array.*/
    func changeSeats(_ numOfSeats: Int) {
        if (numOfSeats > self.numOfSeats) {
            while (numOfSeats != self.numOfSeats) {
                addSeat();
                self.numOfSeats += 1;
            }
        }else if (numOfSeats < self.numOfSeats) {
            while (numOfSeats != self.numOfSeats) {
                self.numOfSeats -= 1;
                removeSeat();
            }
        }
    }
    
    
    /* Helper function for changeSeats() that adds one seat to the array and modifies the appropriate neighbor pointers of the seats. */
    fileprivate func addSeat() {
        let seat = Seat(table: self, seatNum: numOfSeats);
        let lastSeat = seats[numOfSeats - 1];
        seat.seatToRight = lastSeat.seatToRight;
        seat.seatToLeft = lastSeat;
        lastSeat.seatToRight?.seatToLeft = seat;
        lastSeat.seatToRight = seat;
        seats += [seat];
    }
    
    
    /* Helper function for changeSeats() that removes one seat from the array and modifies the appropriate neighbor pointers of the seats. */
    fileprivate func removeSeat() {
        let removedSeat = seats.removeLast();
        removedSeat.seatGuest(nil);
        let lastSeat = seats[numOfSeats - 1];
        lastSeat.seatToRight = removedSeat.seatToRight;
        removedSeat.seatToRight?.seatToLeft = lastSeat;
    }
    
    
    
    // MARK: - UI Floor Plan Methods
    
    /* Function that sets the coordinates where the table will be placed on the floor plan. */
    func placeTable(x: Double, y: Double) {
        self.x = x;
        self.y = y;
        placed = true;
    }
    
    
    /* Function that "removes" the table from a floor plan. */
    func unplaceTable() {
        self.x = 0;
        self.y = 0;
        placed = false;
        rotated = false;
    }
    
    
    /* Returns whether or not the table has been placed on the floor plan. */
    func isPlaced() -> Bool {
        return placed;
    }
    
    
    // MARK: Sorting Static Methods
    
    static func sortByName(_ first : Table, second : Table) -> Bool {
        return first.name < second.name;
    }
    
    
    
    
    // MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name");
        aCoder.encode(tableType.rawValue, forKey: "tableType");
        aCoder.encode(numOfSeats, forKey: "numOfSeats");
        aCoder.encode(tableGroup, forKey: "tableGroup");
        aCoder.encode(plan, forKey: "plan");
        aCoder.encode(seats, forKey: "seats");
        aCoder.encode(tableFull, forKey: "tableFull");
        aCoder.encode(x, forKey: "x");
        aCoder.encode(y, forKey: "y");
        aCoder.encode(placed, forKey: "placed");
        aCoder.encode(rotated, forKey: "rotated");
    }
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String;
        let tableType = TableType(rawValue: aDecoder.decodeObject(forKey: "tableType") as! String) ?? .round;
        let numOfSeats = aDecoder.decodeInteger(forKey: "numOfSeats");
        let tableGroup = aDecoder.decodeObject(forKey: "tableGroup") as? String;
        let plan = aDecoder.decodeObject(forKey: "plan") as! TablePlan;
        let seats = aDecoder.decodeObject(forKey: "seats") as! [Seat];
        let tableFull = aDecoder.decodeBool(forKey: "tableFull");
        let x = aDecoder.decodeDouble(forKey: "x");
        let y = aDecoder.decodeDouble(forKey: "y");
        let placed = aDecoder.decodeBool(forKey: "placed");
        let rotated = aDecoder.decodeBool(forKey: "rotated");
        self.init(name: name, tableType: tableType, numOfSeats: numOfSeats, tableGroup: tableGroup, plan: plan, seats: seats, tableFull: tableFull, x: x, y: y, placed: placed, rotated: rotated);
    }
    
}
