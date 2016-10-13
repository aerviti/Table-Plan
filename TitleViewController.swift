//
//  ViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/20/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {

    //MARK: Properties
    @IBOutlet weak var titleTable: UITableView!; //Table View embedded in this controller
    
    var tablePlans = [TablePlan](); //Array of table plans
    
    //Future iCloud support
    //var tablePlanDocument = TablePlanDocument(fileURL: TablePlan.ArchiveURL); //Document that will load/save data
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set navigation bar defaults
        let defaultColor: UIColor = UIColor.white;
        let disabledColor: UIColor = UIColor.white.withAlphaComponent(0.4);
        let defaultTitleFont: UIFont = UIFont.systemFont(ofSize: 17, weight: UIFontWeightHeavy);
        let defaultNavFont: UIFont = UIFont(name: "HelveticaNeue-Medium", size: 15.0)!;
        let attributes = [NSForegroundColorAttributeName: defaultColor, NSFontAttributeName: defaultTitleFont];
        let barAttributes = [NSForegroundColorAttributeName: defaultColor, NSFontAttributeName: defaultNavFont];
        let barSelectedAttributes = [NSForegroundColorAttributeName: disabledColor, NSFontAttributeName: defaultNavFont];
        UINavigationBar.appearance().barTintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1);
        UINavigationBar.appearance().tintColor = UIColor.white;
        UINavigationBar.appearance().titleTextAttributes = attributes;
        UIBarButtonItem.appearance().setTitleTextAttributes(barAttributes, for: UIControlState());
        UIBarButtonItem.appearance().setTitleTextAttributes(barSelectedAttributes, for: .disabled);
        
        // Assign embedded table view's delegate and data source.
        titleTable.delegate = self;
        titleTable.dataSource = self;
        
        //Load table plans
        if let savedPlans = loadTablePlans() {
            tablePlans += savedPlans;
        }
        
        // Test loading
        //else {
        //    tablePlans += loadTestPlans();
        //}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let indexPath = titleTable.indexPathForSelectedRow {
            titleTable.deselectRow(at: indexPath, animated: true);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableViewDataSource
    
    // Sets the one section needed for the table view.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Sets the count of cells to the number of table plans.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tablePlans.count;
    }
    
    // Formats each cell where the row of the cell corresponds with the index of the plan in tablePlans.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "TitleTableViewCell";
        let cell = titleTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TitleTableViewCell;
        let plan = tablePlans[(indexPath as NSIndexPath).row];
        cell.nameLabel.text = plan.name;
        cell.dateLabel.text = plan.date;
        cell.backgroundColor = cell.contentView.backgroundColor;
        return cell;
    }
    
    //MARK: - Navigation
    
    @IBAction func unwindToTitle(_ sender: UIStoryboardSegue) {
        // If unwinded from AddPlanViewController, add plan to tablePlans array and to the tableview
        if let sourceViewController = sender.source as? AddPlanViewController, let tablePlan = sourceViewController.tablePlan {
            let newIndexPath = IndexPath(row: tablePlans.count, section: 0);
            tablePlans.append(tablePlan);
            titleTable.insertRows(at: [newIndexPath], with: .bottom);
        
        // If unwinded from the delete tableplan option, delete the plan from the array and tableview
        }else if (sender.identifier == "DeletePlanSegue") {
            let sourceViewController = sender.source as! SettingsTableViewController;
            let indexPath = sourceViewController.indexPath;
            tablePlans.remove(at: (indexPath! as NSIndexPath).row);
            titleTable.deleteRows(at: [indexPath! as IndexPath], with: .automatic);
        }
        saveTablePlans();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If a cell is clicked, configure the destination controller with the appropriate data
        if segue.identifier == "OpenTablePlan" {
            let tabBarController = segue.destination as! TabBarController;
            if let selectedPlanCell = sender as? TitleTableViewCell {
                let index = titleTable.indexPath(for: selectedPlanCell)!;
                tabBarController.tablePlan = tablePlans[(index as NSIndexPath).row];
                tabBarController.planIndexPath = index;
                tabBarController.tablePlans = tablePlans;
            }
        }
    }
    
    //MARK: - NSCoding
    
    //Saves the current set of table plans
    func saveTablePlans() {
        let successfulSave = NSKeyedArchiver.archiveRootObject(tablePlans, toFile: TablePlan.ArchiveURL.path);
        if !successfulSave {
            print("Save error...");
        }
    }
    
    //Loads the saved set of table plans
    func loadTablePlans() -> [TablePlan]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: TablePlan.ArchiveURL.path) as? [TablePlan];
    }
    
    
    
    
     /*
     
    // MARK: - TESTING
    
    func loadTestPlans() -> [TablePlan] {
        let tablePlan = TablePlan(name: "Test Plan", date: "Month Day, Year");
        tablePlan.tableGroupList.append("Family");
        tablePlan.tableGroupList.append("Friends");
        for guest in testGuests() {
            tablePlan.addGuest(guest);
        }
        tablePlan.sortGuests();
        for table in testTables(tablePlan) {
            tablePlan.addTable(table);
        }
        tablePlan.tableList.sort(by: Table.sortByName);
        return [tablePlan];
    }
    
    func testGuests() -> [Guest] {
        var guestArray = [Guest]();
        let guests = guestNames.characters.split(separator: ",").map(String.init);
        for guest in guests {
            let names = guest.characters.split(separator: " ").map(String.init);
            if (names.count > 1) {
                guestArray += [Guest(firstName: names[0], lastName: names[1], table: nil, seat: nil)];
            }
        }
        return guestArray;
    }
    
    func testTables(_ tablePlan: TablePlan) -> [Table] {
        var tableArray = [Table]();
        let tables = tableNames.characters.split(separator: ",").map(String.init);
        for table in tables {
            let parts = table.characters.split(separator: " ").map(String.init);
            tableArray += [Table(name: parts[0], tableType: tableType(parts[1]), numOfSeats: Int(parts[2])!, tableGroup: parts[3], plan: tablePlan)];
        }
        return tableArray;
    }
    
    func tableType(_ str: String) -> Table.TableType {
        switch(str) {
            case "Round": return Table.TableType.round;
            case "Oval": return Table.TableType.oval;
            case "Rect-One": return Table.TableType.oneSidedRect;
            default: return Table.TableType.twoSidedRect;
        }
    }
    
    let tableNames = "Wedding_Table Rect-One 10 Family, Family1 Round 10 Family, Family2 Round 10 Family, Family3 Round 10 Family, Family4 Round 10 Family, Family5 Round 10 Family, Family6 Round 10 Family, Family7 Round 10 Family, Family8 Round 10 Family, Family9 Round 10 Family, Family10 Round 10 Family, Family11 Round 10 Family, Friends1 Oval 12 Friends, Friends2 Oval 12 Friends, Friends3 Oval 12 Friends, Friends4 Oval 12 Friends, Friends5 Oval 12 Friends, Friends6 Oval 12 Friends, Friends7 Oval 12 Friends, Friends8 Oval 12 Friends, Friends9 Oval 12 Friends, Friends10 Oval 12 Friends, Friends11 Oval 12 Friends, Friends12 Oval 12 Friends, Friends13 Oval 12 Friends, Friends14 Oval 12 Friends, Friends15 Oval 12 Friends"
    
    let guestNames = "Rose Andrews, Amy Turner, Richard Howard, Judy Stewart, Wanda Ryan, John Gilbert, Lillian Nichols, Elizabeth Lee, Ernest Morgan, Lisa Vasquez, Gregory Thompson, Philip Rogers, Jacqueline Shaw, Jose Simmons, Tammy Hamilton, Linda Miller, Carol Morgan, Raymond Howard, Judy Rice, Ernest Daniels, Harry Jackson, Judy Richardson, Rebecca Holmes, Russell Clark, Lawrence Allen, Jessica Marshall, Walter Jacobs, Rose Wallace, Laura Chapman, Chris Marshall, Christina Hughes, Patrick Simpson, Lisa Rodriguez, Christine Nelson, Debra Olson, Tammy Rice, Albert Lynch, James Harrison, Keith Dunn, Karen Elliott, Irene Vasquez, Edward Weaver, Cynthia Gonzales, Michelle Oliver, Arthur Henry, Jessica Powell, Arthur Green, Jonathan Little, Robin Brooks, Howard Reid, Andrea Wright, Ruth Fernandez, Paul Baker, Willie Meyer, Denise Hunter, Margaret King, Kelly Perez, Alan Lynch, Stephanie Torres, Sara Garcia, Kelly Torres, Larry Arnold, Cheryl Ramos, Jessica Hernandez, Betty Walker, Dennis Reyes, Anna Larson, Beverly Hall, Teresa Stone, Anne Grant, Lisa Frazier, Maria Campbell, Jacqueline Hudson, Walter Porter, Mary Wright, Christopher Webb, Rebecca Riley, Adam Wallace, Henry Mcdonald, Douglas Bradley, Johnny Torres, John Richards, Carl Brown, Earl Willis, Larry Long, Albert Woods, John Barnes, Lillian Hawkins, Christine Simpson, Sandra Roberts, Sandra Reid, Helen Mccoy, Jeffrey Flores, Sara Fernandez, Melissa Wagner, Deborah Bowman, Aaron Fields, Eugene Ross, Walter Lane, Sarah Hanson, Samuel Stanley, Deborah Burton, Ann Hunt, Judy Turner, Ryan Williamson, Theresa Harvey, Antonio Harris, Lois Myers, Beverly Brooks, Roy Duncan, Mary Bailey, Harold Spencer, Mark Ward, Nicole Webb, Jane Olson, Adam Morris, Julie Johnson, Shawn Reynolds, Jessica Mills, Alice Collins, Antonio Bryant, Anna Myers, Ruby Gordon, Sandra Schmidt, Ruth Bowman, Rachel Reyes, Todd Hall, Mildred Cole, John Pierce, Thomas Hall, Lillian West, Kelly Carter, Catherine Reynolds, Mildred Burton, Patricia Franklin, Norma Watkins, Christopher Myers, Michael Hamilton, Justin Foster, Russell Thompson, Marilyn Andrews, Larry Ross, Karen Woods, Pamela Perez, Keith Payne, Alice Kim, Matthew Ward, Joyce Garza, Irene Henry, Robert Snyder, Theresa Woods, Michelle Russell, Jean Harrison, Frank Nguyen, William Carpenter, Robert Gonzalez, Willie Harper, Kenneth Jacobs, Raymond Long, Karen Mccoy, Jonathan Thomas, Juan Long, Jack Johnston, Louis Diaz, Paul Garcia, Sara Jenkins, Theresa Ryan, Heather Butler, Terry Martinez, Charles Wright, Anne Chapman, Fred Gomez, Alan Chapman, Benjamin Schmidt, George Gutierrez, Willie Ortiz, Jesse Phillips, Louis Johnson, Philip Ferguson, Wayne Henry, Jerry Burke, Paula Cooper, Victor Nguyen, Jean Rogers, Kimberly Bailey, Marilyn Bradley, Harry Brooks, Rose Roberts, Gloria Gilbert, Johnny Robinson, Cynthia Berry, Ernest Gordon, Emily Harrison, Diana Scott, Frances Griffin, Brandon Simmons, Johnny Murphy, Debra Mcdonald, Philip Rivera, Billy Elliott, Beverly Medina, Beverly Ford, Robin Meyer, Steve Edwards, Jose Lee, Kelly Reynolds, Bonnie Shaw, Mildred Mason, Harold Knight, Gregory Day, Catherine Turner, Gregory Gilbert, Walter Hernandez, Stephen Perry, Ann Bryant, Judith Reynolds, Stephanie Boyd, Deborah Franklin, Howard Greene, Irene Sims, Nicole Murphy, Paula Thomas, Peter Allen, Sara Rodriguez, Janice Hunter, Melissa Murray, Jeffrey Campbell, Joshua Myers, Ronald Porter, Carl Chapman, Diane Richardson, Louise Price, Mildred Gonzales, Karen Hudson, Linda Wood, Stephen Campbell, Jacqueline Ortiz, William Morrison, Joseph Bradley, Christine Hanson, Ashley Fox, Wanda Bryant, Aaron Hall, David Webb, Billy Cooper, Amy James, Billy Little, Antonio Roberts, Sara Morrison, Philip Thompson, Diane Ferguson, Benjamin Shaw, Eugene Grant, Jane Cooper, Ashley Campbell, Lois Ward, Anna Greene, Judith Arnold, Frances Ruiz, Ralph Mendoza, Betty Simmons, Steve Franklin, Kathryn Weaver, Brian Hudson, Carlos Reid, Phyllis Cunningham, Marie Collins, Jason Romero, Matthew Sims, Dennis Cole, Charles Ortiz, Raymond Rodriguez, George Fisher, Victor Fisher, Virginia Burns, Jessica Mills, Michael Lopez, Louis Mendoza, Richard Butler, Jose Hudson, Terry King, Ashley Little, Laura Frazier, Bonnie Johnston, Jerry Jones, Roger Bryant, Jack Foster, Jennifer Warren, Gregory Carpenter, Paula Harrison, Heather Washington, Anna Webb, Gerald Walker, Sara Roberts, Jose Stevens, Jonathan Larson, Ann Howard, Daniel Bailey, Joyce Ryan, Kathleen Kim"
 
      */
}

