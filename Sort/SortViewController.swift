//
//  SortViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/24/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class SortViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    
    @IBOutlet weak var sortTableView: UITableView!
    @IBOutlet weak var applySortButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    
    // View Properties
    var activeSize: CGSize!;
    var inactiveSize: CGSize!;
    //var queue = DispatchQueue();
    
    
    var tablePlan: TablePlan!;
    var tableSorter: TableSorter!;
    var sorted: Bool = false;
    var sortSuccessful: Bool = false;
    var sortApplied: Bool = false;
    let REPITITIONS: Int = 500;
    
    // MARK: - View Prep
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up tableview delegate and datasource
        sortTableView.delegate = self;
        sortTableView.dataSource = self;
        
        // Retrieve table plan from TabBarController and update counts
        let tabBarController = self.tabBarController as! TabBarController;
        tablePlan = tabBarController.tablePlan;
        
        // Disable apply sort button until a sort is loaded
        applySortButton.isEnabled = false;
        
        // Configure activity indicator and sizes
        activeSize = CGSize(width: self.view.frame.width, height: 80);
        inactiveSize = CGSize(width: 0, height: 0);
        
        self.view.addSubview(activityIndicator);
        activityIndicator.activityIndicatorViewStyle = .whiteLarge;
        activityIndicator.color = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1);
        activityIndicator.stopAnimating();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.navigationItem.rightBarButtonItems = [];
        
        // Set up new tableSorter from tablePlan whenever view is loaded
        tableSorter = TableSorter(tablePlan: tablePlan);
        errorLabel.text = nil;
        sorted = false;
        sortTableView.reloadData();
        if let conflictedGuests = tableSorter.checkAllGuestConstraints() {
            sortButton.isEnabled = false;
            var message: String = constraintError;
            for guest in conflictedGuests {
                message += guest.getFullName(.FirstName) + ", ";
            }
            errorLabel.text = message;
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Set activityIndicator origin here so tableview frame origin is accessible
        activityIndicator.frame = CGRect(origin: sortTableView.frame.origin, size: inactiveSize);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !sortApplied {
            tableSorter.undoSort();
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        sortButton.isEnabled = true;
        applySortButton.isEnabled = false;
        sortApplied = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - TableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if sorted && sortSuccessful {
            return tablePlan.tableList.count;
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + tablePlan.tableList[section].numOfSeats;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let table = tablePlan.tableList[(indexPath as NSIndexPath).section];
        //Table Name Cell
        if ((indexPath as NSIndexPath).row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SortTableCell", for: indexPath) as! SortTableTableViewCell;
            cell.tableNameLabel.text = table.name;
            return cell;
        //Table Image Cell
        }else if ((indexPath as NSIndexPath).row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SortTableImageCell", for: indexPath) as! SortTableImageTableViewCell;
            cell.tableImageView.table = table;
            cell.tableImageView.setNeedsDisplay();
            return cell;
        //Table Seat Cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SortSeatCell", for: indexPath) as! SortSeatTableViewCell;
            cell.seatNumberLabel.text = String((indexPath as NSIndexPath).row - 1) + " -";
            let guest = table.seats[(indexPath as NSIndexPath).row-2].guestSeated;
            cell.seatGuestLabel.text = guest?.getFullName(.FirstName) ?? "";
            return cell;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((indexPath as NSIndexPath).row == 0) {
            return 44;
        }
        if ((indexPath as NSIndexPath).row == 1) {
            return 200;
        }else {
            return 28;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 6;
        }
        return 2;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2;
    }
    
    
    
    // MARK: - Button Actions
    
    /* Function that sets up a preview sort for the view controller */
    @IBAction func sort(_ sender: UIButton) {
        UIApplication.shared.beginIgnoringInteractionEvents();
        errorLabel.text = nil;
        activityIndicator.frame = CGRect(origin: activityIndicator.frame.origin, size: activeSize);
        sortButton.isEnabled = false;
        applySortButton.isEnabled = false;
        activityIndicator.startAnimating();
        
        // Run sort in the background
        DispatchQueue.main.async {
            self.sortIt();
            
            DispatchQueue.main.async {
                // Reload data
                self.activityIndicator.stopAnimating();
                self.activityIndicator.frame = CGRect(origin: self.activityIndicator.frame.origin, size: self.inactiveSize);
                self.sortButton.isEnabled = true;
                self.sortTableView.reloadData();
                UIApplication.shared.endIgnoringInteractionEvents();
            }
        }
    }
    
    private func sortIt() {
        // If already sorted
        if (sorted) {
            // Do a resort
            if tableSorter.resortAllGuests(REPITITIONS) {
                sortSuccessful = true;
                applySortButton.isEnabled = true;
                // Failed resort
            }else {
                errorLabel.text = seatingError;
                applySortButton.isEnabled = false;
                sortSuccessful = false;
            }
            
            // If not yet sorted
        }else if tableSorter.sortAllGuests(REPITITIONS) {
            sorted = true;
            sortSuccessful = true;
            applySortButton.isEnabled = true;
            // Failed Sort
        }else {
            errorLabel.text = seatingError;
            applySortButton.isEnabled = false;
            sortSuccessful = false;
        }
    }
    
    
    /* Function that takes a preview sort and applies it to the table plan */
    @IBAction func applySort(_ sender: UIButton) {
        applySortCheck();
    }
    
    /* Helper function that sets up an alert controller that confirms whether or not the user wants the sort to be applied to the table plan. */
    fileprivate func applySortCheck() {
        let alertController = UIAlertController(title: "Apply Sort?", message: "Once applied, all sorted guests will be seated and this sort will no longer be reversable.", preferredStyle: .alert);
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
        let applyButton = UIAlertAction(title: "Apply", style: .destructive) { (_) in
            self.sortApplied = true;
            self.applySortButton.isEnabled = false;
            self.sortButton.isEnabled = false;
            (self.tabBarController as! TabBarController).savePlans();
        }
        alertController.addAction(cancelAction);
        alertController.addAction(applyButton);
        present(alertController, animated: true, completion: nil);
    }
    
    // MARK: - Error Messages
    
    let constraintError: String = "The following guests have conflicting constraints: \n";
    let seatingError: String = "There was a failure in creating a seating configuration for the current set of guests and their constraints. You may attempt another sort. If this error persists, make sure there are enough seats for the guests and constraints of guests don't conflict with those of others. Visit the 'Help' option in settings for tips on how to correct this.";

}
