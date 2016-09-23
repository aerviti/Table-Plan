//
//  GuestTableViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/24/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class GuestTableViewController: UITableViewController {
    
    //MARK: Properties
    @IBOutlet weak var guestCount: UILabel!
    @IBOutlet weak var unseatedCount: UILabel!
    @IBOutlet weak var sortLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    var tablePlan : TablePlan!;
    var alphabetHeaderTitles = ["#", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
    
    var cellUnwindedFrom : UITableViewCell? = nil;
    
    
    
    
    // MARK: - View Prep

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color of section index
        tableView.sectionIndexBackgroundColor = UIColor.clear;
        
        // Show edit button in navbar
        navigationItem.leftBarButtonItem = editButtonItem;
        
        // Retrieve the guest and table list from the TabBarController and update counts and sort label
        let tabBarController = self.tabBarController as! TabBarController;
        tablePlan = tabBarController.tablePlan;
        updateCounts();
        sortLabel.text = tablePlan.sort.rawValue;
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //tablePlan.sortGuests();
        //tableView.reloadData();
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        // Reload guest list (bugs in view will appear from a non-applied sort)
        tablePlan.sortGuests();
        tableView.reloadData();
        (tabBarController as! TabBarController).showCenterButton(true);
        
        // Clears tableView selection when this view appears
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true);
        }
        updateCounts();
        (tabBarController as! TabBarController).showCenterButton(true);
    }
    
    
    // Updates the counter labels for # of guests and # of unseated guests
    func updateCounts() {
        guestCount.text = String(tablePlan.guestList.count);
        unseatedCount.text = String(tablePlan.unseated);
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        updateCounts();
        if (tablePlan.sort == .FirstName || tablePlan.sort == .LastName) {
            return 27;
        }else {
            return 2;
        }
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (tablePlan.sort == .FirstName || tablePlan.sort == .LastName) {
            return alphabetHeaderTitles[section];
        }else {
            if (section == 0) {
                return "Unseated";
            }
            return "Seated";
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (self.tableView(tableView, numberOfRowsInSection: section) == 0) {
            return 0;
        }else {
            return UITableViewAutomaticDimension;
        }
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tablePlan.sort == .FirstName) {
            return tablePlan.getFirstnameCount(index: section);
            
        }else if (tablePlan.sort == .LastName) {
            return tablePlan.getLastnameCount(index: section);
            
        }else {
            if (section == 0) {
                return tablePlan.unseated;
            }else {
                return tablePlan.guestList.count - tablePlan.unseated;
            }
        }
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "GuestTableViewCell";
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! GuestTableViewCell;
        
        // Retrieve guest based off sort
        let guest = tablePlan.getGuestAtIndex(indexPath.section, indexPath.row);
        
        // Set cell name labels based off of sort
        if (tablePlan.sort == .FirstName || tablePlan.sort == .UnseatedFirstName) {
            cell.firstName.text = guest.firstName;
            cell.lastName.text = guest.lastName;
        }else if (tablePlan.sort == .LastName || tablePlan.sort == .UnseatedLastName) {
            cell.firstName.text = guest.lastName + ",";
            cell.lastName.text = guest.firstName;
        }
        
        // Set cell seat label
        if guest.isSeated() {
            let tableString = guest.table!.name;
            let seatNumString = (guest.seat!.seatNumOfTable + 1).description;
            cell.seatLabel.text = tableString + " - #" + seatNumString;
        }else {
            cell.seatLabel.text = "Unseated";
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48;
    }
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if (tablePlan.sort == .FirstName || tablePlan.sort == .LastName) {
            return alphabetHeaderTitles;
        }else {
            return ["U", "S"];
        }
    }
    

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if index == 0 {
            tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false);
            return -1;
        }
        return index;
    }
    

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = tablePlan.getIndex(indexPath.section, indexPath.row);
            tablePlan.removeGuest(index);
            tableView.deleteRows(at: [indexPath], with: .fade)
            (tabBarController as! TabBarController).savePlans();
        }
    }
    
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If a cell is clicked, prepares the guest view with the guest's info
        if let destinationViewController = segue.destination as? GuestViewController {
            let cell = sender as! GuestTableViewCell;
            let indexPath = tableView.indexPath(for: cell)!;
            let guest = tablePlan.getGuestAtIndex(indexPath.section, indexPath.row);
            destinationViewController.guest = guest;
            destinationViewController.tablePlan = tablePlan;
        
        // If "Add Guest" is clicked, transfer over the current tablePlan to the new view controller (through the nav controller)
        }else if let navViewController = segue.destination as? UINavigationController {
            if let destinationViewController = navViewController.topViewController as? AddGuestViewController {
                destinationViewController.tablePlan = tablePlan;
                destinationViewController.navigationItem.title = "Add Guest";
            }
        }
    }
    
    
    @IBAction func unwindToGuestTable(_ sender: UIStoryboardSegue) {
        //Handle an unwind from a single added/edited guest
        if let sourceViewController = sender.source as? AddGuestViewController, let newGuest = sourceViewController.guest {
            
            // Adds new guest if unwinded from a newly added guest
            if (tableView.indexPathForSelectedRow == nil) {
                tablePlan.addGuest(newGuest);
            }
         
        //Handle an unwind from multiple added guests
        }else if let sourceViewController = sender.source as? AddMultipleGuestsTableViewController, let newGuests = sourceViewController.guestArray {
            for guest in newGuests {
                tablePlan.addGuest(guest);
            }
        }
        
        tablePlan.sortGuests();
        tableView.reloadData();
        (tabBarController as! TabBarController).savePlans();
    }
    
    
    
    // MARK: - Actions
    
    // Create UIAlertController and present it with sorting options when Sort button is tapped
    @IBAction func sortTapped(_ sender: UIButton) {
        // Set up Action Controller
        let sortController = UIAlertController(title: nil, message: "Sort By:", preferredStyle: .actionSheet);
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
        sortController.addAction(cancelAction);
        let firstNameAction = UIAlertAction(title: "First Name", style: .default, handler: firstNameHandler);
        sortController.addAction(firstNameAction);
        let lastNameAction = UIAlertAction(title: "Last Name", style: .default, handler: lastNameHandler);
        sortController.addAction(lastNameAction);
        let unseatedFirstNameAction = UIAlertAction(title: "Unseated (First Name)", style: .default, handler: unseatedFirstNameHandler);
        sortController.addAction(unseatedFirstNameAction);
        let unseatedLastNameAction = UIAlertAction(title: "Unseated (Last Name)", style: .default, handler: unseatedLastNameHandler);
        sortController.addAction(unseatedLastNameAction);
        
        // Prep popover presentation and present the controller
        sortController.popoverPresentationController?.sourceView = sender;
        sortController.popoverPresentationController?.sourceRect = sender.bounds;
        present(sortController, animated: true, completion: nil);
    }
    
    
    // Sorts by first name and sets sort label
    fileprivate func firstNameHandler(_ action: UIAlertAction) {
        tablePlan.sort = .FirstName;
        tablePlan.sortGuests();
        sortLabel.text = "First Name";
        tableView.reloadData();
        (tabBarController as! TabBarController).savePlans();
    }
    
    
    // Sorts by last name and sets sort label
    fileprivate func lastNameHandler(_ action: UIAlertAction) {
        tablePlan.sort = .LastName;
        tablePlan.sortGuests();
        sortLabel.text = "Last Name";
        tableView.reloadData();
        (tabBarController as! TabBarController).savePlans();
    }
    
    
    // Sorts by the isSeated() function and first name, and sets sort label
    fileprivate func unseatedFirstNameHandler(_ action: UIAlertAction) {
        tablePlan.sort = .UnseatedFirstName;
        tablePlan.sortGuests();
        sortLabel.text = "Unseated (First)";
        tableView.reloadData();
        (tabBarController as! TabBarController).savePlans();
    }
    
    
    // Sorts be the isSeated() function and last name, and sets sort label
    fileprivate func unseatedLastNameHandler(_ action: UIAlertAction) {
        tablePlan.sort = .UnseatedLastName;
        tablePlan.sortGuests();
        sortLabel.text = "Unseated (Last)";
        tableView.reloadData();
        (tabBarController as! TabBarController).savePlans();
    }
}
