//
//  GuestPickerViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 6/28/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class GuestPickerViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    // MARK: Properties
    
    var searchController: UISearchController!;
    var tablePlan: TablePlan!;
    var unfilteredGuests: [Guest]!
    var filteredGuests: [Guest] = [Guest]();
    var chosenGuest: Guest? = nil;
    var addingConstraint: Bool = false;
    
    // MARK: - View Prep
    
    override func loadView() {
        //Prep unfiltered guestlist before tableview functions are called
        unfilteredGuests = tablePlan.guestList;
        if tablePlan.sort == TablePlan.GuestSort.UnseatedLastName {
            unfilteredGuests.sort(by: Guest.sortByLastName);
        }else if tablePlan.sort == TablePlan.GuestSort.UnseatedFirstName {
            unfilteredGuests.sort(by: Guest.sortByFirstName);
        }
        super.loadView();
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up search bar
        searchController = UISearchController(searchResultsController: nil);
        searchController.dimsBackgroundDuringPresentation = false;
        searchController.searchResultsUpdater = self;
        definesPresentationContext = true;
        tableView.tableHeaderView = searchController.searchBar;
        self.searchController.loadViewIfNeeded();
        
        // Set up search bar scope controller
        searchController.searchBar.scopeButtonTitles = ["All", "Unseated"];
        searchController.searchBar.delegate = self;
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Search Controller
    
    /* Takes the searchBar text and selected scope and updates the filtered guests list when text in the searchBar is changed */
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar;
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex];
        filterContentForSearchText(searchController.searchBar.text!, scope: scope);
    }
    
    
    // Helper function that filters the filteredGuests list and reloads data
    fileprivate func filterContentForSearchText(_ searchText: String, scope: String) {
        filteredGuests = unfilteredGuests.filter { guest in
            let unseatedScope = (scope == "Unseated");
            let scopeCheck = (scope == "All" || unseatedScope == !guest.isSeated());
            let name = guest.getFullName(.FirstName);
            
            //Ignore empty searchText if filtered only by a scope
            if (searchText == "") {
                return scopeCheck;
            }
            
            return scopeCheck && name.lowercased().contains(searchText.lowercased());
        }
        tableView.reloadData();
    }
    
    
    /* Takes the searchBar text and selected scope and updates the filtered guests list when a new scope is clicked. */
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope]);
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredGuests.count + 1;
        }
        return unfilteredGuests.count + 1;
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GuestPickerCell", for: indexPath) as! GuestPickerTableViewCell;
        
        // Set guest to nil for the first "No Guest" cell
        let guest: Guest?;
        if ((indexPath as NSIndexPath).row == 0) {
            guest = nil;
            cell.firstNameLabel.textColor = UIColor.lightGray;
            cell.guestImage.isHidden = true;
        
        // Set guest if a search has been conducted
        }else if searchController.isActive {
            cell.firstNameLabel.textColor = UIColor.darkText;
            cell.guestImage.isHidden = false;
            guest = filteredGuests[(indexPath as NSIndexPath).row - 1];

        // Set guest if a search has NOT been conducted
        }else {
            cell.firstNameLabel.textColor = UIColor.darkText;
            cell.guestImage.isHidden = false;
            guest = unfilteredGuests[(indexPath as NSIndexPath).row - 1];
        }
        
        // Set cell name labels based off of sort
        if (tablePlan.sort == .FirstName || tablePlan.sort == .UnseatedFirstName) {
            cell.firstNameLabel.text = guest?.firstName ?? "**No Guest**";
            cell.lastNameLabel.text = guest?.lastName;
        }else if (tablePlan.sort == .LastName || tablePlan.sort == .UnseatedLastName) {
            if let last = guest?.lastName {
                cell.firstNameLabel.text = last + ",";
            }else {
                cell.firstNameLabel.text = "**No Guest**";
            }
            cell.lastNameLabel.text = guest?.firstName;
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Set guest to nil if first "No Guest" cell is chosen
        if ((indexPath as NSIndexPath).row == 0) {
            chosenGuest = nil;
        
        // Set guest if a search has been conducted
        }else if searchController.isActive {
            chosenGuest = filteredGuests[(indexPath as NSIndexPath).row-1];
            
        // Set guest if a search has NOT been conducted
        }else {
            chosenGuest = unfilteredGuests[(indexPath as NSIndexPath).row-1];
        }
        // Unwind to added 
        if addingConstraint {
            performSegue(withIdentifier: "AddConstraintSegue", sender: chosenGuest);
        }else {
            performSegue(withIdentifier: "GuestChosenSegue", sender: chosenGuest);
        }
    }
    
    
    
    // MARK: - Button Actions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil);
    }
    
}
