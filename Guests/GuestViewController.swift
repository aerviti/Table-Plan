//
//  GuestViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/31/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class GuestViewController: UITableViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var tableName: UILabel!
    @IBOutlet weak var seatName: UILabel!
    @IBOutlet weak var tableImageView: TableImageView!
    var labelArray : [UILabel] = [UILabel]();
    
    var guest : Guest? = nil;
    var tablePlan : TablePlan? = nil;
    
    @IBOutlet weak var mustSitNextToAddButton: UIButton!
    @IBOutlet weak var mustSitNextToRemoveButton: UIButton!
    @IBOutlet weak var mustSitNextToField: UITextView!
    @IBOutlet weak var mustSitAtTableOfAddButton: UIButton!
    @IBOutlet weak var mustSitAtTableOfRemoveButton: UIButton!
    @IBOutlet weak var mustSitAtTableOfField: UITextView!
    @IBOutlet weak var cannotSitNextToAddButton: UIButton!
    @IBOutlet weak var cannotSitNextToRemoveButton: UIButton!
    @IBOutlet weak var cannotSitNextToField: UITextView!
    @IBOutlet weak var cannotSitAtTableOfAddButton: UIButton!
    @IBOutlet weak var cannotSitAtTableOfRemoveButton: UIButton!
    @IBOutlet weak var cannotSitAtTableOfField: UITextView!
    @IBOutlet weak var mustSitAtTableAddButton: UIButton!
    @IBOutlet weak var mustSitAtTableRemoveButton: UIButton!
    @IBOutlet weak var mustSitAtTableField: UILabel!
    @IBOutlet weak var mustSitInTableGroupAddButton: UIButton!
    @IBOutlet weak var mustSitInTableGroupRemoveButton: UIButton!
    @IBOutlet weak var mustSitInTableGroupField: UILabel!
    weak var selectedButton: UIButton? = nil;

    // MARK: - View Prep
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create edit button
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(GuestViewController.editGuest(_:)));
        navigationItem.rightBarButtonItem = editButton;
        
        // Setup view
        firstName.text = guest!.firstName;
        lastName.text = guest!.lastName;
        tableName.text = guest!.table?.name ?? "N/A";
        seatName.text = guest!.getSeatString() ?? "N/A";
        tableImageView.table = guest!.table;
        tableImageView.highlightedSeat = guest!.seat?.seatNumOfTable;
        setSeatLabelsArray();
        setSeatLabels();
        
        // Set constraint text fields and buttons
        updateConstraintFields()
        updateConstraintButtons();
    }
        
    
    override func viewWillAppear(_ animated: Bool) {
        // Assure a seat change did not occur on another tab
        tableName.text = guest!.table?.name ?? "N/A";
        seatName.text = guest!.getSeatString() ?? "N/A";
        tableImageView.setNeedsDisplay();
        tableImageView.highlightedSeat = guest!.seat?.seatNumOfTable;
        setSeatLabels();
        updateConstraintFields();
        updateConstraintButtons();
        
        (tabBarController as! TabBarController).showCenterButton(true);
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Helper function that updates the constraint text fields. */
    fileprivate func updateConstraintFields() {
        mustSitNextToField.text = guest?.getMustSitNextToString();
        mustSitAtTableOfField.text = guest?.getMustSitAtTableOfString();
        cannotSitNextToField.text = guest?.getCannotSitNextToString();
        cannotSitAtTableOfField.text = guest?.getCannotSitAtTableOfString();
        mustSitAtTableField.text = guest?.getTableConstraintString() ?? "No Table";
        if (guest!.hasTableConstraint) {
            mustSitAtTableField.textColor = UIColor.darkText;
        }else {
            mustSitAtTableField.textColor = UIColor.lightGray;
        }
        mustSitInTableGroupField.text = guest?.getGroupConstraintString() ?? "No Group";
        if (guest!.hasGroupConstraint) {
            mustSitInTableGroupField.textColor = UIColor.darkText;
        }else {
            mustSitInTableGroupField.textColor = UIColor.lightGray;
        }
    }
    
    
    /* Grays out any remove buttons if the corresponding set is empty. */
    func updateConstraintButtons() {
        mustSitNextToRemoveButton.isEnabled = (guest!.mustSitNextToSize > 0);
        mustSitNextToAddButton.isEnabled = (guest!.mustSitNextToSize < 2);
        mustSitAtTableOfRemoveButton.isEnabled = (guest!.mustSitAtTableSize > 0);
        mustSitAtTableOfAddButton.isEnabled = (guest!.mustSitAtTableSize < 19);
        cannotSitNextToRemoveButton.isEnabled = (guest!.cannotSitNextToSize > 0);
        cannotSitNextToAddButton.isEnabled = (guest!.cannotSitNextToSize < 2);
        cannotSitAtTableOfRemoveButton.isEnabled = (guest!.cannotSitAtTableSize > 0);
        cannotSitAtTableOfAddButton.isEnabled = (guest!.cannotSitAtTableSize < 19);
        mustSitAtTableRemoveButton.isEnabled = guest!.hasTableConstraint;
        mustSitInTableGroupRemoveButton.isEnabled = guest!.hasGroupConstraint;
    }
    
    // MARK: - Table View DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0 || section == 3) {
            return 1;
        }else if (section == 1) {
            let seats = guest!.table?.numOfSeats ?? 0;
            return 3 + seats;
        }else {
            return 10;
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 3) {
            return TitleViewController.footerSize;
        }
        return UITableViewAutomaticDimension;
    }

    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the edit button is pressed, set the AddGuestViewController to the properties of the current guest
        if (segue.identifier == "EditGuestSegue") {
            let destinationViewController = segue.destination as! AddGuestViewController;
            destinationViewController.guest = guest;
            destinationViewController.beingPushed = true;
            destinationViewController.tablePlan = tablePlan;
            
        }else if let navViewController = segue.destination as? UINavigationController {
            // Pass on tablePlan to guest picker if an add guest constraint button is pressed
            if let destinationViewController = navViewController.topViewController as? GuestPickerViewController {
                destinationViewController.tablePlan = tablePlan;
                destinationViewController.addingConstraint = true;
                destinationViewController.navigationItem.title = "Add Guest Constraint"
                
                // Pass on appropriate constraint list to object picker if a remove guest constraint or add table/group button is pressed
            }else if let destinationViewController = navViewController.topViewController as? ObjectPickerViewController {
                switch selectedButton! {
                case mustSitNextToRemoveButton:
                    destinationViewController.objectType = .guest;
                    destinationViewController.guestList = guest!.getMustSitNextTo();
                case mustSitAtTableOfRemoveButton:
                    destinationViewController.objectType = .guest;
                    destinationViewController.guestList = guest!.getMustSitAtTableOf();
                case cannotSitNextToRemoveButton:
                    destinationViewController.objectType = .guest;
                    destinationViewController.guestList = guest!.getCannotSitNextTo();
                case cannotSitAtTableOfRemoveButton:
                    destinationViewController.objectType = .guest;
                    destinationViewController.guestList = guest!.getCannotSitAtTableOf();
                case mustSitAtTableAddButton:
                    destinationViewController.objectType = .table;
                    destinationViewController.tableList = tablePlan!.tableList;
                    destinationViewController.navigationItem.title = "Add Table Constraint";
                case mustSitInTableGroupAddButton:
                    destinationViewController.objectType = .group;
                    destinationViewController.groupList = tablePlan!.tableGroupList as [NSString];
                    destinationViewController.navigationItem.title = "Add Group Constraint";
                default:
                    break;
                }
            }
        }
    }
    
    
    @IBAction func unwindToAddGuest(_ sender: UIStoryboardSegue) {
        // If unwinded from a guest picker controller, adds the appropriate constraint based on the chosen guest
        if let sourceViewController = sender.source as? GuestPickerViewController, let chosenGuest = sourceViewController.chosenGuest {
            // Only add guest constraint if chosen guest is not this guest
            do {
                if (selectedButton == mustSitNextToAddButton) {
                    try guest!.mustSitNextTo(chosenGuest);
                }else if (selectedButton == mustSitAtTableOfAddButton) {
                    try guest!.mustSitAtTableOf(chosenGuest);
                }else if (selectedButton == cannotSitNextToAddButton) {
                    guest!.cannotSitNextTo(chosenGuest);
                }else if (selectedButton == cannotSitAtTableOfAddButton) {
                    guest!.cannotSitAtTableOf(chosenGuest);
                }
            // Call appropriate error alert
            }catch Guest.GuestError.constraintTooBigError {
                DispatchQueue.main.async {
                    self.maxConstraintError();
                }
            }catch Guest.GuestError.alreadyIncludedError {
                DispatchQueue.main.async {
                    self.alreadyIncludedError();
                }
            }catch Guest.GuestError.sameGuestError {
                DispatchQueue.main.async {
                    self.sameGuestError();
                }
            }catch let error {
                print(error);
            }
    
        // If unwinded from an object picker controller, removes/adds the appropriate constraint based on the chosen object
        }else if let sourceViewController = sender.source as? ObjectPickerViewController, let chosenObject = sourceViewController.chosenObject {
            // Check through guest remove buttons
            if (selectedButton == mustSitNextToRemoveButton) {
                guest!.removeMustSitNextTo(chosenObject as! Guest);
            }else if (selectedButton == mustSitAtTableOfRemoveButton) {
                guest!.removeMustSitAtTableOf(chosenObject as! Guest);
            }else if (selectedButton == cannotSitNextToRemoveButton) {
                guest!.removeCannotSitNextTo(chosenObject as! Guest);
            }else if (selectedButton == cannotSitAtTableOfRemoveButton) {
                guest!.removeCannotSitAtTableOf(chosenObject as! Guest);
                
            // Check group constraint add button
            }else if (selectedButton == mustSitInTableGroupAddButton) {
                guest!.addGroupConstraint(chosenObject as! String);
                
            // Check table constraint add button
            }else if (selectedButton == mustSitAtTableAddButton) {
                guest!.addTableConstraint(chosenObject as! Table);
            }
        }
        updateConstraintFields();
        updateConstraintButtons();
        (tabBarController as! TabBarController).savePlans();

    }
    
    
    func editGuest(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "EditGuestSegue", sender: self);
    }
    
    
    
    //MARK: - Error Alerts
    
    /* Displays an error pointing out that the user picked a guest for its own constraint. */
    func sameGuestError() {
        let error = UIAlertController(title: "ERROR", message: "Cannot add a guest to its own constraint.", preferredStyle: .alert);
        let okButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil);
        error.addAction(okButton);
        present(error, animated: true, completion: nil);
    }
    
    
    /* Displays an error pointing out that the user picked a guest that is already in the constraint. */
    func alreadyIncludedError() {
        let error = UIAlertController(title: "ERROR", message: "The guest selected is already in the constraint.", preferredStyle: .alert);
        let okButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil);
        error.addAction(okButton);
        present(error, animated: true, completion: nil);
    }
    
    
    /* Displays an error pointing out that the selected guest will create a constraint that exceeds a constraint max. */
    func maxConstraintError() {
        let error = UIAlertController(title: "ERROR", message: "The guest selected will cause a connected constraint to exceed its limit.", preferredStyle: .alert);
        let okButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil);
        error.addAction(okButton);
        present(error, animated: true, completion: nil);
    }
    
    
    
    //MARK: - Button Actions
    
    @IBAction func addGuestToConstraint(_ sender: UIButton) {
        selectedButton = sender;
        performSegue(withIdentifier: "AddConstraintGuest", sender: self);
    }
    
    
    @IBAction func removeGuestFromConstraint(_ sender: UIButton) {
        selectedButton = sender;
        performSegue(withIdentifier: "ObjectConstraintSegue", sender: self);
    }
    
    
    @IBAction func addGroupTableConstraint(_ sender: UIButton) {
        selectedButton = sender;
        performSegue(withIdentifier: "ObjectConstraintSegue", sender: self);
    }
    
    
    @IBAction func removeGroupConstraint(_ sender: UIButton) {
        guest!.removeGroupConstraint();
        mustSitInTableGroupField.text = "No Group";
        mustSitInTableGroupField.textColor = UIColor.lightGray;
        updateConstraintButtons();
        (tabBarController as! TabBarController).savePlans();
    }
    
    
    @IBAction func removeTableConstraint(_ sender: UIButton) {
        guest!.removeTableConstraint();
        mustSitAtTableField.text = "No Table";
        mustSitAtTableField.textColor = UIColor.lightGray;
        updateConstraintButtons();
        (tabBarController as! TabBarController).savePlans();
    }
    
    
    @IBAction func clearConstraintsPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Clear Constraints?", message: "Are you sure you want to clear all constraints for this guest?", preferredStyle: .alert);
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
        }
        let deleteButton = UIAlertAction(title: "Clear", style: .destructive) { (_) in
            self.guest!.clearConstraints();
            self.updateConstraintFields();
            self.updateConstraintButtons();
            (self.tabBarController as! TabBarController).savePlans();
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
        }
        alertController.addAction(cancelAction);
        alertController.addAction(deleteButton);
        present(alertController, animated: true, completion: nil);
    }
    
    
    
    // MARK: - Seat Label Junk
    
    @IBOutlet weak var seatOneLabel: UILabel!
    @IBOutlet weak var seatTwoLabel: UILabel!
    @IBOutlet weak var seatThreeLabel: UILabel!
    @IBOutlet weak var seatFourLabel: UILabel!
    @IBOutlet weak var seatFiveLabel: UILabel!
    @IBOutlet weak var seatSixLabel: UILabel!
    @IBOutlet weak var seatSevenLabel: UILabel!
    @IBOutlet weak var seatEightLabel: UILabel!
    @IBOutlet weak var seatNineLabel: UILabel!
    @IBOutlet weak var seatTenLabel: UILabel!
    @IBOutlet weak var seatElevenLabel: UILabel!
    @IBOutlet weak var seatTwelveLabel: UILabel!
    @IBOutlet weak var seatThirteenLabel: UILabel!
    @IBOutlet weak var seatFourteenLabel: UILabel!
    @IBOutlet weak var seatFifteenLabel: UILabel!
    @IBOutlet weak var seatSixteenLabel: UILabel!
    @IBOutlet weak var seatSeventeenLabel: UILabel!
    @IBOutlet weak var seatEighteenLabel: UILabel!
    @IBOutlet weak var seatNineteenLabel: UILabel!
    @IBOutlet weak var seatTwentyLabel: UILabel!
    
    func setSeatLabelsArray() {
        labelArray = [seatOneLabel, seatTwoLabel, seatThreeLabel, seatFourLabel, seatFiveLabel, seatSixLabel, seatSevenLabel, seatEightLabel, seatNineLabel, seatTenLabel, seatElevenLabel, seatTwelveLabel, seatThirteenLabel, seatFourteenLabel, seatFifteenLabel, seatSixteenLabel, seatSeventeenLabel, seatEighteenLabel, seatNineteenLabel, seatTwentyLabel];
    }
    
    func setSeatLabels() {
        if (guest!.table != nil) {
            for (index, label) in labelArray.enumerated() {
                if (index < guest!.table!.numOfSeats) {
                    let seatedGuest = guest!.table?.seats[index].guestSeated;
                    label.text = seatedGuest?.getFullName(.FirstName);
                }
            }
        }
    }

}
