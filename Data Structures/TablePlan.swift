//
//  TablePlan.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/20/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import Foundation

class TablePlan : NSObject, NSCoding {
    
    //MARK: Properties
    
    var name: String;
    var date: String;
    var guestList = Array<Guest>();
    var tableList = Array<Table>();
    var tableGroupList = Array<String>();
    var sort = GuestSort.FirstName;
    var unseated = 0;
    var lastNameCount: NSMutableDictionary;
    var firstNameCount: NSMutableDictionary;
    var alphabetArray: [String] = ["#","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    var floorPlanNotOpened: Bool;
    
    
    
    //MARK: - Initialization
    
    init(name: String, date: String) {
        self.name = name;
        self.date = date;
        firstNameCount = ["#" : 0, "A" : 0,"B" : 0,"C" : 0,"D" : 0,"E" : 0,"F" : 0,"G" : 0,"H" : 0,"I" : 0,"J" : 0,"K" : 0,"L" : 0,"M" : 0,"N" : 0,"O" : 0,"P" : 0,"Q" : 0,"R" : 0,"S" : 0,"T" : 0,"U" : 0,"V" : 0,"W" : 0,"X" : 0,"Y" : 0,"Z" : 0];
        lastNameCount = ["#" : 0, "A" : 0,"B" : 0,"C" : 0,"D" : 0,"E" : 0,"F" : 0,"G" : 0,"H" : 0,"I" : 0,"J" : 0,"K" : 0,"L" : 0,"M" : 0,"N" : 0,"O" : 0,"P" : 0,"Q" : 0,"R" : 0,"S" : 0,"T" : 0,"U" : 0,"V" : 0,"W" : 0,"X" : 0,"Y" : 0,"Z" : 0];
        floorPlanNotOpened = true;
    }
    
    
    init(name: String, date: String, guestList: [Guest], tableList: [Table], tableGroupList: [String], sort: GuestSort, unseated: Int, firstNameCount: NSMutableDictionary, lastNameCount: NSMutableDictionary, floorPlanNotOpened: Bool) {
        self.name = name;
        self.date = date;
        self.guestList = guestList;
        self.tableList = tableList;
        self.tableGroupList = tableGroupList;
        self.sort = sort;
        self.unseated = unseated;
        self.firstNameCount = firstNameCount;
        self.lastNameCount = lastNameCount;
        self.floorPlanNotOpened = floorPlanNotOpened;
    }
    
    
    
    //MARK: - Enums
    
    enum GuestSort : String {
        case FirstName = "First Name";
        case LastName = "Last Name";
        case UnseatedFirstName = "Unseated (First Name)";
        case UnseatedLastName = "Unseated (Last Name)";
    }
    
    
    
    //MARK: - Guest Functions
    
    func editGuest(_ guest: Guest, firstName: String, lastName: String, table: Table?, seat: Seat?) {
        if (guest.firstName != firstName) {
            removeFromFirstnameCount(guest.firstName);
            addToFirstnameCount(firstName);
        }
        if (guest.lastName != lastName) {
            removeFromLastnameCount(guest.lastName);
            addToLastnameCount(lastName);
        }
        
        guest.firstName = firstName;
        guest.lastName = lastName;
        guest.table = table;
        guest.seat?.seatGuest(nil);
        seat?.seatGuest(guest);
    }
    
    
    func addGuest(_ guest: Guest) {
        addToFirstnameCount(guest.firstName);
        addToLastnameCount(guest.lastName);
        guestList.append(guest);
        unseated += 1;
    }
    
    
    /* Removes the guest at the given index and resets the guest's seat GUESTSEATED pointer if guest is seated. Also updates the UNSEATED count. */
    func removeGuest(_ guestIndex: Int) {
        let removedGuest = guestList.remove(at: guestIndex);
        if !removedGuest.isSeated() {
            unseated -= 1;
        }
        removedGuest.seat?.guestSeated = nil;
        removeFromFirstnameCount(removedGuest.firstName);
        removeFromLastnameCount(removedGuest.lastName);
        
        // Clear constraints of associated guests
        for guest in removedGuest.mustSitNextTo {
            guest.removeMustSitNextTo(removedGuest);
        }
        for guest in removedGuest.cannotSitNextTo {
            guest.removeCannotSitNextTo(removedGuest);
        }
        (removedGuest.mustSitAtTable.first as Guest?)?.removeMustSitAtTableOf(removedGuest);
        (removedGuest.cannotSitAtTable.first as Guest?)?.removeCannotSitAtTableOf(removedGuest);
    }
    
    
    /* Helper function that adds an index count for first name */
    fileprivate func addToFirstnameCount(_ firstName: String) {
        // Change first name start index based off first letter of first name
        let first = String(firstName[firstName.startIndex]).uppercased();
        if let count = firstNameCount[first] {
            firstNameCount[first] = (count as! Int) + 1;
        }else {
            firstNameCount["#"] = (firstNameCount["#"] as! Int) + 1;
        }
    }
    
    
    /* Helper function that adds an index count for last name */
    fileprivate func addToLastnameCount(_ lastName: String) {
        // Change last name start index based off first letter of last name
        let last = String(lastName[lastName.startIndex]).uppercased();
        if let count = lastNameCount[last] {
            lastNameCount[last] = (count as! Int) + 1;
        }else {
            lastNameCount["#"] = (lastNameCount["#"] as! Int) + 1;
        }
    }
    
    
    /* Helper function that removes an index count for first name */
    fileprivate func removeFromFirstnameCount(_ firstName: String) {
        // Change first name start index based off first letter of first name
        let first = String(firstName[firstName.startIndex]).uppercased();
        if let count = firstNameCount[first] {
            firstNameCount[first] = (count as! Int) - 1;
        }else {
            firstNameCount["#"] = (firstNameCount["#"] as! Int) - 1;
        }
    }
    
    
    /* Helper function that removes an index count for last name */
    fileprivate func removeFromLastnameCount(_ lastName: String) {
        // Change last name start index based off first letter of last name
        let last = String(lastName[lastName.startIndex]).uppercased();
        if let count = lastNameCount[last] {
            lastNameCount[last] = (count as! Int) - 1;
        }else {
            lastNameCount["#"] = (lastNameCount["#"] as! Int) - 1;
        }
    }
    
    
    /* Returns value of key at the given index from the firstNameCount dictionary */
    func getFirstnameCount(index: Int) -> Int {
        let key = alphabetArray[index];
        return (firstNameCount[key] as! Int);
    }
    
    
    /* Returns value of key at the given index from the lastNameCount dictionary */
    func getLastnameCount(index: Int) -> Int {
        let key = alphabetArray[index];
        return (lastNameCount[key] as! Int);
    }
    
    
    /* Return guest of the guestList given a section and row from an indexPath and the current sort */
    func getGuestAtIndex(_ section: Int, _ row: Int) -> Guest {
        let index = getIndex(section, row);
        return guestList[index];
    }
    
    /* Return index of the guestList given a section and row from an indexPath and the current sort */
    func getIndex(_ section: Int, _ row: Int) -> Int {
        let index: Int;
        if (sort == .FirstName) {
            index = getFirstnameGuestIndex(section, row: row);
        }else if (sort == .LastName) {
            index = getLastnameGuestIndex(section, row: row);
        }else {
            if (section == 0) {
                index = row;
            }else {
                index = row + unseated;
            }
        }
        return index;
    }
    
    
    /* Return index of the guestList given a section and row from an indexPath following the firstNameCount dictionary */
    fileprivate func getFirstnameGuestIndex(_ section: Int, row: Int) -> Int {
        var index = 0;
        for i in 0..<section {
            let key = alphabetArray[i];
            index = (firstNameCount[key] as! Int) + index;
        }
        return index + row;
    }
    
    
    /* Return index of the guestList given a section and row from an indexPath following the lastNameCount dictionary */
    fileprivate func getLastnameGuestIndex(_ section: Int, row: Int) -> Int {
        var index = 0;
        for i in 0..<section {
            let key = alphabetArray[i];
            index = (lastNameCount[key] as! Int) + index;
        }
        return index + row;
    }
    
    
    //MARK: Table Functions
    
    /* Adds a table to the table list */
    func addTable(_ table: Table) {
        tableList.append(table);
    }
    
    
    /* Removes the table at the given index and resets the table and seat pointers for guests seated at the table's seats */
    func removeTable(_ tableIndex: Int) {
        let removedTable = tableList.remove(at: tableIndex);
        for seat in removedTable.seats {
            let guest = seat.guestSeated;
            if (guest != nil) {
                unseated += 1;
                guest!.table = nil;
                guest!.seat = nil;
            }
        }
        for guest in guestList {
            if guest.tableConstraint == removedTable {
                guest.removeTableConstraint();
            }
        }
    }
    
    
    
    //MARK: Plan Functions
    
    /* Clears all arrays and resets variables of the tablePlan to the default */
    func resetPlan() {
        guestList.removeAll();
        tableList.removeAll();
        tableGroupList.removeAll();
        sort = GuestSort.FirstName;
        unseated = 0;
    }
    
    
    /* Clears all seats in the plan */
    func clearSeats() {
        for guest in guestList {
            guest.seat?.seatGuest(nil);
            guest.table = nil;
        }
    }
    
    /* Clears all constraints among all guests in this plan. */
    func clearConstraints() {
        for guest in guestList {
            guest.mustSitAtTable.removeAll();
            guest.mustSitNextTo.removeAll();
            guest.cannotSitAtTable.removeAll();
            guest.cannotSitNextTo.removeAll();
            guest.tableConstraint = nil;
            guest.groupConstraint = nil;
        }
    }
    
    /* Reloads certain data counts incase those numbers were messed up from a bug. */
    func reloadData() {
        // Clear data to be reloaded
        unseated = 0;
        firstNameCount = ["#" : 0, "A" : 0,"B" : 0,"C" : 0,"D" : 0,"E" : 0,"F" : 0,"G" : 0,"H" : 0,"I" : 0,"J" : 0,"K" : 0,"L" : 0,"M" : 0,"N" : 0,"O" : 0,"P" : 0,"Q" : 0,"R" : 0,"S" : 0,"T" : 0,"U" : 0,"V" : 0,"W" : 0,"X" : 0,"Y" : 0,"Z" : 0];
        lastNameCount = ["#" : 0, "A" : 0,"B" : 0,"C" : 0,"D" : 0,"E" : 0,"F" : 0,"G" : 0,"H" : 0,"I" : 0,"J" : 0,"K" : 0,"L" : 0,"M" : 0,"N" : 0,"O" : 0,"P" : 0,"Q" : 0,"R" : 0,"S" : 0,"T" : 0,"U" : 0,"V" : 0,"W" : 0,"X" : 0,"Y" : 0,"Z" : 0];
        
        // Update unseated count
        for guest in guestList {
            if !guest.isSeated() {
                unseated += 1;
            }
            
            // Update firstname and lastname counts
            addToFirstnameCount(guest.firstName);
            addToLastnameCount(guest.lastName);
        }
        
    }
    
    
    //MARK: Sort Functions
    
    /* Sorts the guestList based off of the given sort enumeration */
    func sortGuests() {
        if (sort == .FirstName) {
            sortByFirstName();
        }else if (sort == .LastName) {
            sortByLastName();
        }else if (sort == .UnseatedFirstName) {
            sortByUnseatedFirstName();
        }else {
            sortByUnseatedLastName();
        }
    }
    
    
    /* Helper func that sorts guests by first name */
    fileprivate func sortByFirstName() {
        guestList.sort(by: Guest.sortByFirstName);
    }
    
    
    /* Helper func that sorts guests by last name */
    fileprivate func sortByLastName() {
        guestList.sort(by: Guest.sortByLastName);
    }
    
    
    /* Helper func that sorts guests by first name, then their seat status */
    fileprivate func sortByUnseatedFirstName() {
        guestList.sort(by: Guest.sortByUnseatedFirstName);
    }
    
    
    /* Helper func that sorts guests by last name, then their seat status */
    fileprivate func sortByUnseatedLastName() {
        guestList.sort(by: Guest.sortByUnseatedLastName);
    }
    
    
    
    //MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name");
        aCoder.encode(date, forKey: "date");
        aCoder.encode(guestList, forKey: "guestList");
        aCoder.encode(tableList, forKey: "tableList");
        aCoder.encode(tableGroupList, forKey: "tableGroupList");
        aCoder.encode(sort.rawValue, forKey: "sort");
        aCoder.encode(unseated, forKey: "unseated");
        aCoder.encode(firstNameCount, forKey: "firstNameCount");
        aCoder.encode(lastNameCount, forKey: "lastNameCount");
        aCoder.encode(floorPlanNotOpened, forKey: "floorPlanNotOpened");
    }
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String;
        let date = aDecoder.decodeObject(forKey: "date") as! String;
        let guestList = aDecoder.decodeObject(forKey: "guestList") as! [Guest];
        let tableList = aDecoder.decodeObject(forKey: "tableList") as! [Table];
        let tableGroupList = aDecoder.decodeObject(forKey: "tableGroupList") as! [String];
        let sort = GuestSort(rawValue: aDecoder.decodeObject(forKey: "sort") as! String) ?? .FirstName;
        let unseated = aDecoder.decodeInteger(forKey: "unseated");
        let firstNameCount = aDecoder.decodeObject(forKey: "firstNameCount") as! NSMutableDictionary;
        let lastNameCount = aDecoder.decodeObject(forKey: "lastNameCount") as! NSMutableDictionary;
        let floorPlanNotOpened = aDecoder.decodeBool(forKey: "floorPlanNotOpened");
        self.init(name: name, date: date, guestList: guestList, tableList: tableList, tableGroupList: tableGroupList, sort: sort, unseated: unseated, firstNameCount: firstNameCount, lastNameCount: lastNameCount, floorPlanNotOpened: floorPlanNotOpened);
    }
}
