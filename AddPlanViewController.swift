//
//  AddPlanViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/22/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class AddPlanViewController: UIViewController, UINavigationBarDelegate, UITextFieldDelegate {
    
    
    //MARK: Properties
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var nameEntry: UITextField!
    @IBOutlet weak var dateEntry: UIDatePicker!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var tablePlan: TablePlan? = nil; //Table Plan to be transfered
    var seguedFromSettings: Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up fields if loaded in from settings page
        if (seguedFromSettings && tablePlan != nil) {
            nameEntry.text = tablePlan!.name;
            let dateFormatter = DateFormatter();
            dateFormatter.dateFormat = "MMM d, yyyy";
            if let date = dateFormatter.date(from: tablePlan!.date) {
                dateEntry.setDate(date, animated: false);
            }
        }
        
        // Set up delegates and disable/enable save button.
        navigationBar.delegate = self;
        nameEntry.delegate = self;
        checkValidName();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - UITextFieldDelegate
    
    //Disable the save button if the text field is empty.
    func checkValidName() {
        let text = nameEntry.text ?? "";
        saveButton.isEnabled = !text.isEmpty;
    }
    
    //Hide the keyboard if return is tapped.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    //Hide the keyboard if a tap is registered outside of the keyboard.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameEntry.resignFirstResponder();
        super.touchesBegan(touches, with: event);
    }
    
    //When finished editing, if the name is valid enable the save button.
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidName();
    }
    
    //Check if there is a valid name when text in the text field is changed
    @IBAction func textChanged(_ sender: UITextField) {
        checkValidName();
    }
    
    
    //MARK: - UINavigationBarDelegate
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached;
    }

    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "UnwindAddPlanSegue") {
            let name = nameEntry.text ?? "";
            let dateFormatter = DateFormatter();
            dateFormatter.dateStyle = .medium;
            let date = dateFormatter.string(from: dateEntry.date);
            tablePlan = TablePlan(name: name, date: date);
            
        }else if (segue.identifier == "UnwindEditPlanSegue") {
            let name = nameEntry.text ?? "";
            let dateFormatter = DateFormatter();
            dateFormatter.dateStyle = .medium;
            let date = dateFormatter.string(from: dateEntry.date);
            tablePlan?.name = name;
            tablePlan?.date = date;
        }
    }
    
    
    //MARK: - Actions
    
    @IBAction func savePlan(_ sender: UIBarButtonItem) {
        if seguedFromSettings {
            self.performSegue(withIdentifier: "UnwindEditPlanSegue", sender: sender);
        }else {
            self.performSegue(withIdentifier: "UnwindAddPlanSegue", sender: sender);
        }
    }
    
    @IBAction func cancelPlan(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil);
    }

}
