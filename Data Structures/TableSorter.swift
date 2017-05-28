//
//  TableSorter.swift
//  Table Planner
//
//  Created by Alex Erviti on 7/28/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import Foundation
import GameplayKit
import FirebaseAnalytics

class TableSorter {
    
    // MARK: - Properties
    
    weak var tablePlan: TablePlan?;
    var unseatedGuests: [Guest];
    var extraGuests: [Guest];
    
    
    // MARK: - Initialization
    
    init(tablePlan: TablePlan) {
        // Set up tablePlan and list of unseated guests
        self.tablePlan = tablePlan;
        self.unseatedGuests = tablePlan.guestList.filter { guest in
            return !guest.isSeated();
        }
        self.extraGuests = [Guest]();
    }
    
    
    
    // MARK: - Methods
    
    /* Function that unseats all guests on the unseated list; used for undoing a sort. */
    func undoSort() {
        for guest in unseatedGuests {
            guest.seat?.seatGuest(nil);
            guest.table = nil;
            guest.seatedRandomly = false;
            guest.tabledRandomly = false;
            extraGuests.removeAll();
        }
    }
    
    
    /* Function that returns a list of guests that have conflicting restraints. Returns nil if there are no guests with conflicting constraints. */
    func checkAllGuestConstraints() -> [Guest]? {
        var conflictedGuests = [Guest]();
        for guest in unseatedGuests {
            if !checkConstraint(guest) {
                conflictedGuests.append(guest);
            }
        }
        
        if conflictedGuests.isEmpty {
            return nil;
        }
        return conflictedGuests;
    }
    
    
    /* Function that checks if any of the given guest's constraints conflict. Returns true if no constraints conflict, and false if any do. */
    func checkConstraint(_ guest: Guest) -> Bool {
        var tablePlaceholder: Table? = nil;
        var guestPlaceholder: Guest? = nil;
        for g in guest.mustSitNextTo {
            // Check if there are conflicts between must-sit-next-to guests and guests that cannot be at the current guests table
            if (guest.cannotSitNextTo.contains(g) || guest.cannotSitAtTable.contains(g)) {
                return false;
            }
            // Check that these guests are not at different tables
            if (g.table != nil) {
                if (tablePlaceholder == nil) {
                    tablePlaceholder = g.table;
                    guestPlaceholder = g;
                }else {
                    if (g.table! != tablePlaceholder!) {
                        return false;
                    // If tables are the same and there isn't one empty seat between them, error
                    }else {
                        if (g.seat?.seatToLeft?.seatToLeft != guestPlaceholder!.seat && g.seat?.seatToRight?.seatToRight != guestPlaceholder!.seat) {
                            return false;
                        }
                    }
                }
                // Check that must-sit-next-to guest's table does not conflict with current guests table constraint
                if (guest.tableConstraint != nil && g.table! != guest.tableConstraint!) {
                    return false;
                }
            }
        }
        
        tablePlaceholder = nil;
        for g in guest.mustSitAtTable {
            // Check if there are conflicts between must-sit-at-table-of guests and guests that cannot be at the current guests table
            if (guest.cannotSitAtTable.contains(g)) {
                return false;
            }
            // Check that these guests are not at different tables
            if (g.table != nil) {
                if (tablePlaceholder == nil) {
                    tablePlaceholder = g.table;
                }else {
                    if (g.table! != tablePlaceholder!) {
                        return false;
                    }
                }
                // Check that must-sit-at-table-of guest's table does not conflict with current guests table constraint
                if (guest.tableConstraint != nil && g.table! != guest.tableConstraint!) {
                    return false;
                }
            }
        }
        
        // Check that cannot-sit guest's table does not conflict with current guest's table constraint
        for g in guest.cannotSitNextTo {
            if (guest.tableConstraint != nil && g.table != nil && g.table! != guest.tableConstraint!) {
                return false;
            }
        }
        for g in guest.cannotSitAtTable {
            if (guest.tableConstraint != nil && g.table != nil && g.table! != guest.tableConstraint!) {
                return false;
            }
        }
        
        // Check if the table constraint and group constraint conflict
        if (guest.tableConstraint != nil && guest.groupConstraint != nil && guest.tableConstraint!.tableGroup != guest.groupConstraint) {
            return false;
        }
        return true;
    }
    
    
    /* Seats all unseated guests based off their constraints. Repeats sort up to REPITITIONS number of times until a successful sort occurs. If one does not, returns false. */
    func sortAllGuests(_ repititions: Int) -> Bool {
        for _ in 0..<repititions {
            if sortAllGuests() {
                return true;
            }
        }
        return false;
    }
    
    
    /* Seats all unseated guests based off its constraints. Returns true if all unseated guests were successfully seated. If a conflict is encountered, unseats all previously seated guests and returns false. */
    func sortAllGuests() -> Bool {
        // Unseated guests
        let guestIndexGenerator = NumberGenerator(maxRange: unseatedGuests.count);
        var guestIndex: Int? = guestIndexGenerator.generateNumber();
        while (guestIndex != nil) {
            let guest = unseatedGuests[guestIndex!];
            let guestSuccessful = sortGuest(guest);
            let neighborSuccessful = seatMustSitAtTableOfGuests(guest);
            if !guestSuccessful || !neighborSuccessful {
                undoSort();
                return false;
            }
            guestIndex = guestIndexGenerator.generateNumber();
        }
        
        // Guests removed from previous seatings
        while !extraGuests.isEmpty {
            let guest = extraGuests.removeFirst();
            let successful = sortGuest(guest);
            if !successful {
                undoSort();
                return false;
            }
        }
        return true;
    }
    
    
    /* Helper function that sorts all of the given guests' must-sit-at-table-of guests and marks them as already seated. */
    fileprivate func seatMustSitAtTableOfGuests(_ guest: Guest) -> Bool {
        if !guest.mustSitAtTable.isEmpty {
            guest.seatedRandomly = false;
            guest.tabledRandomly = false;
        }
        for guestConstraint in guest.mustSitAtTable where !guestConstraint.isSeated() {
            if !sortGuest(guestConstraint) {
                return false;
            }
        }
        return true;
    }
    
    
    /* Unseats guests and resorts them up to REPITITIONS number of times. */
    func resortAllGuests(_ repititions: Int) -> Bool {
        undoSort();
        return sortAllGuests(repititions);
    }
    
    
    /* Unseats guests and resorts them. */
    func resortAllGuests() -> Bool {
        undoSort();
        return sortAllGuests();
    }
    
    
    /* Seats the given guest based off its constraints. Returns true if successfully seated, false if not.*/
    func sortGuest(_ guest: Guest) -> Bool {
        // Skip guest if already seated from a must-sit-next-to guest
        if guest.isSeated() {
            return true;
        }
        
        var table: Table? = nil;
        guard let tablePlan = self.tablePlan else {
            print("No assigned tablePlan from Table Sorter (sortGuest)");
            FIRAnalytics.logEvent(withName: "Caught_Error", parameters: [
                "name": "sortGuest" as NSObject,
                "full_text": "No assigned tablePlan from TableSorter." as NSObject
                ]);
            return false;
        }
        var tableList = tablePlan.tableList;
        let hasNeighbors = (guest.mustSitNextTo.count > 0);
        
        // If any neighbors in the neighbor chain are seated, seat guests from that seated guest
        if hasNeighbors {
            for chain in guest.getNeighborChains() {
                for neighbor in chain {
                    if neighbor.isSeated() {
                        return seatGuestWithSeatedNeighbors(neighbor);
                    }
                }
            }
        }
        
        // If there is a table constraint, use it
        if (guest.tableConstraint != nil) {
            table = guest.tableConstraint!;
            if hasNeighbors {
                return seatGuestWithNeighbors(guest, table: table!);
            }
            return seatGuestWithTable(guest, table: table!);
        }
        
        // If a must-sit-at-table guest has a table, use it
        for g in guest.mustSitAtTable {
            if (g.table != nil) {
                table = g.table!;
                if hasNeighbors {
                    return seatGuestWithNeighbors(guest, table: table!);
                }
                return seatGuestWithTable(guest, table: table!);
            }
        }
        
        // Create a restricted table list based off of guests that cannot be sat with, to utilize in the seating of the guest
        var restrictedTables: Set<Table> = Set<Table>();
        for g in guest.cannotSitAtTable {
            if (g.table != nil) {
                restrictedTables.insert(g.table!);
            }
        }
        
        // If a group constraint is set, filter tableList and seat
        if (guest.groupConstraint != nil) {
            tableList = tableList.filter { table in
                return table.tableGroup == guest.groupConstraint;
            }
            if hasNeighbors {
                return seatGuestWithNeighbors(guest, tableList: tableList, restrictedTables: restrictedTables);
            }
            return seatGuestWithTableList(guest, tableList: tableList, restrictedTables: restrictedTables);
        }
        
        // Seat at a random table if no constraints set
        if hasNeighbors {
            return seatGuestWithNeighbors(guest, restrictedTables: restrictedTables);
        }
        return seatGuestAtRandom(guest, tableList: tableList, restrictedTables: restrictedTables);
    }
    
    
    /* Helper function that seats the neighbors of the given guest, taking into account any already seated neighbors. */
    fileprivate func seatGuestWithSeatedNeighbors(_ guest: Guest) -> Bool {
        var guestsSeated = [Guest]();
        var emptySeatSides: Set<String> = ["left", "right"];
        
        // Iterate through the given seated guests neighbor chains and attempt to seat them
        let neighborChains = guest.getNeighborChains();
        for chain in neighborChains {
            // Attempt to seat chain on the left of the given guest's seat if emtpy
            if emptySeatSides.contains("left") {
                emptySeatSides.remove("left");
                var leftSeat = guest.seat!.seatToLeft;
                for neighbor in chain {
                    // If neighbor not seated but the the seat is occupied with someone replaceable, replace
                    if leftSeat != nil && !neighbor.isSeated() && leftSeat!.hasGuest() && leftSeat!.guestSeated!.seatedRandomly && neighborCheck(neighbor, leftSeat!) {
                        guestsSeated.append(neighbor);
                        extraGuests.append(leftSeat!.guestSeated!);
                        leftSeat!.seatGuest(neighbor);
                    // If neighbor not seated and seat is empty, seat neighbor
                    }else if leftSeat != nil && !neighbor.isSeated() && neighborCheck(neighbor, leftSeat!) {
                        guestsSeated.append(neighbor);
                        leftSeat!.seatGuest(neighbor);
                    // If neighbor is seated but seat in question is not neighbor's seat or there is no seat or neighborcheck doesn't pass, cancel
                    }else if leftSeat == nil || (leftSeat != nil && neighbor.seat! != leftSeat) || !neighborCheck(neighbor, leftSeat!) {
                        unseatListOfLists([guestsSeated]);
                        guestsSeated.removeAll();
                        emptySeatSides.insert("left");
                        break;
                    }
                    leftSeat = leftSeat?.seatToLeft;
                }
                // If successful, don't let chain be attempted to be seated on right
                if !emptySeatSides.contains("left") { break; }
            }
            
            // Attempt to seat chain on the right of the given guest's seat if empty
            if emptySeatSides.contains("right") {
                emptySeatSides.remove("right");
                var rightSeat = guest.seat!.seatToRight;
                for neighbor in chain {
                    // If neighbor not seated but the the seat is occupied with someone replaceable, replace
                    if rightSeat != nil && !neighbor.isSeated() && rightSeat!.hasGuest() && rightSeat!.guestSeated!.seatedRandomly && neighborCheck(neighbor, rightSeat!) {
                        guestsSeated.append(neighbor);
                        extraGuests.append(rightSeat!.guestSeated!);
                        rightSeat!.seatGuest(neighbor);
                    // If neighbor not seated and seat is empty, seat neighbor
                    }else if rightSeat != nil && !neighbor.isSeated() && neighborCheck(neighbor, rightSeat!) {
                        guestsSeated.append(neighbor);
                        rightSeat!.seatGuest(neighbor);
                    // If neighbor is seated but seat in question is not neighbor's seat or there is no seat or neighborcheck doesn't pass, cancel
                    }else if rightSeat == nil || (rightSeat != nil && neighbor.seat! != rightSeat) || !neighborCheck(neighbor, rightSeat!) {
                        unseatListOfLists([guestsSeated]);
                        guestsSeated.removeAll();
                        emptySeatSides.insert("right");
                        break;
                    }
                    rightSeat = rightSeat?.seatToRight;
                }
            }
        }
        
        // If there are as many filled sides of the seat as there are neighbor chains, return true
        if (neighborChains.count == 2 && emptySeatSides.count == 0) || (neighborChains.count == 1 && emptySeatSides.count == 1) {
            return true;
        }
        return false;
    }
    
    
    /* Helper function that seats a guest and its must-sit-next-to guests at the given table assuming they don't already have a table. */
    fileprivate func seatGuestWithNeighbors(_ guest: Guest, table: Table) -> Bool {
        // Randomly pick a seat and seat if empty
        //tableOptomizer(table);
        let indexGenerator = NumberGenerator(maxRange: table.numOfSeats);
        var index: Int? = indexGenerator.generateOrderedNumber();
        while (index != nil) {
            let seat = table.seats[index!];
            if !seat.hasGuest() && neighborCheck(guest, seat) && seatGuestAndNeighbors(guest, seat: seat) {
                return true;
            }
            index = indexGenerator.generateOrderedNumber();
        }
        
        // If all seats are taken, check if any guests are seatedRandomly and replace them
        indexGenerator.reset();
        index = indexGenerator.generateOrderedNumber();
        while (index != nil) {
            let seat = table.seats[index!];
            if seat.hasGuest() && neighborCheck(guest, seat) && seat.guestSeated!.seatedRandomly && seatGuestAndNeighbors(guest, seat: seat)  {
                return true;
            }
            index = indexGenerator.generateOrderedNumber();
        }
        
        // Return false for failed seating attempt
        return false;
    }
    
    
    /* Helper function that seats a guest and its must-sit-next-to guests at a table in the given table list assuming they don't already have a table. */
    fileprivate func seatGuestWithNeighbors(_ guest: Guest, tableList: [Table], restrictedTables: Set<Table>) -> Bool {
        // Randomly pick a table within list and assess if not restricted
        let tableIndexGenerator = NumberGenerator(maxRange: tableList.count);
        var tableIndex: Int? = tableIndexGenerator.generateNumber();
        while (tableIndex != nil) {
            let table = tableList[tableIndex!];
            if (!restrictedTables.contains(table)) {
                
                // Randomly pick a seat and seat if empty
                //tableOptomizer(table);
                let seatIndexGenerator = NumberGenerator(maxRange: table.numOfSeats);
                var seatIndex: Int? = seatIndexGenerator.generateOrderedNumber();
                while (seatIndex != nil) {
                    let seat = table.seats[seatIndex!];
                    if !seat.hasGuest() && neighborCheck(guest, seat) && seatGuestAndNeighbors(guest, seat: seat) {
                        return true;
                    }
                    seatIndex = seatIndexGenerator.generateOrderedNumber();
                }
            }
            tableIndex = tableIndexGenerator.generateNumber();
        }
        
        // If all seats in the tables are taken, check to see if any of the guests are tabledRandomly and replace them
        tableIndexGenerator.reset();
        tableIndex = tableIndexGenerator.generateNumber();
        while (tableIndex != nil) {
            let table = tableList[tableIndex!];
            if (!restrictedTables.contains(table)) {
                
                // Randomly pick a seat and seat if guest is randomlyTabled
                let seatIndexGenerator = NumberGenerator(maxRange: table.numOfSeats);
                var seatIndex: Int? = seatIndexGenerator.generateOrderedNumber();
                while (seatIndex != nil) {
                    let seat = table.seats[seatIndex!];
                    if seat.hasGuest() && neighborCheck(guest, seat) && seat.guestSeated!.tabledRandomly && seatGuestAndNeighbors(guest, seat: seat) {
                        return true;
                    }
                    seatIndex = seatIndexGenerator.generateOrderedNumber();
                }
            }
            tableIndex = tableIndexGenerator.generateNumber();
        }
        
        // Return false for failed seating attempt
        return false;
    }
    
    
    /* Helper function that seats a guest and its must-sit-next-to guests at any potential table assuming they don't already have a table. */
    fileprivate func seatGuestWithNeighbors(_ guest: Guest, restrictedTables: Set<Table>) -> Bool {
        // Randomly pick a table within list and assess if not restricted
        guard let tablePlan = self.tablePlan else {
            print("No assigned tablePlan from TableSorter (seatGuestWithNeighbors)");
            FIRAnalytics.logEvent(withName: "Caught_Error", parameters: [
                "name": "seatGuestWithNeighbors" as NSObject,
                "full_text": "No assigned tablePlan from TableSorter." as NSObject
                ]);
            return false;
        }
        let tableList = tablePlan.tableList;
        let tableIndexGenerator = NumberGenerator(maxRange: tableList.count);
        var tableIndex: Int? = tableIndexGenerator.generateNumber();
        while (tableIndex != nil) {
            let table = tableList[tableIndex!];
            if (!restrictedTables.contains(table)) {
                
                // Randomly pick a seat and seat if empty
                let seatIndexGenerator = NumberGenerator(maxRange: table.numOfSeats);
                var seatIndex: Int? = seatIndexGenerator.generateOrderedNumber();
                while (seatIndex != nil) {
                    let seat = table.seats[seatIndex!];
                    if !seat.hasGuest() && neighborCheck(guest, seat) && seatGuestAndNeighbors(guest, seat: seat) {
                        return true;
                    }
                    seatIndex = seatIndexGenerator.generateOrderedNumber();
                }
            }
            tableIndex = tableIndexGenerator.generateNumber();
        }
        
        // Return false for failed seating attempt
        return false;
    }
    
    
    /* Helper function that seats the given guest at the given table in a random seat. */
    fileprivate func seatGuestWithTable(_ guest: Guest, table: Table) -> Bool {
        // Randomly pick a seat and seat if empty
        let indexGenerator = NumberGenerator(maxRange: table.numOfSeats);
        var index: Int? = indexGenerator.generateOrderedNumber();
        while (index != nil) {
            let seat = table.seats[index!];
            if !seat.hasGuest() && neighborCheck(guest, seat) {
                seat.seatGuest(guest);
                guest.seatedRandomly = false;
                guest.tabledRandomly = false;
                return true;
            }
            index = indexGenerator.generateOrderedNumber();
        }
        
        // If all seats are taken, check if any guests are seatedRandomly and replace them
        indexGenerator.reset();
        index = indexGenerator.generateOrderedNumber();
        while (index != nil) {
            let seat = table.seats[index!];
            if seat.hasGuest() && neighborCheck(guest, seat) && seat.guestSeated!.seatedRandomly  {
                extraGuests.append(seat.guestSeated!);
                seat.seatGuest(guest);
                guest.seatedRandomly = false;
                guest.tabledRandomly = false;
                return true;
            }
            index = indexGenerator.generateOrderedNumber();
        }
        
        // Return false for failed seating attempt
        return false;
    }
    
    
    /* Helper function that seats the given guest at a random table from the given tableList and in a random seat at that table. */
    fileprivate func seatGuestWithTableList(_ guest: Guest, tableList: [Table], restrictedTables: Set<Table>) -> Bool {
        // Randomly pick a table within list and assess if not restricted
        let tableIndexGenerator = NumberGenerator(maxRange: tableList.count);
        var tableIndex: Int? = tableIndexGenerator.generateNumber();
        while (tableIndex != nil) {
            let table = tableList[tableIndex!];
            if (!restrictedTables.contains(table)) {
            
                // Randomly pick a seat and seat if empty
                let seatIndexGenerator = NumberGenerator(maxRange: table.numOfSeats);
                var seatIndex: Int? = seatIndexGenerator.generateOrderedNumber();
                while (seatIndex != nil) {
                    let seat = table.seats[seatIndex!];
                    if !seat.hasGuest() && neighborCheck(guest, seat) {
                        seat.seatGuest(guest);
                        guest.seatedRandomly = guest.mustSitAtTable.isEmpty; //If others will be seated wtih, need to make sure it cannot be moved
                        guest.tabledRandomly = false;
                        return true;
                    }
                    seatIndex = seatIndexGenerator.generateOrderedNumber();
                }
            }
            tableIndex = tableIndexGenerator.generateNumber();
        }
        
        // If all seats in the tables are taken, check to see if any of the guests are tabledRandomly and replace them
        tableIndexGenerator.reset();
        tableIndex = tableIndexGenerator.generateNumber();
        while (tableIndex != nil) {
            let table = tableList[tableIndex!];
            if (!restrictedTables.contains(table)) {
            
            // Randomly pick a seat and seat if guest is randomlyTabled
                let seatIndexGenerator = NumberGenerator(maxRange: table.numOfSeats);
                var seatIndex: Int? = seatIndexGenerator.generateOrderedNumber();
                while (seatIndex != nil) {
                    let seat = table.seats[seatIndex!];
                    if seat.hasGuest() && neighborCheck(guest, seat) && seat.guestSeated!.tabledRandomly {
                        extraGuests.append(seat.guestSeated!);
                        seat.seatGuest(guest);
                        guest.seatedRandomly = guest.mustSitAtTable.isEmpty; //If others will be seated wtih, need to make sure it cannot be moved
                        guest.tabledRandomly = false;
                        return true;
                    }
                    seatIndex = seatIndexGenerator.generateOrderedNumber();
                }
            }
            tableIndex = tableIndexGenerator.generateNumber();
        }
        
        // Return false for failed seating attempt
        return false;
    }
    
    
    /* Helper function that seats the given guest at a random table from the entire tableList and in a random seat at that table. */
    fileprivate func seatGuestAtRandom(_ guest: Guest, tableList: [Table], restrictedTables: Set<Table>) -> Bool {
        // Randomly pick a table within list and assess if not restricted
        let tableIndexGenerator = NumberGenerator(maxRange: tableList.count);
        var tableIndex: Int? = tableIndexGenerator.generateNumber();
        while (tableIndex != nil) {
            let table = tableList[tableIndex!];
            if (!restrictedTables.contains(table)) {
                
                // Randomly pick a seat and seat if empty
                let seatIndexGenerator = NumberGenerator(maxRange: table.numOfSeats);
                var seatIndex: Int? = seatIndexGenerator.generateOrderedNumber();
                while (seatIndex != nil) {
                    let seat = table.seats[seatIndex!];
                    if !seat.hasGuest() && neighborCheck(guest, seat) {
                        seat.seatGuest(guest);
                        //If others will be seated wtih, need to make sure it cannot be moved
                        guest.seatedRandomly = guest.mustSitAtTable.isEmpty;
                        guest.tabledRandomly = guest.mustSitAtTable.isEmpty;
                        return true;
                    }
                    seatIndex = seatIndexGenerator.generateOrderedNumber();
                }
            }
            tableIndex = tableIndexGenerator.generateNumber();
        }
        
        // Return false for failed seating attempt
        return false;
    }
    
    
    /* Helper function that checks to see if the neighbors of the seat are on the guest's cannot-sit-next-to set. If so returns false, if not returns true. */
    fileprivate func neighborCheck(_ guest: Guest, _ seat: Seat) -> Bool {
        let leftGuest = seat.seatToLeft?.guestSeated;
        let rightGuest = seat.seatToRight?.guestSeated;
        if (leftGuest != nil && guest.cannotSitNextTo.contains(leftGuest!)) {
            return false;
        }
        if (rightGuest != nil && guest.cannotSitNextTo.contains(rightGuest!)) {
            return false;
        }
        return true;
    }
    
    
    /* Helper function that seats a guest and its neighbors in the given seat and its neighbor seats. */
    fileprivate func seatGuestAndNeighbors(_ guest: Guest, seat: Seat) -> Bool {
        
        // Check length of empty seats on left and right and put them in order of least to greatest
        let (emptySeatsOnLeft, emptySeatsOnRight) = checkEmptySeats(seat);
        var emptySeatSides: [String];
        if emptySeatsOnLeft < emptySeatsOnRight {
            emptySeatSides = ["left", "right"];
        }else if emptySeatsOnRight < emptySeatsOnLeft {
            emptySeatSides = ["right", "left"];
        }else {
            emptySeatSides = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: ["left", "right"]) as! [String];
        }
        
        // Get array of neighbors to be seated and seat them
        let neighborOrders = guest.getNeighborChains();
        for order in neighborOrders {
            var order = order; //Override constant status
            for side in emptySeatSides {
                if side == "left" && order.count <= emptySeatsOnLeft {
                    var seat = seat.seatToLeft;
                    while (!order.isEmpty) {
                        let guestToSeat = order.removeFirst();
                        if seat!.hasGuest() || !neighborCheck(guestToSeat, seat!) { return unseatListOfLists(neighborOrders) } //Checking for overlapping of sides
                        seat!.seatGuest(guestToSeat);
                        seat = seat!.seatToLeft;
                    }
                    emptySeatSides.remove(at: emptySeatSides.index(of: "left")!);
                    break;
                }else if side == "right" && order.count <= emptySeatsOnRight {
                    var seat = seat.seatToRight;
                    while (!order.isEmpty) {
                        let guestToSeat = order.removeFirst();
                        if seat!.hasGuest() || !neighborCheck(guestToSeat, seat!) { return unseatListOfLists(neighborOrders) } //Checking for overlapping of sides
                        seat!.seatGuest(guestToSeat);
                        seat = seat!.seatToRight;
                    }
                    emptySeatSides.remove(at: emptySeatSides.index(of: "right")!);
                    break;
                }else {
                    return unseatListOfLists(neighborOrders); //FALSE
                }
            }
        }
        
        //Check if there is an already seated guest to add to the extraGuests array and seat guest
        if guest.isSeated() {
            return true; //Guest seated prior to the sort
        }
        if seat.hasGuest() {
            extraGuests.append(seat.guestSeated!);
        }
        seat.seatGuest(guest);
        return true;
    }
    
    
    /* Helper function that unseats guests in the given list of lists. Usually neighbors that had been seated that led to a failed attempt. */
    @discardableResult
    fileprivate func unseatListOfLists(_ lists: [[Guest]]) -> Bool {
        for list in lists {
            for guest in list {
                guest.seat?.seatGuest(nil);
            }
        }
        return false;
    }
    
    
    /* Helper function that returns a tuple with the number of empty seats to the left and right of the given seat respectively. */
    fileprivate func checkEmptySeats(_ seat: Seat) -> (Int, Int) {
        // Check left seats
        var leftSeat = seat.seatToLeft;
        var emptySeatsOnLeft = 0;
        while (leftSeat != nil) {
            if leftSeat!.hasGuest() || leftSeat! == seat {
                break;
            }
            emptySeatsOnLeft += 1;
            leftSeat = leftSeat!.seatToLeft;
        }
        
        // Check right seats
        var rightSeat = seat.seatToRight;
        var emptySeatsOnRight = 0;
        while (rightSeat != nil) {
            if rightSeat!.hasGuest() || rightSeat! == seat {
                break;
            }
            emptySeatsOnRight += 1;
            rightSeat = rightSeat!.seatToRight;
        }
        return (emptySeatsOnLeft, emptySeatsOnRight);
    }
    
    
    
    /*
     
    /* Helper function that determines the order of seating for must sit next to guests and their respective must sit next to guests. Returns each array list of guests in another array. */
    private func getNeighborSeatingOrders(guest: Guest) -> [[Guest]] {
        let neighbors = guest.mustSitNextTo;
        var arrayOfOrders = [[Guest]]();
        
        //Iterate through given guest's neighbors and make an order for each
        for neighbor in neighbors {
            var guestOrder = [Guest]();
            var lastGuest: Guest = guest;
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
    
    
    // Helper function that attempts to rearrange a table to fit in neighbors, etc.
    private func tableOptomizer(table: Table) {
        // FILL
        // OR MAKE GUESTS RANDOM AND SEAT IN ORDER
    }
     
    */
    
}
