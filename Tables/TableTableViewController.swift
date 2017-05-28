//
//  TableTableViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/24/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class TableTableViewController: UITableViewController {

    // MARK: Properties
    @IBOutlet weak var tableCount: UILabel!
    @IBOutlet weak var unseatedCount: UILabel!
    
    var tablePlan : TablePlan!;
    
    // MARK: View Prep
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Retrieve table plan from TabBarController and update counts
        let tabBarController = self.tabBarController as! TabBarController;
        tablePlan = tabBarController.tablePlan;
        updateCounts();

        // Load in the edit button on the nav bar
        navigationItem.leftBarButtonItem = editButtonItem;
    }
    
    // Unhides custom tabBar button and relaods table data
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData();
        (tabBarController as! TabBarController).showCenterButton(true);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true);
        }
        updateCounts();
    }
    
    func updateCounts() {
        tableCount.text = String(tablePlan.tableList.count);
        unseatedCount.text = String(tablePlan.unseated);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tablePlan.tableList.count;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let table = tablePlan.tableList[section];
        if table.open {
            return 2 + table.numOfSeats;
        }
        return 1;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table Name Cell
        if ((indexPath as NSIndexPath).row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableTableViewCell;
            let table = tablePlan.tableList[(indexPath as NSIndexPath).section];
            cell.tableName.text = table.name;
            cell.openTableButton.cell = cell;
            cell.openTableButton.isSelected = table.open;
            cell.groupName.text = table.tableGroup ?? "No Group";
            cell.seatedLabel.text = table.takenSeats().description + "/" + table.seats.count.description + " Seated";
            return cell;
            
        // Table Image Cell
        }else if ((indexPath as NSIndexPath).row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableImageCell", for: indexPath) as! TableImageTableViewCell;
            cell.tableImageView.table = tablePlan.tableList[(indexPath as NSIndexPath).section];
            cell.tableImageView.setNeedsDisplay();
            return cell;
            
        // Table Seat Cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeatCell", for: indexPath) as! SeatTableViewCell;
            cell.seatNumberLabel.text = String((indexPath as NSIndexPath).row - 1) + " -";
            let guest = tablePlan.tableList[(indexPath as NSIndexPath).section].seats[(indexPath as NSIndexPath).row-2].guestSeated;
            cell.seatGuestLabel.text = guest?.getFullName(.FirstName) ?? "";
            return cell;
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((indexPath as NSIndexPath).row == 0) {
            return 54;
        }
        if ((indexPath as NSIndexPath).row == 1) {
            return 200;
        }else {
            return 28;
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0;
        }
        return 2;
    }
    
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == tablePlan.tableList.count - 1) {
            return TitleViewController.footerSize;
        }
        return 2;
    }
    

    // Allows only the first row of each section (the table name cell) to be edited
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if ((indexPath as NSIndexPath).row == 0) {
            return true;
        }
        return false;
    }
    

    // Deletes a table and its row if the table is chosen to be deleted
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tablePlan.tableList[(indexPath as NSIndexPath).section].unplaceTable();
            tablePlan.removeTable((indexPath as NSIndexPath).section);
            tableView.deleteSections(IndexSet(integer: (indexPath as NSIndexPath).section), with: .fade);
            updateCounts();
            tablePlan.sortGuests();
            (tabBarController as! TabBarController).savePlans();
        }
    }
    
    
    

    // MARK: - Navigation

    // If a cell is clicked, prepares the table view with the table's info
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? TableViewController {
            let cell = sender as! TableTableViewCell;
            let indexPath = tableView.indexPath(for: cell)!;
            let table = tablePlan.tableList[(indexPath as NSIndexPath).section];
            destinationViewController.table = table;
            destinationViewController.tablePlan = tablePlan;
      
            
    // If "Add Table" is clicked, transfer over the current tablePlan to the new view controller
        }else if let navViewController = segue.destination as? UINavigationController {
            if let destinationViewController = navViewController.topViewController as? TableAddViewController {
                destinationViewController.tablePlan = tablePlan;
                destinationViewController.navigationItem.title = "Add Table";
            }
        }
    }
    
    
    @IBAction func unwindToTableTable(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? TableAddViewController, let table = sourceViewController.table {
            
            // Reload data if unwinded from an edited table
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tablePlan.tableList[(selectedIndexPath as NSIndexPath).section] = table;
                tablePlan.tableList.sort(by: Table.sortByName);
                tablePlan.sortGuests();
                tableView.reloadData();
                
            // Add table and reload data if unwinded from an added table
            }else {
                tablePlan.addTable(table);
                tablePlan.tableList.sort(by: Table.sortByName);
                tableView.reloadData();
            }
        }
        (tabBarController as! TabBarController).savePlans();
    }
    
    
    
    // MARK: - Button Actions
    
    @IBAction func openTable(_ sender: TableButton) {
        let cell = sender.cell!;
        let cellSection = (tableView.indexPath(for: cell)! as NSIndexPath).section;
        var cellIndexPaths = [IndexPath]();
        let table = tablePlan.tableList[cellSection];
        let rowsToAdd = table.numOfSeats + 1;
        for row in 1...rowsToAdd {
            cellIndexPaths += [IndexPath(row: row, section: cellSection)];
        }
        if (table.open) {
            table.open = false;
            tableView.deleteRows(at: cellIndexPaths, with: .top);
        }else {
            table.open = true;
            tableView.insertRows(at: cellIndexPaths, with: .top);
        }
        cell.openTableButton.isSelected = table.open;
    }
    

}
