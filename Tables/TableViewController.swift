//
//  TableViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 6/9/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    // MARK: Properties
    @IBOutlet weak var tableNameLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var tableTypeLabel: UILabel!
    @IBOutlet weak var seatNumberLabel: UILabel!
    @IBOutlet weak var tableImageView: TableImageView!
    var guestFields : [UITextField] = [UITextField]();
    
    var table : Table? = nil;
    var tablePlan : TablePlan? = nil;
    var floorPlanPush: Bool = false;
    
    var chosenGuest : Guest? = nil;
    
    
    
    
    // MARK: - View Prep
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load labels with proper titles
        setGuestFieldsArray()
        tableNameLabel.text = table!.name;
        tableTypeLabel.text = table!.tableType.rawValue;
        seatNumberLabel.text = "[" + String(table!.numOfSeats) + "]";
        groupNameLabel.text = table!.tableGroup ?? "No Group";
        if (table!.tableGroup == nil) {
            groupNameLabel.textColor = UIColor.lightGray;
        }
        tableImageView.table = table!;
        setGuestFields();
        
        // If pushed from a floor plan, show nav bar and block edit button creation
        if (floorPlanPush) {
            navigationController?.setNavigationBarHidden(false, animated: false);
        
        // If not, display the edit button in the nav bar
        }else {
            let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(TableViewController.editTable(_:)));
            navigationItem.rightBarButtonItem = editButton;
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setGuestFields();
        tableImageView.setNeedsDisplay();
        (tabBarController as! TabBarController).showCenterButton(true);
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        // Clears tableView selection when this view appears
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true);
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3;
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 3;
        }else if (section == 1) {
            return 1 + table!.numOfSeats;
        }else {
            return 1;
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section != 2) {
            performSegue(withIdentifier: "GuestPickerSegue", sender: self);
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 2) {
            return TitleViewController.footerSize;
        }
        return UITableViewAutomaticDimension;
    }
    
    

    // MARK: - Navigation
    
    @IBAction func unwindToTableView(_ sender: UIStoryboardSegue) {
        // Seats a guest that was chosen from the guest picker controller
        if let sourceViewController = sender.source as? GuestPickerViewController, let indexPath = tableView.indexPathForSelectedRow {
            let seatNum = indexPath.row - 1;
            let seat = table!.seats[seatNum];
            chosenGuest = sourceViewController.chosenGuest;
            seat.seatGuest(chosenGuest);
            setGuestFields();
            tableImageView.setNeedsDisplay();
            (tabBarController as! TabBarController).savePlans();
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If edit is pressed, transfer table info to TableAddViewController
        if let destinationViewController = segue.destination as? TableAddViewController {
            destinationViewController.tablePlan = tablePlan;
            destinationViewController.table = table;
            destinationViewController.beingPushed = true;
        
        // If a seat cell is pressed, transfer table plan to GuestPickerViewController
        } else if let navController = segue.destination as? UINavigationController, let destinationViewController = navController.topViewController as? GuestPickerViewController {
            destinationViewController.tablePlan = tablePlan;
        }
    }
    
    func editTable(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "EditTableSegue", sender: self);
    }
    
    
    
    //MARK: - Button Actions
    
    @IBAction func clearTablePressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Clear Table?", message: "Are you sure you want to clear all of this table's seats?", preferredStyle: .alert);
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
        }
        let deleteButton = UIAlertAction(title: "Clear", style: .destructive) { (_) in
            self.clearAllSeats();
            (self.tabBarController as! TabBarController).savePlans();
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
        }
        alertController.addAction(cancelAction);
        alertController.addAction(deleteButton);
        present(alertController, animated: true, completion: nil);
    }
    
    /* Helper function that clears all of this table's seats. */
    private func clearAllSeats() {
        for seat in table!.seats {
            seat.seatGuest(nil);
        }
        setGuestFields();
        tableImageView.setNeedsDisplay();
        (tabBarController as! TabBarController).showCenterButton(true);
    }
    

    
    // MARK: - TextField Nonsense
    
    @IBOutlet weak var guestOneField: UITextField!
    @IBOutlet weak var guestTwoField: UITextField!
    @IBOutlet weak var guestThreeField: UITextField!
    @IBOutlet weak var guestFourField: UITextField!
    @IBOutlet weak var guestFiveField: UITextField!
    @IBOutlet weak var guestSixField: UITextField!
    @IBOutlet weak var guestSevenField: UITextField!
    @IBOutlet weak var guestEightField: UITextField!
    @IBOutlet weak var guestNineField: UITextField!
    @IBOutlet weak var guestTenField: UITextField!
    @IBOutlet weak var guestElevenField: UITextField!
    @IBOutlet weak var guestTwelveField: UITextField!
    @IBOutlet weak var guestThirteenField: UITextField!
    @IBOutlet weak var guestFourteenField: UITextField!
    @IBOutlet weak var guestFifteenField: UITextField!
    @IBOutlet weak var guestSixteenField: UITextField!
    @IBOutlet weak var guestSeventeenField: UITextField!
    @IBOutlet weak var guestEighteenField: UITextField!
    @IBOutlet weak var guestNineteenField: UITextField!
    @IBOutlet weak var guestTwentyField: UITextField!
    
    func setGuestFieldsArray() {
        guestFields = [guestOneField, guestTwoField, guestThreeField, guestFourField, guestFiveField, guestSixField, guestSevenField, guestEightField, guestNineField, guestTenField, guestElevenField, guestTwelveField, guestThirteenField, guestFourteenField, guestFifteenField, guestSixteenField, guestSeventeenField, guestEighteenField, guestNineteenField, guestTwentyField];
    }
    
    func setGuestFields() {
        for (index, field) in guestFields.enumerated() {
            if (index < table!.numOfSeats) {
                field.isUserInteractionEnabled = false;
                let guest = table!.seats[index].guestSeated?.getFullName(.FirstName);
                field.text = guest;
            }
        }
    }
}
