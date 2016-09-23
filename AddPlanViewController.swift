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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up delegates and disable save button.
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
        if let sender = (sender as? UIBarButtonItem), saveButton === sender {
            let name = nameEntry.text ?? "";
            let dateFormatter = DateFormatter();
            dateFormatter.dateStyle = .medium;
            let date = dateFormatter.string(from: dateEntry.date);
            tablePlan = TablePlan(name: name, date: date);
        }
    }
    
    
    //MARK: - Actions
    
    @IBAction func cancelPlan(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil);
    }

}
