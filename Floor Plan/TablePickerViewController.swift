//
//  TablePickerViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 6/29/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class TablePickerViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    // MARK: Properties
    
    var searchController: UISearchController!;
    var tablePlan: TablePlan!;
    var unplacedTables: [Table] = [Table]();
    var filteredTables: [Table] = [Table]();
    var chosenTable: Table!;
    
    var cancelButton: UIBarButtonItem!;
    
    
    
    
    // MARK: - View Prep
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up search bar
        searchController = UISearchController(searchResultsController: nil);
        searchController.dimsBackgroundDuringPresentation = false;
        searchController.searchResultsUpdater = self;
        definesPresentationContext = true;
        searchController.hidesNavigationBarDuringPresentation = false;
        searchController.searchBar.delegate = self;
        navigationItem.titleView = searchController.searchBar;
        (searchController.searchBar.value(forKey: "searchField") as? UITextField)?.placeholder = "Search Tables";
        
        
        // Filter tables to only show unplaced ones
        unplacedTables = tablePlan.tableList.filter { table in
            return !table.isPlaced();
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Search Controller
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        cancelButton = navigationItem.rightBarButtonItem;
        navigationItem.setRightBarButton(nil, animated: true);
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        navigationItem.setRightBarButton(cancelButton, animated: true);
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!);
    }
    
    
    fileprivate func filterContentForSearchText(_ searchText: String) {
        filteredTables = unplacedTables.filter { table in
            return table.name.lowercased().contains(searchText.lowercased());
        }
        tableView.reloadData();
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredTables.count;
        }
        return unplacedTables.count;
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TablePickerCell", for: indexPath) as! TablePickerTableViewCell;
            
        // Set table if search has been conducted
        let table: Table;
        if (searchController.isActive && searchController.searchBar.text != "") {
            table = filteredTables[(indexPath as NSIndexPath).row];
            
            // Set table if search has NOT been conducted
        }else {
            table = unplacedTables[(indexPath as NSIndexPath).row];
        }
        
        // Configure the cell
        cell.tableNameLabel.text = table.name;
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Set chosenTable to appropriate table if search has been conducted
        if (searchController.isActive && searchController.searchBar.text != "") {
            chosenTable = filteredTables[(indexPath as NSIndexPath).row];
            
        // set chosenTable if search has NOT been conducted
        }else {
            chosenTable = unplacedTables[(indexPath as NSIndexPath).row];
        }
        
        performSegue(withIdentifier: "TableChosenSegue", sender: self);
    }
    
    
    
    // MARK: - Button Actions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil);
    }
    
    
    
    // MARK: - Deallocation
    
    deinit{
        searchController.view.removeFromSuperview();
    }
    
}
