//
//  FloorPlanViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 6/26/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class FloorPlanViewController: UIViewController, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {

    // MARK: Properties
    @IBOutlet weak var scrollView: UIScrollView!
    var addTableAlert: UIAlertController!;
    var infoAlert: UIAlertController!;
    
    var tablePlan: TablePlan!;
    var tableViews: Set<FloorPlanTableView> = Set<FloorPlanTableView>();
    var chosenTable: Table? = nil;
    var chosenTableView: FloorPlanTableView? = nil;
    var tableToAdd: Table? = nil;
    var _xToAdd: CGFloat? = nil;
    var _yToAdd: CGFloat? = nil;
    
    // Masks for xToAdd and yToAdd
    var xToAdd: CGFloat? {
        get {
            if (_xToAdd < 0) {
                return 0;
            }
            return _xToAdd;
        }set(x) {
            _xToAdd = x;
        }
    }
    var yToAdd: CGFloat? {
        get {
            if (_yToAdd < 0) {
                return 0;
            }
            return _yToAdd;
        }set(y) {
            _yToAdd = y;
        }
    }
    
    
    
    // MARK: - View Prep
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self;

        // Retrieve table plan from TabBarController and update counts
        let tabBarController = self.tabBarController as! TabBarController;
        tablePlan = tabBarController.tablePlan;
        
        // Set gesture recognizers
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(FloorPlanViewController.handleLongPress(_:)));
        longPressGesture.minimumPressDuration = 0.3;
        scrollView.addGestureRecognizer(longPressGesture);
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FloorPlanViewController.handleTap(_:)));
        scrollView.addGestureRecognizer(tapGesture);
        
        // Set up popover presentation controller
        addTableAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);
        let addTable = UIAlertAction(title: "Add Table", style: .default) { (_) in
            self.performSegue(withIdentifier: "AddTableSegue", sender: nil);
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
        addTableAlert.addAction(addTable);
        addTableAlert.addAction(cancel);
        
        //Load tables on view
        for table in tablePlan!.tableList {
            placeTable(table);
        }
        
        //Set up info alert
        infoAlert = UIAlertController(title: "Instructions", message: floorPlanInfo, preferredStyle: .alert);
        let okButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil);
        infoAlert.addAction(okButton);
    }
    
    
    // Redraws the tables in case of any edits and hides nav bar
    override func viewWillAppear(_ animated: Bool) {
        updateTableViews();
        navigationController?.setNavigationBarHidden(true, animated: false);
    }
    
    
    // Update views and scroll view when view appears
    override func viewDidAppear(_ animated: Bool) {
        for tableView in tableViews {
            if (tableView.table!.rotated) {
                tableView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2));
            }
        }
        updateContentView();
        
        if tablePlan!.floorPlanNotOpened {
            present(infoAlert, animated: true, completion: nil);
            tablePlan!.floorPlanNotOpened = false;
        }
    }
    
    
    // Helper func that places a table given the controllers x y coords and stores this info in the Table instance
    fileprivate func placeTable(_ table: Table) {
        if table.isPlaced() {
            let x = table.x;
            let y = table.y;
            let tableView = FloorPlanTableView(table: table);
            tableView.center = CGPoint(x: x, y: y);
            tableView.table = table;
            tableView.backgroundColor = UIColor.clear;
            scrollView.addSubview(tableView);
            tableView.isUserInteractionEnabled = true;
            tableViews.insert(tableView);
            tableView.setNeedsDisplay();
            
            // Rotate table if table loaded in is rotated
            if table.rotated {
                tableView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2));
            }
            tableBoundsCheck(tableView);
        }
    }
    
    
    // Helper function that updates the placed table views' images or removes the view if previously deleted from the table plan
    fileprivate func updateTableViews() {
        for tableView in tableViews {
            
            if (!tableView.table!.isPlaced()) {
                tableView.removeFromSuperview();
                tableViews.remove(tableView);
            }else {
                tableView.transform = CGAffineTransform(rotationAngle: 0);
                tableView.setNeedsDisplay();
            }
        }
    }
    
    
    // Helper function that updates scroll view content size
    fileprivate func updateContentView() {
        var contentRect: CGRect = CGRect.zero;
        for view in tableViews {
            contentRect = contentRect.union(view.frame);
        }
        scrollView.contentSize = CGSize(width: contentRect.width + 45, height: contentRect.height + 45);
    }
    
    
    // If a table's origin is out of the view's bounds, move it in bounds
    fileprivate func tableBoundsCheck(_ tableView: FloorPlanTableView) {
        var changed = false;
        if (tableView.frame.origin.x < 0) {
            tableView.frame.origin.x = 0;
            changed = true;
        }else if (tableView.frame.origin.y < 0) {
            tableView.frame.origin.y = 0;
            changed = true;
        }
        
        // Place table in new spot if changed
        if changed {
            let x = tableView.center.x;
            let y = tableView.center.y;
            tableView.table!.placeTable(x: Double(x), y: Double(y));
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Gesture Functions
    
    func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: gesture.view!);
        switch gesture.state {
        case .began:
            longPressBegan(location);
        case .changed:
            longPressChanged(location);
        case .ended:
            longPressEnded(location);
        default:
            break;
        }
    }
    
    
    // Long press gesture function
    fileprivate func longPressBegan(_ location: CGPoint) {
        if let selectedView = scrollView.hitTest(location, with: nil) {
            // If gesture begins on a table, set it up for movement
            if let tableView = selectedView as? FloorPlanTableView {
                chosenTable = tableView.table;
                chosenTableView = tableView;
                chosenTableView!.alpha = 0.3;
                scrollView.bringSubview(toFront: chosenTableView!);
                
            // If gesture beings on scrollView, call the add table alert
            }else if (selectedView == scrollView) {
                xToAdd = location.x;
                yToAdd = location.y;
                addTableAlert.popoverPresentationController?.sourceView = scrollView;
                addTableAlert.popoverPresentationController?.sourceRect = CGRect(x: xToAdd!, y: yToAdd!, width: 1, height: 1);
                present(addTableAlert, animated: true, completion: nil);
            }
        }
    }
    
    
    fileprivate func longPressChanged(_ location: CGPoint) {
        // Replace table wherever the gesture moves
        if (chosenTableView != nil) {
            let xToMove = location.x;
            let yToMove = location.y;
            chosenTableView!.table?.placeTable(x: Double(xToMove), y: Double(yToMove));
            chosenTableView!.center = CGPoint(x: xToMove, y: yToMove);
        }
    }
    
    
    fileprivate func longPressEnded(_ location: CGPoint) {
        // Unset the chosen table for movement and save the new position
        if (chosenTableView != nil) {
            tableBoundsCheck(chosenTableView!);
            chosenTableView!.alpha = 1;
            chosenTableView = nil;
            chosenTable = nil;
            (tabBarController as! TabBarController).savePlans();
        }
        updateContentView();
    }
    
    
    // Tap gesture function
    func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view!);
        
        // If a table is tapped, store that table and present the options view controller
        if let selectedView = scrollView.hitTest(location, with: nil) as? FloorPlanTableView {
            chosenTable = selectedView.table;
            chosenTableView = selectedView;
            let optionsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tableOptionsView");
            optionsViewController.modalPresentationStyle = .popover;
            optionsViewController.preferredContentSize = CGSize(width: 150, height: 50);
            optionsViewController.view.backgroundColor = UIColor.clear;
            let popoverPresentationController = optionsViewController.popoverPresentationController!;
            popoverPresentationController.delegate = self;
            popoverPresentationController.permittedArrowDirections = .any;
            popoverPresentationController.sourceView = scrollView;
            popoverPresentationController.sourceRect = CGRect(origin: selectedView.center, size: CGSize(width: 1, height: 1));
            present(optionsViewController, animated: true, completion: nil);
        }
    }
    
    
    // Allow custom gestures to be registered by the scroll view
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    // Forces a popover presentation on iphones
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none;
    }
    
    
    
    // MARK: - Button Actions
    
    @IBAction func help(_ sender: UIButton) {
        present(infoAlert, animated: true, completion: nil);
    }
    
    
    
    // MARK: - Navigation
    
    @IBAction func unwindToFloorPlan(_ sender: UIStoryboardSegue) {
        // Place table if a table is added
        if let sourceViewController = sender.source as? TablePickerViewController {
            let tableToAdd = sourceViewController.chosenTable;
            tableToAdd?.placeTable(x: Double(xToAdd!), y: Double(yToAdd!));
            placeTable(tableToAdd!);
            
        // Delete table if delete option is pressed and action is confirmed through an alert controller
        }else if (sender.identifier == "deleteTableSegue") {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Remove Table?", message: "Are you sure you want to remove this table from the floor plan?", preferredStyle: .alert);
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
                let deleteButton = UIAlertAction(title: "Remove", style: .destructive) { (_) in
                    self.chosenTableView!.removeFromSuperview();
                    self.tableViews.remove(self.chosenTableView!);
                    self.chosenTable!.unplaceTable();
            }
                alertController.addAction(cancelAction);
                alertController.addAction(deleteButton);
                self.present(alertController, animated: true, completion: nil);
            }
           
        // Turn table if turn option is pressed
        }else if (sender.identifier == "turnTableSegue") {
            UIView.animate(withDuration: 0.5, animations: {
                if (self.chosenTable!.rotated) {
                    self.chosenTable!.rotated = false;
                    self.chosenTableView!.transform = CGAffineTransform(rotationAngle: 0);
                }else {
                    self.chosenTable!.rotated = true;
                    self.chosenTableView!.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2));
                }
            }) 
            tableBoundsCheck(chosenTableView!);
           
        // Segue to edit table view if edit option is pressed
        }else if (sender.identifier == "editTableSegue") {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "EditFloorPlanTableSegue", sender: self);
            }
        }
        
        // Save data
        (tabBarController as! TabBarController).savePlans();
        updateContentView();
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If an edit table button is pressed
        if let destinationViewController = segue.destination as? TableViewController {
            destinationViewController.tablePlan = tablePlan!;
            destinationViewController.table = chosenTable!;
            destinationViewController.floorPlanPush = true;
        
        // If going to pick a table, pass on the table plan
        }else if let navController = segue.destination as? UINavigationController, let destinationViewController = navController.topViewController as? TablePickerViewController {
            destinationViewController.tablePlan = tablePlan;
            
        }
    }
    
    // MARK: - Messages
    
    let floorPlanInfo = "Hold on the screen to add a table. When added, hold on a table to move it around the view. Tap on a table to delete, rotate, or edit it. Drag a table to the right or bottom to increase the floor plans' outer limits.";

}
