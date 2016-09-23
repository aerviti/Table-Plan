//
//  Guest.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/20/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import Foundation

class Guest : NSObject, NSCoding {
    
    //MARK: - Properties
    var firstName: String;
    var lastName: String;
    var table: Table?;
    var seat: Seat?;
    
    enum GuestError: Error {
        case sameGuestError;
        case constraintTooBigError;
        case alreadyIncludedError;
    }
    
    
    
    //MARK: Constraint Properties
    
    var mustSitNextTo: Set<Guest>;
    var mustSitNextToSize: Int {
        return mustSitNextTo.count;
    }
    var mustSitAtTable: Set<Guest>;
    var mustSitAtTableSize: Int {
        return mustSitAtTable.count;
    }
    var cannotSitNextTo: Set<Guest>;
    var cannotSitNextToSize: Int {
        return cannotSitNextTo.count;
    }
    var cannotSitAtTable: Set<Guest>;
    var cannotSitAtTableSize: Int {
        return cannotSitAtTable.count;
    }
    var tableConstraint: Table?;;
    var hasTableConstraint: Bool {
        return tableConstraint != nil;
    }
    var groupConstraint: String?;;
    var hasGroupConstraint: Bool {
        return groupConstraint != nil;
    }
    var seatedRandomly: Bool = false; //Only used during the sorting process by TableSorter
    var tabledRandomly: Bool = false; //Only used during the sorting process by TableSorter
    //var alreadySeated: Bool = false; // Only used during the sorting process by TableSorter
    
    
    //MARK: - Initialization
    
    init(firstName: String, lastName: String, table: Table?, seat: Seat?) {
        self.firstName = firstName;
        self.lastName = lastName;
        self.table = table;
        self.seat = seat;
        self.mustSitNextTo = Set<Guest>();
        self.mustSitAtTable = Set<Guest>();
        self.cannotSitNextTo = Set<Guest>();
        self.cannotSitAtTable = Set<Guest>();
        self.tableConstraint = nil;
        self.groupConstraint = nil;
    }
    
    
    init(firstName: String, lastName: String, table: Table?, seat: Seat?, msnt: Set<Guest>, msat: Set<Guest>, csnt: Set<Guest>, csat: Set<Guest>, groupC: String?, tableC: Table?) {
        self.firstName = firstName;
        self.lastName = lastName;
        self.table = table;
        self.seat = seat;
        self.mustSitNextTo = msnt;
        self.mustSitAtTable = msat;
        self.cannotSitNextTo = csnt;
        self.cannotSitAtTable = csat;
        self.groupConstraint = groupC;
        self.tableConstraint = tableC;
    }
    
    
    
    //MARK: - Methods
    
    /* Returns true if the Guest has a seat, false if the Guest does not. */
    func isSeated() -> Bool {
        return seat != nil;
    }
    
    
    /* Returns true if the Guest has an assigned table, false if the Guest does not. */
    func isTabled() -> Bool {
        return table != nil;
    }
    
    
    /* Return a String representation of the seat number the guest is sitting in. Return NIL if there is no seat. */
    func getSeatString() -> String? {
        if (seat != nil) {
            return String(seat!.seatNumOfTable + 1);
        }else {
            return nil;
        }
    }
    
    
    /* Returns full name of guest depending on the current sort */
    func getFullName(_ sort: TablePlan.GuestSort) -> String {
        if (sort == .LastName || sort == .UnseatedLastName) {
            return lastName + ", " + firstName;
        }
        return firstName + " " + lastName;
    }
    
    
    
    // MARK: - Constraint Methods
    
    /* Function that clears all of this guest's constraints. */
    func clearConstraints() {
        for guest in mustSitNextTo {
            removeMustSitNextTo(guest);
        }
        for guest in mustSitAtTable {
            removeMustSitAtTableOf(guest);
        }
        for guest in cannotSitNextTo {
            removeCannotSitNextTo(guest);
        }
        for guest in cannotSitAtTable {
            removeCannotSitAtTableOf(guest);
        }
        removeTableConstraint();
        removeGroupConstraint();
    }
    
    // MARK: Table Constraint
    
    /* Returns a string version of the tableConstraint */
    func getTableConstraintString() -> String? {
        return tableConstraint?.name;
    }
    
    
    /* Adds a table to the tableConstraint variable */
    func addTableConstraint(_ table: Table) {
        tableConstraint = table;
        for guest in mustSitAtTable {
            guest.tableConstraint = table;
        }
        for chain in getNeighborChains() {
            for guest in chain {
                guest.tableConstraint = table;
            }
        }
    }
    
    
    /* Removes a table from the tableConstraint variable */
    func removeTableConstraint() {
        tableConstraint = nil;
        for guest in mustSitAtTable {
            guest.tableConstraint = nil;
        }
        for chain in getNeighborChains() {
            for guest in chain {
                guest.tableConstraint = nil;
            }
        }
    }
    
    
    // MARK: Group Constraint
    
    /* Returns the string of the groupConstraint */
    func getGroupConstraintString() -> String? {
        return groupConstraint;
    }
    
    
    /* Adds a group to the groupConstraint variable */
    func addGroupConstraint(_ string: String) {
        groupConstraint = string;
        for guest in mustSitAtTable {
            guest.groupConstraint = string;
        }
        for chain in getNeighborChains() {
            for guest in chain {
                guest.groupConstraint = string;
            }
        }
    }
    
    
    /* Removes a group from the groupConstraint variable */
    func removeGroupConstraint() {
        groupConstraint = nil;
        for guest in mustSitAtTable {
            guest.groupConstraint = nil;
        }
        for chain in getNeighborChains() {
            for guest in chain {
                guest.groupConstraint = nil;
            }
        }
    }
    
    
    // MARK: Must Sit Next To Constraint
    
    /* Return an array version of the mustSitNextTo set */
    func getMustSitNextTo() -> [Guest] {
        return Array(mustSitNextTo);
    }
    
    
    /* Returns a string representation of the mustSitNextTo set */
    func getMustSitNextToString() -> String {
        return returnStringFromSet(mustSitNextTo);
    }
    
    
    /* Adds a guest to the "Must Sit Next To" array */
    @discardableResult
    func mustSitNextTo(_ guest: Guest) throws -> Bool {
        if (guest == self) {
            throw GuestError.sameGuestError;
        }else if (mustSitNextTo.contains(guest)) {
            throw GuestError.alreadyIncludedError;
        }
        
        if (mustSitNextTo.count < 2 && guest.mustSitNextTo.count < 2) {
            do { try mustSitAtTableOf(guest);
            }catch GuestError.alreadyIncludedError {
                //Do nothing as is fine
            }
            
            mustSitNextTo.insert(guest);
            guest.mustSitNextTo.insert(self);
            guest.tableConstraint = tableConstraint;
            guest.groupConstraint = groupConstraint;
            return true;
        }
        return false;
    }
    
    
    /* Removes a guest from the "Must Sit Next To" array if present */
    @discardableResult
    func removeMustSitNextTo(_ guest: Guest) -> Bool {
        if (mustSitNextTo.contains(guest)) {
            mustSitNextTo.remove(guest);
            guest.mustSitNextTo.remove(self);
            //MAYBE???
            guest.tableConstraint = nil;
            guest.groupConstraint = nil;
            
            //Remove from other constraint for sorter function
            if (mustSitAtTable.contains(guest)) {
                removeMustSitAtTableOf(guest);
            }
            return true;
        }
        return false;
    }
    
    
    // MARK: Must Sit At Table Of Constraint
    
    /* Return an array version of the mustSitAtTable set */
    func getMustSitAtTableOf() -> [Guest] {
        return Array(mustSitAtTable);
    }
    
    
    /* Returns a string representation of the mustSitAtTable set */
    func getMustSitAtTableOfString() -> String {
        return returnStringFromSet(mustSitAtTable);
    }
    
    
    /* Adds a guest to the "Must Be At Table Of" array */
    @discardableResult
    func mustSitAtTableOf(_ guest: Guest) throws -> Bool {
        // Throw error if same guest or guest already included
        if (guest == self) {
            throw GuestError.sameGuestError;
        }else if (mustSitAtTable.contains(guest)) {
            throw GuestError.alreadyIncludedError;
        }
        
        // Create new must sit at table of constraint to be shared among guests
        var newMustSitAtTable = mustSitAtTable;
        for constraint in guest.mustSitAtTable {
            newMustSitAtTable.insert(constraint);
        }
        newMustSitAtTable.insert(guest);
        newMustSitAtTable.insert(self);
        
        // Create new cannot sit at table of constraint to be shared among guests
        var newCannotSitAtTable = cannotSitAtTable;
        for constraint in guest.cannotSitAtTable {
            newCannotSitAtTable.insert(constraint);
        }
        
        // Throw error if ending constraint size is too big
        if newMustSitAtTable.count > 20 {
            throw GuestError.constraintTooBigError;
        }
        
        // Iterate through each guest and change mustSitAtTable to new set while excluding self
        for guest in newMustSitAtTable {
            guest.changeMustSitAtTable(newMustSitAtTable);
            try guest.changeCannotSitAtTable(newCannotSitAtTable);
            guest.groupConstraint = self.groupConstraint;
            guest.tableConstraint = self.tableConstraint;
        }
        return true;
    }
    
    
    /* Helper function that adds all the guests in the given set to self's mustSitAtTable set unless the guest is self or it is already contained. */
    fileprivate func changeMustSitAtTable(_ newSet: Set<Guest>) {
        for guest in newSet {
            if (!mustSitAtTable.contains(guest) && guest != self) {
                mustSitAtTable.insert(guest);
            }
        }
    }
    
    
    /* Helper function that adds all the guests in the given set to self's cannotSitAtTable set unless the guest is self or it is already contained. */
    fileprivate func changeCannotSitAtTable(_ newSet: Set<Guest>) throws {
        for guest in newSet {
            if (!cannotSitAtTable.contains(guest) && guest != self) {
                cannotSitAtTable.insert(guest);
            }
        }
    }
    
    
    /* Removes a guest from the "Must Be At Table Of" array if present */
    @discardableResult
    func removeMustSitAtTableOf(_ guest: Guest) -> Bool {
        if (mustSitAtTable.contains(guest)) {
            mustSitAtTable.remove(guest);
            guest.mustSitAtTable.removeAll();
            //MAYBE???
            guest.tableConstraint = nil;
            guest.groupConstraint = nil;
            
            //Remove the guest from the other must sit at table of guests
            for g in mustSitAtTable {
                g.mustSitAtTable.remove(guest);
                if (g.mustSitNextTo.contains(guest)) {
                    g.mustSitNextTo.remove(guest);
                    guest.mustSitNextTo.remove(g);
                }
            }
            
            //Remove from other constraint if there
            if (mustSitNextTo.contains(guest)) {
                mustSitNextTo.remove(guest);
            }
            return true;
        }
        return false;
    }
    
    
    // MARK: Cannot Sit Next To Constraint
    
    /* Returns an array version of the cannotSitNextTo set */
    func getCannotSitNextTo() -> [Guest] {
        return Array(cannotSitNextTo);
    }
    
    
    /* Returns a string representation of the cannotSitNextTo set */
    func getCannotSitNextToString() -> String {
        return returnStringFromSet(cannotSitNextTo);
    }
    
    
    /* Adds a guest to the "Cannot Sit Next To" array */
    @discardableResult
    func cannotSitNextTo(_ guest: Guest) -> Bool {
        cannotSitNextTo.insert(guest);
        guest.cannotSitNextTo.insert(self);
        return true;
    }
    
    
    /* Removes a guest from the "Cannot Sit Next To" array if present */
    @discardableResult
    func removeCannotSitNextTo(_ guest: Guest) -> Bool {
        if (cannotSitNextTo.contains(guest)) {
            cannotSitNextTo.remove(guest);
            guest.cannotSitNextTo.remove(self);
            return true;
        }
       return false;
    }
    
    
    // MARK: Cannot Sit At Table Of Constraint
    
    /* Returns an array version the cannotSitAtTable set */
    func getCannotSitAtTableOf() -> [Guest] {
        return Array(cannotSitAtTable);
    }
    
    
    /* Returns a string representation of the cannotSitAtTable set */
    func getCannotSitAtTableOfString() -> String {
        return returnStringFromSet(cannotSitAtTable);
    }
    
    
    /* Adds a guest to the "Cannot Be At Table Of" array */
    @discardableResult
    func cannotSitAtTableOf(_ guest: Guest) -> Bool {
        cannotSitAtTable.insert(guest);
        guest.cannotSitAtTable.insert(self);
        return true;
    }
    
    
    /* Removes a guest from the "Cannot Be At Table Of" array if present */
    @discardableResult
    func removeCannotSitAtTableOf(_ guest: Guest) -> Bool {
        if (cannotSitAtTable.contains(guest)) {
            cannotSitAtTable.remove(guest);
            guest.cannotSitAtTable.remove(self);
            return true;
        }
        return false;
    }
    
    // MARK: Helper Functions
    
    /* Helper function that returns a string of all guests in the given set */
    fileprivate func returnStringFromSet(_ set: Set<Guest>) -> String {
        var str: String = "";
        for guest in set {
            str += guest.getFullName(.FirstName) + ", ";
        }
        return String(str.characters.dropLast(2));
    }
    
    /* Function that determines the order of seating for must sit next to guests and their respective must sit next to guests. Returns each array list of guests in another array. */
    func getNeighborChains() -> [[Guest]] {
        var arrayOfOrders = [[Guest]]();
        
        //Iterate through given guest's neighbors and make an order for each
        for neighbor in mustSitNextTo {
            var guestOrder = [Guest]();
            var lastGuest: Guest = self;
            var currentGuest: Guest? = neighbor;
            //Iterate through each neighbors chain of must-sit-next-to guests
            while (currentGuest != nil) {
                guestOrder.append(currentGuest!);
                let currentGuestNeighbors = currentGuest!.mustSitNextTo;
                let placeHolderGuest = currentGuest!;
                currentGuest = nil;
                for currentNeighbor in currentGuestNeighbors {
                    if (currentNeighbor != lastGuest) {
                        currentGuest = currentNeighbor;
                    }
                }
                lastGuest = placeHolderGuest;
            }
            arrayOfOrders.append(guestOrder);
        }
        return arrayOfOrders;
    }
    
    
    
    //MARK: Sorting Static Methods
    
    static func sortByFirstName(_ first: Guest, second: Guest) -> Bool {
        if (first.firstName == second.firstName) {
            return first.lastName < second.lastName;
        }
        return first.firstName < second.firstName;
    }
    
    
    static func sortByLastName(_ first: Guest, second: Guest) -> Bool {
        if (first.lastName == second.lastName) {
            return first.firstName < second.firstName;
        }
        return first.lastName < second.lastName;
    }
    
    
    static func sortByUnseatedFirstName(_ first: Guest, second: Guest) -> Bool {
        if (first.isSeated() == second.isSeated()) {
            if (first.firstName == second.firstName) {
                return first.lastName < second.lastName;
            }
            return first.firstName < second.firstName;
        }
        return !first.isSeated();
    }
    
    
    static func sortByUnseatedLastName(_ first: Guest, second: Guest) -> Bool {
        if (first.isSeated() == second.isSeated()) {
            if (first.lastName == second.lastName) {
                return first.firstName < second.firstName;
            }
            return first.lastName < second.lastName;
        }
        return !first.isSeated();
    }
    
    
    
    //MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(firstName, forKey: "firstName");
        aCoder.encode(lastName, forKey: "lastName");
        aCoder.encode(seat, forKey: "seat");
        aCoder.encode(table, forKey: "table");
        aCoder.encode(mustSitNextTo, forKey: "mustSitNextTo");
        aCoder.encode(mustSitAtTable, forKey: "mustSitAtTable");
        aCoder.encode(cannotSitNextTo, forKey: "cannotSitNextTo");
        aCoder.encode(cannotSitAtTable, forKey: "cannotSitAtTable");
        aCoder.encode(groupConstraint, forKey: "groupConstraint");
        aCoder.encode(tableConstraint, forKey: "tableConstraint");
    }
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        let firstName = aDecoder.decodeObject(forKey: "firstName") as! String;
        let lastName = aDecoder.decodeObject(forKey: "lastName") as! String;
        let seat = aDecoder.decodeObject(forKey: "seat") as? Seat;
        let table = aDecoder.decodeObject(forKey: "table") as? Table;
        let mustSitNextTo = aDecoder.decodeObject(forKey: "mustSitNextTo") as! Set<Guest>;
        let mustSitAtTable = aDecoder.decodeObject(forKey: "mustSitAtTable") as! Set<Guest>;
        let cannotSitNextTo = aDecoder.decodeObject(forKey: "cannotSitNextTo") as! Set<Guest>;
        let cannotSitAtTable = aDecoder.decodeObject(forKey: "cannotSitAtTable") as! Set<Guest>;
        let groupConstraint = aDecoder.decodeObject(forKey: "groupConstraint") as? String;
        let tableConstraint = aDecoder.decodeObject(forKey: "tableConstraint") as? Table;
        self.init(firstName: firstName, lastName: lastName, table: table, seat: seat, msnt: mustSitNextTo, msat: mustSitAtTable, csnt: cannotSitNextTo, csat: cannotSitAtTable, groupC: groupConstraint, tableC: tableConstraint);
    }
}
