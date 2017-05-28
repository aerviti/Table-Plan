//
//  TabBarController.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/24/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit
import Firebase;

class TabBarController: UITabBarController, GADBannerViewDelegate {
    
    //MARK: Properties
    var tablePlans: [TablePlan]!;
    var tablePlan: TablePlan!;
    var planIndexPath: IndexPath!;
    
    weak var buttonBackground: UIImageView? = nil;
    var hasAds: Bool!;
    lazy var adBanner: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait);
        adBannerView.adUnitID = "ca-app-pub-7464685312244302/4925120272";
        adBannerView.delegate = self;
        adBannerView.rootViewController = self;
        return adBannerView
    }()
    lazy var tabFrame: CGRect = {
        let yPos: CGFloat = self.tabBar.frame.origin.y - self.adBanner.frame.height;
        return CGRect(x: 0, y: yPos, width: self.adBanner.frame.width, height: self.adBanner.frame.height);
    }()
    lazy var noTabFrame: CGRect = {
        let yPos = self.view.frame.height - self.adBanner.frame.height;
        return CGRect(x: 0, y: yPos, width: self.adBanner.frame.width, height: self.adBanner.frame.height);
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBar.itemPositioning = .fill;
        addCenterButton();
        
        // Load in ads
        if (!UserDefaults.standard.bool(forKey: "RemoveAds")) {
            createAd();
            hasAds = true;
        }else {
            hasAds = false;
        }
    }
    
    
    func addCenterButton() {
        let buttonWidth = self.view.frame.width / 5.0;
        let buttonBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: 30));
        buttonBackground.image = UIImage(named: "tabBarBackground");
        buttonBackground.center = self.tabBar.center;
        buttonBackground.center.y -= tabBar.frame.height/2.2;
        buttonBackground.isHidden = false;
        view.addSubview(buttonBackground);
        self.buttonBackground = buttonBackground;
    }
    
    
    func removeAd() {
        if hasAds {
            adBanner.delegate = nil;
            adBanner.removeFromSuperview();
        }
    }
    
    
    func createAd() {
        adBanner.frame = tabFrame;
        view.addSubview(adBanner);
        let request = GADRequest();
        request.testDevices = [kGADSimulatorID, "67f3c63dadf4b21867f7e168428cddee"];
        adBanner.load(request);
    }
    
    
    override func viewDidLayoutSubviews() {
        if (buttonBackground != nil) {
            view.bringSubview(toFront: buttonBackground!);
        }
    }
    
    
    func hideCenterButton(_ animated: Bool) {
        if (animated) {
            UIView.animate(withDuration: 0.01, delay: 0, options: UIViewAnimationOptions(), animations: {self.buttonBackground!.alpha = CGFloat(0)}, completion: {(_) in});
            if hasAds { adBanner.frame = noTabFrame; }
        }
    }
    
    
    func showCenterButton(_ animated: Bool) {
        if (animated) {
            UIView.animate(withDuration: 0.01, delay: 0.15, options: UIViewAnimationOptions(), animations: {self.buttonBackground!.alpha = CGFloat(1)}, completion: {(_) in});
            if hasAds { adBanner.frame = tabFrame; }
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
    
    // Function called from TabBar's children to save tablePlan array that they do not have access to
    func savePlans() {
        TablePlanData.saveTablePlans(tablePlans);
    }

}
