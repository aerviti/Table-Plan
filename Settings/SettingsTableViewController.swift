//
//  SettingsTableViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/25/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    let APPID = "1147076572"
    let APPURL = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1147076572&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
    let APPVER = "1.0.0"

    
    //MARK: Properties
    @IBOutlet weak var clearSeats: UITableViewCell!
    @IBOutlet weak var clearConstraints: UITableViewCell!
    @IBOutlet weak var changePlan: UITableViewCell!
    @IBOutlet weak var deletePlan: UITableViewCell!
    @IBOutlet weak var resetPlan: UITableViewCell!
    @IBOutlet weak var help: UITableViewCell!
    @IBOutlet weak var rateTablePlan: UITableViewCell!
    @IBOutlet weak var reportABug: UITableViewCell!
    @IBOutlet weak var suggestAFeature: UITableViewCell!
    
    var indexPath : IndexPath? = nil;
    var tablePlan : TablePlan!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Retrieve table plan from TabBarController and get its NSIndexPath
        let tabBarController = self.tabBarController as! TabBarController;
        indexPath = tabBarController.planIndexPath;
        tablePlan = tabBarController.tablePlan;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 5;
        }else if (section == 1) {
            return 4;
        }
        return 0;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath == tableView.indexPath(for: clearSeats)) {
            clearSeatsCheck();
            
        }else if (indexPath == tableView.indexPath(for: clearConstraints)) {
            clearConstraintsCheck();
            
        }else if (indexPath == tableView.indexPath(for: resetPlan)) {
            resetCheck();
            
        }else if (indexPath == tableView.indexPath(for: deletePlan)) {
            deleteCheck();
            
        }else if (indexPath == tableView.indexPath(for: changePlan)) {
            performSegue(withIdentifier: "SwitchPlanSegue", sender: self);
            
        }else if (indexPath == tableView.indexPath(for: help)) {
            performSegue(withIdentifier: "HelpSegue", sender: self);
            
        }else if (indexPath == tableView.indexPath(for: rateTablePlan)) {
            showAppPage();
            
        }else if (indexPath == tableView.indexPath(for: reportABug)) {
            createEmailTemplate(subject: "Bug Report");
            
        }else if (indexPath == tableView.indexPath(for: suggestAFeature)) {
            createEmailTemplate(subject: "Feature Suggestion");
        }
    }
    
    
    /* Helper function that sets up an alert controller that asks for permission to clear the current plan's guests' seats. If "Clear" is pressed, clears all guests' seats. */
    fileprivate func clearSeatsCheck() {
        let alertController = UIAlertController(title: "Clear Seats?", message: "Are you sure you want to clear all seats in this table plan?", preferredStyle: .alert);
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
        }
        let deleteButton = UIAlertAction(title: "Clear", style: .destructive) { (_) in
            self.tablePlan.clearSeats();
            (self.tabBarController as! TabBarController).savePlans();
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
        }
        alertController.addAction(cancelAction);
        alertController.addAction(deleteButton);
        present(alertController, animated: true, completion: nil);
    }
    
    
    /* Helper function that sets up an alert controller that asks for permission to clear all constraints in the current plan. If "Clear" is pressed, clears all constraints. */
    fileprivate func clearConstraintsCheck() {
        let alertController = UIAlertController(title: "Clear Constraints?", message: "Are you sure you want to clear all constraints in this table plan?", preferredStyle: .alert);
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
        }
        let deleteButton = UIAlertAction(title: "Clear", style: .destructive) { (_) in
            self.tablePlan.clearConstraints();
            (self.tabBarController as! TabBarController).savePlans();
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
        }
        alertController.addAction(cancelAction);
        alertController.addAction(deleteButton);
        present(alertController, animated: true, completion: nil);
    }
    
    
    /* Helper function that sets up an alert controller that asks for permission to delete the current plan. If "Delete" is pressed, deletes the plan. */
    fileprivate func deleteCheck() {
        let alertController = UIAlertController(title: "Delete Plan?", message: "Are you sure you want to delete this table plan?", preferredStyle: .alert);
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
        }
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.performSegue(withIdentifier: "DeletePlanSegue", sender: self);
        }
        
        alertController.addAction(cancelAction);
        alertController.addAction(deleteButton);
        present(alertController, animated: true, completion: nil);
        
    }
    
    
    /* Helper function that sets up an alert controller that asks for permission to clear the current plan. If "Reset" is pressed, resets the plan. */
    fileprivate func resetCheck() {
        let alertController = UIAlertController(title: "Reset Plan?", message: "Are you sure you want to reset this table plan and erase all of its contents?", preferredStyle: .alert);
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
        }
        let deleteButton = UIAlertAction(title: "Reset", style: .destructive) { (_) in
            self.tablePlan.resetPlan();
            (self.tabBarController as! TabBarController).savePlans();
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
        }
        
        alertController.addAction(cancelAction);
        alertController.addAction(deleteButton);
        present(alertController, animated: true, completion: nil);
    }
    
    
    /* Helper function that presents the app store review page in the default browser. */
    fileprivate func showAppPage() {
        UIApplication.shared.openURL(URL(string: APPURL)!);
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true);
        }
    }
    
    
    /* Helper function that creates an email template for bug reporting. */
    fileprivate func createEmailTemplate(subject: String) {
        let mailController = MFMailComposeViewController();
        mailController.mailComposeDelegate = self;
        mailController.navigationBar.tintColor = UIColor.white;
        mailController.setToRecipients(["TablePlanApp@gmail.com"]);
        let subject: String = subject;
        let appVersion: String = "App Version: " + APPVER;
        let phoneModel: String = "Phone Model: " + deviceName;
        let iOSVer: String = "iOS Version: " + UIDevice.current.systemVersion;
        let body: String = "\n\n\n=== Diagnostic Data ===" + "\n" + appVersion + "\n" + phoneModel + "\n" + iOSVer + "\n===";
        mailController.setSubject(subject);
        mailController.setMessageBody(body, isHTML: false);
        present(mailController, animated: false, completion: nil);
    }
    
    /* Delegate function that handles the dismissal of a compose view controller. */
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil);
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true);
        }
    }
    
    /* Computed property that gets the iPhone model. */
    var deviceName: String {
        var systemInfo = utsname();
        uname(&systemInfo);
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier;
    }

    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination;
        destinationViewController.navigationItem.title = "Help";
    }
}
