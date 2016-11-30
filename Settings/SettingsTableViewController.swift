//
//  SettingsTableViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/25/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit
import MessageUI
import PDFGenerator
import QuickLook


class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    let APPID = "1147076572"
    let APPURL = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1147076572&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
    let APPVER = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.3"

    
    //MARK: Properties
    @IBOutlet weak var clearSeats: UITableViewCell!
    @IBOutlet weak var clearConstraints: UITableViewCell!
    @IBOutlet weak var changePlan: UITableViewCell!
    @IBOutlet weak var deletePlan: UITableViewCell!
    @IBOutlet weak var resetPlan: UITableViewCell!
    @IBOutlet weak var previewPDF: UITableViewCell!
    @IBOutlet weak var exportToPDF: UITableViewCell!
    @IBOutlet weak var help: UITableViewCell!
    @IBOutlet weak var rateTablePlan: UITableViewCell!
    @IBOutlet weak var reportABug: UITableViewCell!
    @IBOutlet weak var suggestAFeature: UITableViewCell!
    
    var indexPath : IndexPath? = nil;
    var tablePlan : TablePlan!;
    var pdfURL : NSURL!;
    
    
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
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 5;
        }else if (section == 1) {
            return 2;
        }else if (section == 2) {
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
        
        }else if (indexPath == tableView.indexPath(for: previewPDF)) {
            if let pdfURL = createPDF() {
                if QLPreviewController.canPreview(pdfURL) {
                    self.pdfURL = pdfURL;
                    let quickLookController = QLPreviewController();
                    quickLookController.dataSource = self;
                    quickLookController.delegate = self;
                    present(quickLookController, animated: true, completion: nil);
                }
            }
        
        }else if (indexPath == tableView.indexPath(for: exportToPDF)) {
            if let pdfData = createDataPDF() {
                let fileName = tablePlan.name + ".pdf";
                let emailTitle = tablePlan.name + " PDF";
                let mailController = createEmailTemplate(subject: emailTitle, recipient: "", diagnostic: false);
                mailController.addAttachmentData(pdfData, mimeType: "pdf", fileName: fileName);
                present(mailController, animated: true, completion: nil);
            }
        
        }else if (indexPath == tableView.indexPath(for: help)) {
            performSegue(withIdentifier: "HelpSegue", sender: self);
            
        }else if (indexPath == tableView.indexPath(for: rateTablePlan)) {
            showAppPage();
            
        }else if (indexPath == tableView.indexPath(for: reportABug)) {
            let mailController = createEmailTemplate(subject: "Bug Report", recipient: "TablePlanApp@gmail.com", diagnostic: true);
            present(mailController, animated: false, completion: nil);
            
        }else if (indexPath == tableView.indexPath(for: suggestAFeature)) {
            let mailController = createEmailTemplate(subject: "Feature Suggestion", recipient: "TablePlanApp@gmail.com", diagnostic: true);
            present(mailController, animated: false, completion: nil);
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
    fileprivate func createEmailTemplate(subject: String, recipient: String, diagnostic: Bool) -> MFMailComposeViewController {
        let mailController = MFMailComposeViewController();
        mailController.mailComposeDelegate = self;
        mailController.navigationBar.tintColor = UIColor.white;
        mailController.setToRecipients([recipient]);
        mailController.setSubject(subject);
        let appVersion: String = "App Version: " + APPVER;
        let phoneModel: String = "Phone Model: " + deviceName;
        let iOSVer: String = "iOS Version: " + UIDevice.current.systemVersion;
        let body: String = "\n\n\n=== Diagnostic Data ===" + "\n" + appVersion + "\n" + phoneModel + "\n" + iOSVer + "\n===";
        if diagnostic { mailController.setMessageBody(body, isHTML: false) }
        return mailController;
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
    
    
    
    // MARK: - QLPreview DataSource/Delegate
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1;
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return pdfURL;
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true);
        }
    }
    
    
    
    // MARK: - PDF Creations
    
    // PDF Properties
    let COLUMNS: Int = 3;
    let BUFFER: CGFloat = 30;
    let MARGIN: CGFloat = 40;
    let COLUMNGAP: CGFloat = 15;
    let TABLEIMAGEHEIGHT: CGFloat = 80;
    var TABLEWIDTH: CGFloat {
        return (612 - (MARGIN*2 + COLUMNGAP*CGFloat(COLUMNS-1))) / CGFloat(COLUMNS);
    }
    fileprivate func TABLEHEIGHT(_ table: Table) -> CGFloat {
        return (tableFontSize+fontBuffer) + (CGFloat(table.numOfSeats) * (seatFontSize+fontBuffer) + TABLEIMAGEHEIGHT);
    }
    let seatNumWidth: CGFloat = 24;
    let seatFontSize: CGFloat = 10;
    let tableFontSize: CGFloat = 14;
    let fontBuffer: CGFloat = 4;
    let tableBuffer: CGFloat = 10;
    
    /* Creates and returns a temporary URL for a PDF of the table plan. */
    func createPDF() -> NSURL? {
        let firstPage = floorPlanView(tables: tablePlan.tableList);
        let pages = [firstPage] + tableListViews(tables: tablePlan.tableList);
        
        let fileName = tablePlan.name + ".pdf";
        let dst = URL(fileURLWithPath: NSTemporaryDirectory().appending(fileName));
        
        // outputs as Data
        do {
            try PDFGenerator.generate(pages, to: dst);
            return (dst as NSURL);
        } catch (let error) {
            print(error);
        }
        return nil;
    }
    
    /* Creates and returns a PDF of the table plan in the form of Data. */
    func createDataPDF() -> Data? {
        let firstPage = floorPlanView(tables: tablePlan.tableList);
        let pages = [firstPage] + tableListViews(tables: tablePlan.tableList);
        
        do {
            let data = try PDFGenerator.generated(by: pages);
            return data;
        } catch (let error) {
            print(error);
        }
        return nil;
    }
    
    
    /* Create floor plan view for PDF creation. */
    fileprivate func floorPlanView(tables: [Table]) -> UIView {
        let view = UIView();
        var tableViews: Set<FloorPlanTableView> = Set<FloorPlanTableView>();
        for table in tables {
            if table.isPlaced() {
                let x = CGFloat(table.x) + BUFFER;
                let y = CGFloat(table.y) + BUFFER;
                let tableView = FloorPlanTableView(table: table);
                tableView.center = CGPoint(x: x, y: y);
                tableView.table = table;
                tableView.backgroundColor = UIColor.clear;
                view.addSubview(tableView);
                tableView.isUserInteractionEnabled = true;
                tableViews.insert(tableView);
                tableView.setNeedsDisplay();
                
                // Rotate table if table loaded in is rotated
                if table.rotated {
                    tableView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2));
                }
                //tableBoundsCheck(tableView);
            }
        }
        
        var contentRect: CGRect = CGRect.zero;
        for tableView in tableViews {
            contentRect = contentRect.union(tableView.frame);
        }
        view.frame = CGRect(x: 0, y: 0, width: contentRect.width + BUFFER, height: contentRect.height + BUFFER);
        return view;
    }
    
    
    /* Create table list views for PDF creation. */
    fileprivate func tableListViews(tables: [Table]) -> [UIView] {
        var view = UIView(frame: CGRect(x: 0, y: 0, width: 612, height: 792));
        var viewList: [UIView] = [view];
        var xLoc: CGFloat = MARGIN;
        var yLoc: CGFloat = MARGIN;
        var currentColumn: Int = 1;
        
        for table in tables {
            // Add to current column
            if (yLoc + TABLEHEIGHT(table) < (792-MARGIN)) {
                let tableView = getTableList(table: table, x: xLoc, y: yLoc);
                view.addSubview(tableView);
                yLoc = yLoc + tableView.frame.height + tableBuffer;
            
            // Move to second column and add to it
            }else if (currentColumn < COLUMNS) {
                currentColumn += 1;
                xLoc += TABLEWIDTH + COLUMNGAP;
                yLoc = MARGIN;
                let tableView = getTableList(table: table, x: xLoc, y: yLoc);
                view.addSubview(tableView);
                yLoc = yLoc + tableView.frame.height + tableBuffer;
                
            // Create new view page and add to it
            }else {
                view = UIView(frame: CGRect(x: 0, y: 0, width: 612, height: 792));
                viewList.append(view);
                xLoc = MARGIN;
                yLoc = MARGIN;
                currentColumn = 1;
                let tableView = getTableList(table: table, x: xLoc, y: yLoc);
                view.addSubview(tableView);
                yLoc = yLoc + tableView.frame.height + tableBuffer;
            }
        }
        return viewList;
    }
    
    
    /* Create a subview including text of a table and its seated guests. */
    fileprivate func getTableList(table: Table, x: CGFloat, y: CGFloat) -> UIView {
        let height: CGFloat = TABLEHEIGHT(table);
        let view = UIView(frame: CGRect(x: x, y: y, width: TABLEWIDTH, height: height));
        
        let tableFrame = UIView(frame: CGRect(x: 0, y: 0, width: TABLEWIDTH, height: TABLEIMAGEHEIGHT));
        let tableImage = TableImageView(frame: CGRect(x: 0, y: 0, width: 375, height: 200));
        tableImage.table = table;
        tableImage.backgroundColor = UIColor.clear;
        tableFrame.addSubview(tableImage);
        tableFrame.transform = CGAffineTransform(scaleX: TABLEWIDTH/400, y: TABLEWIDTH/400);
        tableFrame.frame = CGRect(x: 0, y: 0, width: TABLEWIDTH, height: TABLEIMAGEHEIGHT);
        view.addSubview(tableFrame);
        
        let title = UILabel(frame: CGRect(x: seatNumWidth, y: TABLEIMAGEHEIGHT, width: TABLEWIDTH-seatNumWidth, height: tableFontSize+fontBuffer));
        title.text = table.name;
        title.font = UIFont.boldSystemFont(ofSize: tableFontSize);
        view.addSubview(title);
        
        for (index, seat) in table.seats.enumerated() {
            let y: CGFloat = (tableFontSize+fontBuffer+TABLEIMAGEHEIGHT) + CGFloat(index) * (seatFontSize+fontBuffer);
            let seatNum = UILabel(frame: CGRect(x: 0, y: y, width: seatNumWidth, height: seatFontSize+fontBuffer));
            seatNum.text = String(index+1) + " -";
            seatNum.font = seatNum.font.withSize(seatFontSize);
            seatNum.textAlignment = .right;
            view.addSubview(seatNum);
            let seatedGuest = UILabel(frame: CGRect(x: seatNumWidth, y: y, width: TABLEWIDTH - seatNumWidth, height: seatFontSize+fontBuffer));
            seatedGuest.text = seat.guestSeated?.getFullName(.FirstName) ?? "";
            seatedGuest.font = seatedGuest.font.withSize(seatFontSize);
            view.addSubview(seatedGuest);
        }
        return view;
    }
    
    
}
