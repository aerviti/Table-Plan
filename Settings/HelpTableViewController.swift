//
//  HelpTableViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 8/10/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class HelpTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var strings: [[String]]!;
    let titleFont = UIFont.systemFont(ofSize: 20.0, weight: UIFontWeightBold)
    let subtitleFont = UIFont.systemFont(ofSize: 17.0, weight: UIFontWeightMedium);
    let entryFont = UIFont.systemFont(ofSize: 15.0);

    // MARK: - View Prep
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load text into the strings array
        createTextArrays();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return 2;
            case 1: return 6;
            case 2: return 2;
            case 3: return 6;
            default: return 0;
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "helpCell", for: indexPath) as! HelpTableViewCell;
        cell.entryLabel.text = strings[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row];
        
        // Retrieve font that will be used for specific block of text and set it
        if (indexPath as NSIndexPath).row == 0 {
            cell.entryLabel.font = titleFont;
        }else if ((indexPath as NSIndexPath).row % 2 == 0) {
            cell.entryLabel.font = subtitleFont;
        }else {
            cell.entryLabel.font = entryFont;
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Retrieve font that will be used for specific block of text
        let font: UIFont;
        if (indexPath as NSIndexPath).row == 0 {
            font = titleFont;
        }else if ((indexPath as NSIndexPath).row % 2 == 0) {
            font = subtitleFont;
            return 35;
        }else {
            font = entryFont;
        }
        
        // Acquire the height of the text entry given the string and font
        let text = strings[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row];
        let height = getTextViewHeight(text, font);
        return height + 30;
    }
    
    /* Helper function that returns the height which a string would occupy in a label given a String and UIFont. */
    func getTextViewHeight(_ string: String, _ font: UIFont) -> CGFloat {
        let attributes = [NSFontAttributeName: font] ;
        let text = NSMutableAttributedString(string: string, attributes: attributes);
        let width = view.frame.width - 16;
        let size = text.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil);
        return size.height;
    }
    
    
    
    // MARK: - Text Entries
    
    func createTextArrays() {
        var strings: [[String]] = [[String]]();
        strings.append([guestsTitle, guestsEntry]);
        strings.append([tablesTitle,tablesEntry, tablesSubtitleOne,tablesSubentryOne, tablesSubtitleTwo,tablesSubentryTwo]);
        strings.append([floorplanTitle, floorplanEntry]);
        strings.append([sortTitle,sortEntry, sortSubtitleOne,sortSubentryOne, sortSubtitleTwo,sortSubentryTwo]);
        self.strings = strings;
    }
    
    // Guests Tab
    var guestsTitle = "Guests Tab"
    var guestsEntry = "The 'Guests' tab displays all the guests in the current table plan. There are two ways to add guests through the buttons at the top right of the screen. On the right is the 'add guest' button. Clicking this button will open up a new tab where you can enter a name, table, and seat number. On the left is the 'add multiple guests' button. Clicking this button will open up a tab with a text box in which you can enter a list of names to be added. In order to avoid problems, follow the correct format when entering names. Write the firstname, followed by a space, followed by the lastname, followed by a comma and another space. Clicking on a guest cell when at the guests list will open a view of that guest. Here you may add several seating constraints that are ONLY functional when using the auto-seat feature. To learn how to use these constraints please skip to the section on the 'Sort Tab'. \n \n"
        
        + "At the top of the tab below the navigation bar the number of guests and the number of unseated guests are displayed. Also along these numbers is the sort button. Through this button you can sort the guests through four different ways: First Name, Last Name, Unseated (First Name), Unseated (Last Name)."
    
    
    // Tables Tab
    var tablesTitle = "Tables Tab"
    var tablesEntry = "The 'Tables' tab displays all the tables in the current table plan. You can add a table by clicking on the 'add table' button at the top right of the screen. When tables are listed you may click on the blue bracket next to the table name to open up a preview of the table and its seats. Clicking on the bracket again will close this preview. You may also click on the cell containing the table name to display a table view. On this view you may add guests by clicking on the seat number cell displayed below the image of the table."
    
    var tablesSubtitleOne = "- Adding Guests"
    var tablesSubentryOne = "Clicking on a seat number cell will bring up a guest picker displaying all current guests in the table plan. In order to make the seat empty, simply click the first *No Guest* cell. To seat a guest simply click the guest you want to seat. Clicking the search bar will allow you to either search a guest by name, search a guest by whether they are not currently seated, or both."
    
    var tablesSubtitleTwo = "- Adding Groups"
    var tablesSubentryTwo = "Table groups are used to distinguish certain tables from others and are mostly utilized in the sort function. For example, you might want to have a 'Family' table group to distinguish the tables where family will be sitting. To add groups, when editing or adding a table press the blue 'Add Group' button to the right of the Group text field. You will be prompted to enter the name of the new group. To change the tables group, click on the Group text field and select your desired group. You must add at least one group in order to select a group."
    
    
    // Floor Plan Tab
    var floorplanTitle = "Floor Plan Tab"
    var floorplanEntry = "The 'Floor Plan' tab is where you can place and arrange tables to create a floor plan. The addition and manipulation of your tables are done through different gestures. To add a table long press anywhere on the screen where there isn't alredy a table. This will bring up an option to add a table. When a table is added, long press on that table until it turns semi-transparent to move it around the floor plan. To delete, turn, or edit a table, simply tap on it. This tap will bring up a pop-up menu with three buttons. The first button will remove the table from the floor plan, the second will turn the table 90 degrees, and the last button will open up a table view of the tapped table. To increase your floor plan's size and make it scrollable, drag and drop a table to either the right or bottom of the screen. If the table is close or passes the edge of the screen, the size of the floor plan is increased to accomodate the table's new location."
    
    
    // Sort Tab
    var sortTitle = "Sort Tab"
    var sortEntry = "The 'Sort Tab' is where you can automatically sort and seat UNSEATED guests into your alotted tables based on guest constraints. At the top of the screen there are two buttons. clicking the 'Sort' button on the right will create a preview of a table plan given your current guests and tables. To apply this preview to your actual table plan, click the 'Apply Sort' button on the left. However before the 'Sort' button is active all guests MUST NOT have conflicting constraints. There are six different constraints. \n \n"
        
        + "NOTE: The sort feature only applies to unseated guests. Guests that are already seated will not be changed. As such, conflicts may arise with these guests. Please read below to minimize this from occurring."
    
    var sortSubtitleOne = "- Constraints & Conflicts"
    var sortSubentryOne = "Must Sit At Table: Guest will be seated only at this table. Can conflict with Must-Sit-In-Group if the group does not contain this table. Can conflict with Must-Sit-Next-To and Must-Sit-At-Table-Of guests if they are already seated at a table other than this one. Can conflict with Cannot-Sit-Next-To and Cannot-Sit-At-Table-Of guests if they are already seated at this table. \n \n"
    
    + "Must Sit In Group: Guest will be seated only at tables within this table grouping. Can conflict with Must-Sit-At-Table if the table is not within this group. Can conflict with Must-Sit-Next-To and Must-Sit-At-Table-Of guests if they are already seated at a table that is not in this group. \n \n"
    
    + "Must Sit Next To: Guest will be seated next to these guests. There is a max of 2 people for this list. Can conflict internally if both guests are already tabled and further than one empty seat apart. Can conflict with Must-Sit-At-Table if the table is different than one of these guests' table. Can conflict with Must-Sit-In-Group if the group does not contain the table of these guests. Can conflict with Must-Sit-At-Table-Of guests if they are at a different table than these guests. Can conflict with  Cannot-Sit-At-Table-Of guests if they are already seated at the table of these guests. \n \n"
    
    + "Must Sit At Table Of: Guest will be seated at the table of these guests. There is a max of 19 people for this list. Can conflict with Must-Sit-At-Table if the table is different than one of these guests' table. Can conflict with Must-Sit-In-Group if the group does not contain the table of these guests. Can conflict with Must-Sit-Next-To guests if they are at a different table than these guests. Can conflict with Cannot-Sit-Next-To and Cannot-Sit-At-Table-Of guests if they are already seated at the table of these guests. \n \n"
    
    + "Cannot Sit Next To: Guest will not be seated next to these guests. There is a max of 2 people for this list. \n \n"
    
    + "Cannot Sit At Table Of: Guest will not be seated at the table of these guests. Can conflict with Must-Sit-At-Table if the table is the same as one of these guests' table. Can conflict with Must-Sit-Next-To and Must-Sit-At-Table-Of guests if they are seated at the table of any of these guests."
    
    var sortSubtitleTwo = "- Failed Sorts"
    var sortSubentryTwo = "If a sort has failed there may be other conflicts occurring across multiple guests or there are simply too many constraints for the sorter to handle. The following are some potential reasons a sort has failed: \n \n"
    
    + "- There are fewer empty seats across all tables than unseated guests. All guests must be seated for a successful sort to occur. \n"
    + "- A guest's must-sit-at-table-of constraint has more guests than the size of the average table. For example, if there are 12 people in a tabling constraint and all the tables in the current plan only have 10 seats, the constraint can't be fulfilled. \n"
    + "- There is overlapping between guests' constraints that ultimately make them all impossible to satisfy. For example, while there may be an empty table with 12 seats to accomodate a 12 person tabling constraint, other guests outside of that constraint might have a must-sit-at-table constraint for that same 12 person table. This means 13 or more guests must sit there but that is not possible. \n"
    + "- A constraint may seem to be fine, but can be conflicting with already seated guests. Previously seated guests cannot be moved by the sorting feature in order to not tamper with seating choices already made by the user."
    

}
