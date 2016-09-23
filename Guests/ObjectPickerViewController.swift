//
//  ObjectPickerViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 7/23/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class ObjectPickerViewController: UITableViewController {
    
    // MARK: - Properties
    
    var objectType: PickerObject!;
    var guestList: [Guest]!;
    var tableList: [Table]!;
    var groupList: [NSString]!;
    var chosenObject: AnyObject? = nil;
    
    enum PickerObject {
        case guest;
        case table;
        case group;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sort guests by first name
        if (objectType == .guest) {
            guestList.sort(by: Guest.sortByFirstName);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return count of appropriate list
        switch objectType! {
        case .guest: return guestList.count;
        case .table: return tableList.count;
        case .group: return groupList.count;
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectPickerCell", for: indexPath) as! ObjectPickerTableViewCell;
        
        // Configure cell for a guest
        switch objectType! {
        case .guest:
            let guest = guestList[indexPath.row];
            cell.firstNameLabel.text = guest.firstName;
            cell.lastNameLabel.text = guest.lastName;
        
        // Configure cell for a table
        case .table:
            let table = tableList[indexPath.row];
            cell.firstNameLabel.text = table.name;
            cell.lastNameLabel.text = nil;
        
        // Configure cell for a group
        case .group:
            let group = groupList[indexPath.row] as String;
            cell.firstNameLabel.text = group;
            cell.lastNameLabel.text = nil;
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch objectType! {
        case .guest:
            chosenObject = guestList[indexPath.row];
        case .table:
            chosenObject = tableList[indexPath.row];
        case .group:
            chosenObject = groupList[indexPath.row];
        }
        performSegue(withIdentifier: "RemoveConstraintSegue", sender: self);
    }
    
    // MARK: - Button Actions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil);
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
