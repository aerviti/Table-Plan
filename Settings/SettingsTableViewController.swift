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
import StoreKit


class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIWebViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    let APPID = "1147076572"
    let APPURL = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1147076572&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
    let APPVER = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.1.2"

    
    //MARK: Properties
    @IBOutlet weak var clearSeats: UITableViewCell!
    @IBOutlet weak var clearConstraints: UITableViewCell!
    @IBOutlet weak var editPlan: UITableViewCell!
    @IBOutlet weak var changePlan: UITableViewCell!
    @IBOutlet weak var deletePlan: UITableViewCell!
    @IBOutlet weak var resetPlan: UITableViewCell!
    @IBOutlet weak var previewPDF: UITableViewCell!
    @IBOutlet weak var exportToPDF: UITableViewCell!
    @IBOutlet weak var help: UITableViewCell!
    @IBOutlet weak var rateTablePlan: UITableViewCell!
    @IBOutlet weak var reportABug: UITableViewCell!
    @IBOutlet weak var suggestAFeature: UITableViewCell!
    @IBOutlet weak var removeAds: UITableViewCell!
    @IBOutlet weak var restorePurchases: UITableViewCell!
    
    var indexPath : IndexPath? = nil;
    var tablePlan : TablePlan!;
    var pdfURL : NSURL!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Retrieve table plan from TabBarController and get its NSIndexPath
        let tabBarController = self.tabBarController as! TabBarController;
        indexPath = tabBarController.planIndexPath;
        tablePlan = tabBarController.tablePlan;
        
        // Set transaction observer
        SKPaymentQueue.default().add(self);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 2) {
            return TitleViewController.footerSize;
        }
        return UITableViewAutomaticDimension;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 6;
        }else if (section == 1) {
            return 2;
        }else if (section == 2) {
            return 6;
        }
        return 0;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath == tableView.indexPath(for: clearSeats)) {
            clearSeatsCheck();
            
        }else if (indexPath == tableView.indexPath(for: clearConstraints)) {
            clearConstraintsCheck();
            
        }else if (indexPath == tableView.indexPath(for: editPlan)) {
            performSegue(withIdentifier: "EditPlanSegue", sender: self);
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
        
        }else if (indexPath == tableView.indexPath(for: resetPlan)) {
            resetCheck();
            
        }else if (indexPath == tableView.indexPath(for: deletePlan)) {
            deleteCheck();
            
        }else if (indexPath == tableView.indexPath(for: changePlan)) {
            performSegue(withIdentifier: "SwitchPlanSegue", sender: self);
        
        }else if (indexPath == tableView.indexPath(for: previewPDF)) {
            pdfPreviewChoice();
        
        }else if (indexPath == tableView.indexPath(for: exportToPDF)) {
            if let pdfData = createDataPDF(), let pdfCompactData = createCompactDataPDF() {
                let fileName = tablePlan.name + ".pdf";
                let compactFileName = tablePlan.name + " (Compact).pdf";
                let emailTitle = tablePlan.name + " PDF";
                let mailController = createEmailTemplate(subject: emailTitle, recipient: "", diagnostic: false);
                mailController.addAttachmentData(pdfData, mimeType: "pdf", fileName: fileName);
                mailController.addAttachmentData(pdfCompactData, mimeType: "pdf", fileName: compactFileName);
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
            
        }else if (indexPath == tableView.indexPath(for: removeAds)) {
            removeAdsRequest();
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
            
        }else if (indexPath == tableView.indexPath(for: restorePurchases)) {
            restorePurchasesRequest();
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
        }
    }
    
    /* Helper function that sets up a popup asking if the user wants to preview a compact PDF or a detailed PDF. */
    fileprivate func pdfPreviewChoice() {
        if let selected = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selected, animated: true);
        }
        let addTableAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);
        let viewDetail = UIAlertAction(title: "Detailed PDF", style: .default) { (_) in
            if let pdfURL = self.createPDF() {
                if QLPreviewController.canPreview(pdfURL) {
                    self.pdfURL = pdfURL;
                    let quickLookController = QLPreviewController();
                    quickLookController.dataSource = self;
                    quickLookController.delegate = self;
                    self.present(quickLookController, animated: true, completion: nil);
                }
            }
        }
        let viewCompact = UIAlertAction(title: "Compact PDF", style: .default) { (_) in
            if let pdfURL = self.createCompactPDF() {
                if QLPreviewController.canPreview(pdfURL) {
                    self.pdfURL = pdfURL;
                    let quickLookController = QLPreviewController();
                    quickLookController.dataSource = self;
                    quickLookController.delegate = self;
                    self.present(quickLookController, animated: true, completion: nil);
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
        addTableAlert.addAction(viewDetail);
        addTableAlert.addAction(viewCompact);
        addTableAlert.addAction(cancel);
        addTableAlert.popoverPresentationController?.sourceView = self.view;
        addTableAlert.popoverPresentationController?.sourceRect = CGRect(x: previewPDF.center.x, y: previewPDF.center.y, width: 1, height: 1);
        present(addTableAlert, animated: true, completion: nil);
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
    
    @IBAction func unwindtoSettings(_ sender: UIStoryboardSegue) {
        //Nothing!
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "EditPlanSegue") {
            let destinationViewController = segue.destination as! AddPlanViewController;
            destinationViewController.tablePlan = tablePlan;
            destinationViewController.seguedFromSettings = true;
        }else if (segue.identifier == "HelpSegue") {
            let destinationViewController = segue.destination;
            destinationViewController.navigationItem.title = "Help";
        }
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
    
    
    
    // MARK: - In App Purchases
    
    /* Sends request to purchase the remove ads option. */
    func removeAdsRequest() {
        if (!SKPaymentQueue.canMakePayments()) {
            present(message: notAllowed, title: "Permission Denied");
        }else if (UserDefaults.standard.bool(forKey: "RemoveAds")) {
            present(message: alreadyPurchased, title: "Already Purchased");
        }else {
            let productIdentifiers: Set<String> = [TitleViewController.RemoveAds];
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers);
            productRequest.delegate = self;
            productRequest.start();
        }
    }
    
    
    /* Sends a request to restore purchases. */
    func restorePurchasesRequest() {
        if (!SKPaymentQueue.canMakePayments()) {
            present(message: notAllowed, title: "Permission Denied");
        }else if (UserDefaults.standard.bool(forKey: "RemoveAds")) {
            present(message: alreadyPurchased, title: "Already Purchased");
        }else {
            print("Attempting purchase restoration...");
            SKPaymentQueue.default().restoreCompletedTransactions();
        }
    }
    
    
    /* Helper function that presents an alert that the user has already made the purchase. */
    private func present(message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
        }
        alertController.addAction(cancelAction);
        present(alertController, animated: true, completion: nil);
    }
    
    private let alreadyPurchased: String = "You have already made this purchase.";
    private let notAllowed: String = "You are not permitted to make purchases on this account.";
    
    
    
    // MARK: SKProductsRequestDelegate
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded products...");
        if let product = response.products.first {
            print(product.localizedTitle);
            let payment = SKPayment(product: product);
            SKPaymentQueue.default().add(payment);
        }else {
            print("Missing product.");
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.");
        print("Error: \(error.localizedDescription)");
    }
    
    
    // MARK: SKPaymentTransactionObserver
    
    /* Function that handles payments from the SKPaymentQueue. */
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("Processing transaction...");
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction);
                break
            case .failed:
                fail(transaction: transaction);
                break
            case .restored:
                restore(transaction: transaction);
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    /* Helper function that deals with completed transactions. */
    private func complete(transaction: SKPaymentTransaction) {
        print("Transaction Complete");
        UserDefaults.standard.set(true, forKey: "RemoveAds");
        UserDefaults.standard.synchronize();
        (self.tabBarController as! TabBarController).removeAd();
        SKPaymentQueue.default().finishTransaction(transaction);
    }
    
    /* Helper function that deals with failed transactions. */
    private func fail(transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error {
            print("Transaction Error: \(transactionError.localizedDescription)");
        }
        SKPaymentQueue.default().finishTransaction(transaction);
    }
    
    /* Helper function that deals with restored transactions. */
    private func restore(transaction: SKPaymentTransaction) {
        print("Transaction Restored");
        UserDefaults.standard.set(true, forKey: "RemoveAds");
        UserDefaults.standard.synchronize();
        (self.tabBarController as! TabBarController).removeAd();
        SKPaymentQueue.default().finishTransaction(transaction);
        present(message: "Transaction successfully restored.", title: "Transaction Restored");
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
    let titleFontSize: CGFloat = 24;
    let dateFontSize: CGFloat = 18;
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
    
    /* Gets data of a compact pdf and returns it as a NSURL. */
    func createCompactPDF() -> NSURL? {
        if let data = createCompactDataPDF() {
            let fileName = tablePlan.name + " (Compact).pdf";
            let dst = URL(fileURLWithPath: NSTemporaryDirectory().appending(fileName));
            do {
                try data.write(to: dst);
                return (dst as NSURL);
            }catch (let error) {
                print(error);
            }
        }
        return nil;
    }
    
    /* Gets html of a compact representation of the table plan and returns it as Data. */
    func createCompactDataPDF() -> Data? {
        let html = getCompactString();
        let printPageRenderer = UIPrintPageRenderer();
        let printFrame = CGRect(x: 0, y: 0, width: 612, height: 792);
        printPageRenderer.setValue(NSValue(cgRect: printFrame), forKey: "paperRect");
        printPageRenderer.setValue(NSValue(cgRect: printFrame.insetBy(dx: 20.0, dy: 10.0)), forKey: "printableRect");
        printPageRenderer.addPrintFormatter(UIMarkupTextPrintFormatter(markupText: html!), startingAtPageAt: 0);
        let pdfData = NSMutableData();
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil);
        for i in 0..<printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds();
            printPageRenderer.drawPage(at: i, in: bounds);
        }
        UIGraphicsEndPDFContext();
        return (pdfData as Data);
    }
    
    /* Creates and returns HTML of a compact representation of the table plan. */
    fileprivate func getCompactString() -> String? {
        let pathToHTML = Bundle.main.path(forResource: "compactPDF", ofType: "html");
        let pathToGuestTemplate = Bundle.main.path(forResource: "guestEntry", ofType: "html");
        let pathToTableTemplate = Bundle.main.path(forResource: "tableEntry", ofType: "html");
        let planTitle = tablePlan.name;
        let planDate = tablePlan.date;
        
        do {
            var compactHTML = try String(contentsOfFile: pathToHTML!);
            compactHTML = compactHTML.replacingOccurrences(of: "#PLAN_TITLE#", with: planTitle);
            compactHTML = compactHTML.replacingOccurrences(of: "#PLAN_DATE#", with: planDate);
            
            var allGuests = "";
            for guest in tablePlan.guestList {
                var itemHTML = try String(contentsOfFile: pathToGuestTemplate!);
                itemHTML = itemHTML.replacingOccurrences(of: "#GUEST#", with: guest.getFullName(tablePlan.sort));
                itemHTML = itemHTML.replacingOccurrences(of: "#GROUP#", with: guest.table?.tableGroup ?? "N/A");
                itemHTML = itemHTML.replacingOccurrences(of: "#TABLE#", with: guest.table?.name ?? "N/A");
                if let seatNum = guest.seat?.seatNumOfTable {
                    itemHTML = itemHTML.replacingOccurrences(of: "#SEAT#", with: (seatNum+1).description);
                }else {
                    itemHTML = itemHTML.replacingOccurrences(of: "#SEAT#", with: "N/A");
                }
                allGuests += itemHTML;
            }
            
            var allTables = "";
            for table in tablePlan.tableList {
                var itemHTML = try String(contentsOfFile: pathToTableTemplate!);
                itemHTML = itemHTML.replacingOccurrences(of: "#TABLE#", with: table.name);
                itemHTML = itemHTML.replacingOccurrences(of: "#GROUP#", with: table.tableGroup ?? "N/A");
                itemHTML = itemHTML.replacingOccurrences(of: "#NUMBER_OF_SEATS#", with: table.numOfSeats.description);
                allTables += itemHTML;
            }
            
            compactHTML = compactHTML.replacingOccurrences(of: "#GUEST_ENTRIES#", with: allGuests);
            compactHTML = compactHTML.replacingOccurrences(of: "#TABLE_ENTRIES#", with: allTables);
            return compactHTML;
        } catch (let error) {
            print(error)
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
                let y = CGFloat(table.y) + BUFFER*2.5;
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
                    tableView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2));
                }
                //tableBoundsCheck(tableView);
            }
        }
        
        var contentRect: CGRect = CGRect.zero;
        for tableView in tableViews {
            contentRect = contentRect.union(tableView.frame);
        }
        view.frame = CGRect(x: 0, y: 0, width: contentRect.width + BUFFER, height: contentRect.height + BUFFER);
        
        //Add title, date, and logo
        let title = UILabel(frame: CGRect(x: 0, y: BUFFER/2, width: 200, height: titleFontSize+fontBuffer));
        title.center.x = view.center.x;
        title.textAlignment = .center;
        title.text = tablePlan.name;
        title.font = UIFont.boldSystemFont(ofSize: titleFontSize);
        view.addSubview(title);
        
        let date = UILabel(frame: CGRect(x: 0, y: BUFFER/2+title.frame.height, width: 200, height: dateFontSize+fontBuffer));
        date.center.x = view.center.x;
        date.textAlignment = .center;
        date.text = tablePlan.date;
        date.font = UIFont.italicSystemFont(ofSize: dateFontSize);
        view.addSubview(date);
        
        let logo = UIImageView(frame: CGRect(x: BUFFER/2, y: BUFFER/2, width: 60, height: 25));
        logo.image = UIImage(named: "title");
        logo.backgroundColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1);
        view.addSubview(logo);
        view.sendSubview(toBack: logo);
        
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
