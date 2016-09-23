//
//  TabBarController.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/24/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    //MARK: Properties
    var tablePlans: [TablePlan]!;
    var tablePlan: TablePlan!;
    var planIndexPath: IndexPath!;
    
    var buttonBackground: UIImageView? = nil;

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBar.itemPositioning = .fill;
        addCenterButton();
    }
    
    func addCenterButton() {
        let buttonWidth = self.view.frame.width / 5.0;
        buttonBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: 30));
        buttonBackground!.image = UIImage(named: "tabBarBackground");
        buttonBackground!.center = self.tabBar.center;
        buttonBackground!.center.y -= tabBar.frame.height/2.2;
        buttonBackground!.isHidden = false;
        view.addSubview(buttonBackground!);
    }
    
    override func viewDidLayoutSubviews() {
        if (buttonBackground != nil) {
            view.bringSubview(toFront: buttonBackground!);
        }
    }
    
    func hideCenterButton(_ animated: Bool) {
        if (animated) {
            UIView.animate(withDuration: 0.01, delay: 0, options: UIViewAnimationOptions(), animations: {self.buttonBackground!.alpha = CGFloat(0)}, completion: {(_) in});
            }
    }
    
    func showCenterButton(_ animated: Bool) {
        if (animated) {
            UIView.animate(withDuration: 0.01, delay: 0.15, options: UIViewAnimationOptions(), animations: {self.buttonBackground!.alpha = CGFloat(1)}, completion: {(_) in});
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    //Unhides the navigation bar when the tab bar controller appears
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false;
    }
    
    // MARK: - NSCoding
    
    func savePlans() {
        let successfulSave = NSKeyedArchiver.archiveRootObject(tablePlans, toFile: TablePlan.ArchiveURL.path);
        if !successfulSave {
            print("Save error...");
        }
    }

}
