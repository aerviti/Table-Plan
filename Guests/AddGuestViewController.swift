//
//  AddGuestViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/25/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class AddGuestViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var tableText: UITextField!
    @IBOutlet weak var seatText: UITextField!
    @IBOutlet weak var tableImageView: TableImageView!
    var labelArray : [UILabel] = [UILabel]();
    
    var tablePlan : TablePlan? = nil;
    var guest : Guest? = nil;
    var beingPushed = false; //True if view is being pushed, false if otherwise
    
    var chosenTable : Table? = nil;
    var chosenSeat : Seat? = nil;
    
    

    // MARK: - View Prep
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create picker views and set their delegate and datasource
        let screenWidth = view.bounds.size.width;
        
        let tableToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44));
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(AddGuestViewController.tablePickerPressed));
        tableToolBar.setItems([space, doneButton], animated: false);
        tableToolBar.barTintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1);
        
        let tablePicker = UIPickerView();
        tablePicker.delegate = self;
        tablePicker.dataSource = self;
        tablePicker.showsSelectionIndicator = true;
        tableText.inputView = tablePicker;
        tableText.inputAccessoryView = tableToolBar;
        tableToolBar.isUserInteractionEnabled = true;
        
        let seatToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44));
        let doneButton2 = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(AddGuestViewController.seatPickerPressed));
        seatToolBar.setItems([space, doneButton2], animated: false);
        seatToolBar.barTintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1);
        
        let seatPicker = UIPickerView();
        seatPicker.delegate = self;
        seatPicker.dataSource = self;
        seatPicker.showsSelectionIndicator = true;
        seatText.inputView = seatPicker;
        seatText.inputAccessoryView = seatToolBar;
        seatToolBar.isUserInteractionEnabled = true;
        
        // Set text field delegates
        firstNameText.delegate = self;
        lastNameText.delegate = self;
        setSeatLabelsArray();
        
        // Set text fields if loaded in from a GuestViewController
        if (guest != nil) {
            firstNameText.text = guest!.firstName;
            lastNameText.text = guest!.lastName;
            tableText.text = guest!.table?.name;
            chosenTable = guest!.table;
            seatText.text = guest!.getSeatString();
            chosenSeat = guest!.seat;
            tableImageView.table = chosenTable;
            setSeatLabels();
        }
        
        // Set whether the UI objects are enabled
        checkValidName();
        checkTablesAndSeats();
    }
    
    // Hides custom tabBar button if view is pushed
    override func viewWillAppear(_ animated: Bool) {
        if beingPushed {
            (tabBarController as! TabBarController).hideCenterButton(true);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 2;
        }else {
            let seats = chosenTable?.numOfSeats ?? 0;
            return 3 + seats;
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 1) {
            return TitleViewController.footerSize;
        }
        return UITableViewAutomaticDimension;
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Update guest if save button is pressed
        if (segue.destination is GuestTableViewController) {
            // Update Guest instance stats if guest being edited
            if beingPushed {
                tablePlan!.editGuest(guest!, firstName: firstNameText.text!, lastName: lastNameText.text!, table: chosenTable, seat: chosenSeat);
            
                // Create new Guest instance if a guest is being added
            }else {
                guest = Guest(firstName: firstNameText.text!, lastName: lastNameText.text!, table: chosenTable, seat: nil);
                chosenSeat?.seatGuest(guest);
            }
        
        }else if let navViewController = segue.destination as? UINavigationController {
            // Pass on tablePlan to guest picker if an add guest constraint button is pressed
            if let destinationViewController = navViewController.topViewController as? GuestPickerViewController {
                destinationViewController.tablePlan = tablePlan;
                destinationViewController.addingConstraint = true;
            }
        }
    }
    
    //MARK: - Button Actions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        if (beingPushed) {
            _ = navigationController?.popViewController(animated: true);
        }else {
            dismiss(animated: true, completion: nil);
        }
    }
    
    //MARK: - UIPickerView DataSource/Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == tableText.inputView) {
            return tablePlan!.tableList.count + 2;
        }else if (pickerView == seatText.inputView) {
            return chosenTable!.seats.count + 2;
        }
        return 0;
    }
    
    // Helper function that disables the table text field and/or the seat text field if there are tables to choose from and a chosen table
    func checkTablesAndSeats() {
        tableText.isEnabled = !tablePlan!.tableList.isEmpty;
        if (chosenTable == nil) {
            seatText.isEnabled = false;
            seatText.text = nil;
        }else {
            seatText.isEnabled = true;
        }
    }
    
    // Assign the title for each item in the picker view
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (row == 0) {
            return "";
        }
        if (pickerView == tableText.inputView) {
            if (row == 1) {
                return "**No Table**";
            }
            return tablePlan!.tableList[row-2].name;
        }else if (pickerView == seatText.inputView) {
            if (row == 1) {
                return "**No Seat**";
            }
            return String(chosenTable!.seats[row-2].seatNumOfTable + 1);
        }
        return "Empty";
    }
    
    // When an item is selected, change text of the corresponding text view and store the table or seat
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (row == 0) {
            //Do Nothing
        }else if (pickerView == tableText.inputView) {
            if (row == 1) {
                chosenTable = nil;
            }else {
                chosenTable = tablePlan!.tableList[row-2];
            }
            //Reset seat placement
            chosenSeat = nil;
            seatText.text = nil;
        }else if (pickerView == seatText.inputView) {
            if (row == 1) {
                chosenSeat = nil;
            }else {
                chosenSeat = chosenTable!.seats[row-2];
            }
        }
    }
    
    // Sets the tabletext field to the chosen table and dismisses the picker
    func tablePickerPressed() {
        tableText.text = chosenTable?.name;
        checkTablesAndSeats();
        tableText.resignFirstResponder();
        tableImageView.table = chosenTable;
        tableImageView.setNeedsDisplay();
        tableView.reloadData();
        setSeatLabels();
    }
    
    // Sets the seattext field to the chosen seat and dismisses the picker
    func seatPickerPressed() {
        if chosenSeat == nil {
            seatText.text = nil;
        }else {
            seatText.text = String(chosenSeat!.seatNumOfTable + 1);
        }
        seatText.resignFirstResponder();
    }
    
    //MARK: - UITextFieldDelegate
    
    //Enables or disables the save button if the first and last name text field is empty/filled
    func checkValidName() {
        let firstName = firstNameText.text ?? "";
        let lastName = lastNameText.text ?? "";
        saveButton.isEnabled = !firstName.isEmpty && !lastName.isEmpty;
    }
    
    //Hides the keyboard if return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    //Enables or disables the save button depending on the state of the first and last name text field
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidName();
    }
    
    //Enables or disables save button depending on the state of the name text fields while editing is occurring
    @IBAction func textChanged(_ sender: UITextField) {
        checkValidName();
    }
    
    //MARK: - Seat Label Junk
    
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
        if (chosenTable != nil) {
            for (index, label) in labelArray.enumerated() {
                if (index < chosenTable!.numOfSeats) {
                    let seatedGuest = chosenTable!.seats[index].guestSeated;
                    label.text = seatedGuest?.getFullName(.FirstName);
                }
            }
        }
    }
    
}
