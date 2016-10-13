//
//  TableAddViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 6/3/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class TableAddViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var tableNameField: UITextField!
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var tableTypeField: UITextField!
    @IBOutlet weak var seatCount: UILabel!
    @IBOutlet weak var seatCountStepper: UIStepper!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var tableImageView: TableImageView!
    
    var tablePlan : TablePlan? = nil;
    var table : Table? = nil;
    var beingPushed = false; //True if view is being pushed, false if otherwise
    
    var tableType : Table.TableType = .round;
    var numOfSeats : Int = 4;
    var chosenGroup : String? = nil;
    
    // MARK: - View Prep
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create picker views with a toolbar and set their delegate and datasource
        let screenWidth = view.bounds.size.width;
        
        let groupToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44));
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(TableAddViewController.groupPickerPressed));
        doneButton.tintColor = UIColor.blue;
        groupToolBar.setItems([space, doneButton], animated: false);
        groupToolBar.barTintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1);
        
        let groupPicker = UIPickerView(frame: CGRect(x: 0, y: groupToolBar.frame.size.height, width: screenWidth, height: 200));
        groupPicker.delegate = self;
        groupPicker.dataSource = self;
        groupPicker.showsSelectionIndicator = true;
        groupNameField.inputView = groupPicker;
        groupNameField.inputAccessoryView = groupToolBar;
        groupToolBar.isUserInteractionEnabled = true;
        
        let typeToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44));
        let doneButton2 = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(TableAddViewController.typePickerPressed));
        doneButton2.tintColor = UIColor.blue;
        typeToolBar.setItems([space, doneButton2], animated: false);
        typeToolBar.barTintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1);
        
        let tableTypePicker = UIPickerView(frame: CGRect(x: 0, y: typeToolBar.frame.size.height, width: screenWidth, height: 200));
        tableTypePicker.delegate = self;
        tableTypePicker.dataSource = self;
        tableTypePicker.showsSelectionIndicator = true;
        tableTypeField.inputView = tableTypePicker;
        tableTypeField.inputAccessoryView = typeToolBar;
        typeToolBar.isUserInteractionEnabled = true;
        
        // Set text field delegates
        tableNameField.delegate = self;
        
        // Set fields if loaded from TableViewController
        if (table != nil) {
            tableType = table!.tableType;
            numOfSeats = table!.numOfSeats;
            tableNameField.text = table!.name;
            chosenGroup = table!.tableGroup;
            groupNameField.text = table!.tableGroup;
            seatCount.text = "[" + String(numOfSeats) + "]";
            setStepperDefaults(tableType);
            seatCountStepper.value = Double(numOfSeats);
            tableImageView.table = Table(name: "Placeholder", tableType: tableType, numOfSeats: numOfSeats, tableGroup: nil, plan: tablePlan!);
            
        // Set fields to default if not loaded
        }else {
            seatCount.text = "[4]";
            seatCountStepper.value = 4.0;
            tableImageView.table = Table(name: "Placeholder", tableType: tableType, numOfSeats: numOfSeats, tableGroup: nil, plan: tablePlan!);
        }
        tableTypeField.text = tableType.rawValue;
        
        // Set whether the UI objects are enabled
        checkValidName();
        checkTableGroupNames();
    }
    
    // Hides custom tabBar button if view is pushed
    override func viewWillAppear(_ animated: Bool) {
        if beingPushed {
            (tabBarController as! TabBarController).hideCenterButton(true);
        }
    }
    
    override func viewDidLayoutSubviews() {
        tableImageView.setNeedsLayout();
    }
    
    // Helper func that sets the minimum value for the stepper based off of the table type
    fileprivate func setStepperDefaults(_ type : Table.TableType) {
        if (type == .twoSidedRect) {
            seatCountStepper.minimumValue = 2;
            seatCountStepper.maximumValue = 20;
            
        }else if (type == .oneSidedRect) {
            seatCountStepper.minimumValue = 2;
            if (seatCountStepper.value > 10) {
                seatCount.text = "[10]";
            }
            seatCountStepper.maximumValue = 10;
            
        }else if (type == .round) {
            if (seatCountStepper.value < 4) {
                seatCount.text = "[4]";
            }
            seatCountStepper.minimumValue = 4;
            if (seatCountStepper.value > 12) {
                seatCount.text = "[12]";
            }
            seatCountStepper.maximumValue = 12;
            
        }else {
            if (seatCountStepper.value < 4) {
                seatCount.text = "[4]";
            }
            seatCountStepper.minimumValue = 4;
            seatCountStepper.maximumValue = 20;
        }
        
        //If tableview already loaded, redraws it incase there was a stepper change
        if (tableImageView.table != nil) {
            stepperChanged(seatCountStepper);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if beingPushed {
            table!.name = tableNameField.text!;
            table!.tableGroup = chosenGroup;
            table!.changeSeats(numOfSeats);
            table!.tableType = tableType;
            table!.edited = true;
        }else {
            table = Table(name: tableNameField.text!, tableType: tableType, numOfSeats: numOfSeats, tableGroup: chosenGroup, plan: tablePlan!);
        }
    }
    
    
    
    // MARK: - Button Actions
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        let seatNumber = Int(sender.value);
        let stringValue = "[" + String(seatNumber) + "]";
        seatCount.text = stringValue;
        numOfSeats = seatNumber;
        tableImageView.table!.changeSeats(numOfSeats);
        tableImageView.setNeedsDisplay();
    }
    
    
    @IBAction func closePressed(_ sender: UIBarButtonItem) {
        if beingPushed {
            _ = navigationController?.popViewController(animated: true);
        }else {
            dismiss(animated: true, completion: nil);
        }
    }
    
    
    // Call a UIAlertController asking for a group name, then add to group list if add is selected
    @IBAction func addGroup(_ sender: UIButton) {
        // Create UIAlertController
        let alertController = UIAlertController(title: nil, message: "Enter New Group Name:", preferredStyle: .alert);
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
        let addGroupAction = UIAlertAction(title: "Add", style: .default) { (_) in
            let groupName = alertController.textFields![0].text!;
            self.tablePlan!.tableGroupList.append(groupName);
            self.checkTableGroupNames();
            let picker = self.groupNameField.inputView as! UIPickerView;
            let row = self.tablePlan!.tableGroupList.count + 1;
            picker.reloadAllComponents();
            
            // Simulates a user selecting the row of the newly added group
            picker.selectRow(row, inComponent: 0, animated: false);
            self.pickerView(picker, didSelectRow: row, inComponent: 0);
            self.groupPickerPressed();
            (self.tabBarController as! TabBarController).savePlans();
        }
        addGroupAction.isEnabled = false;
        alertController.addTextField {(textField) in
            textField.placeholder = "Group Name"
            textField.autocapitalizationType = .words;
            textField.autocorrectionType = .no;
            textField.spellCheckingType = .no;
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (_) in
                addGroupAction.isEnabled = (textField.text != "");
            }
        }
        alertController.addAction(cancelAction);
        alertController.addAction(addGroupAction);
        
        present(alertController, animated: true, completion: nil);
    }
    
    
    
    // MARK: - UIPickerView DataSource/Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == groupNameField.inputView) {
            return tablePlan!.tableGroupList.count + 2;
        }else if (pickerView == tableTypeField.inputView) {
            return 5;
        }
        return 0;
    }
    
    
    func checkTableGroupNames() {
        groupNameField.isEnabled = !tablePlan!.tableGroupList.isEmpty;
    }
    
    
    // Assign the title for each itme in the picker view
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (row == 0) {
            return "";
        }
        
        if (pickerView == groupNameField.inputView) {
            if (row == 1) {
                return "**No Group**";
            }
            return tablePlan!.tableGroupList[row - 2];
        }else if (pickerView == tableTypeField.inputView) {
            return Table.tableTypeList[row-1].rawValue;
        }
        return "Empty";
    }
    
    
    // When an item is selected, change text of corresponding text view and store the group name
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (row == 0) {
            //Do nothing
        }else if (pickerView == groupNameField.inputView) {
            if (row == 1) {
                chosenGroup = nil;
            }else {
                chosenGroup = tablePlan!.tableGroupList[row-2];
            }
        }else if (pickerView == tableTypeField.inputView) {
            tableType = Table.tableTypeList[row-1];
        }
    }
    
    
    // Closes a group picker view when Done is tapped
    func groupPickerPressed() {
        groupNameField.text = chosenGroup;
        groupNameField.resignFirstResponder();
    }
    
    
    // Closes a type picker view when Done is tapped
    func typePickerPressed() {
        tableTypeField.text = tableType.rawValue;
        setStepperDefaults(tableType);
        tableImageView.table?.tableType = tableType;
        tableImageView.setNeedsDisplay();
        tableTypeField.resignFirstResponder()
    }
    
    

    // MARK: - UITextFieldDelegate
    
    //Enables or disables the save button based on if a valid table name is entered
    fileprivate func checkValidName() {
        let tableName = tableNameField.text ?? "";
        saveButton.isEnabled = !tableName.isEmpty;
    }
    
    
    //Hides the keyboard if return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    
    //Enables or disables the save button depending on the state of the name text field when editing is finished
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidName();
    }
    
    
    //Enables or disables save button depending on the state of the name text field while editing is occurring
    @IBAction func tableNameChanged(_ sender: UITextField) {
        checkValidName();
    }
}
