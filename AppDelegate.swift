//
//  AppDelegate.swift
//  Table Planner
//
//  Created by Alex Erviti on 5/20/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Initialize kit
        Fabric.sharedSDK().debug = true;
        Fabric.with([Crashlytics.self]);
        
        /*
        // Register iCloud token
        let userDefaults = NSUserDefaults.standardUserDefaults();
        let iCloudToken = NSFileManager.defaultManager().ubiquityIdentityToken;
        if (iCloudToken != nil) {
            let tokenData = NSKeyedArchiver.archivedDataWithRootObject(iCloudToken!);
            userDefaults.setObject(tokenData, forKey: "com.apple.Table-Plan.UbiquityIdentityToken");
        }else {
            userDefaults.removeObjectForKey("com.apple.Table-Plan.UbiquityIdentityToken");
        }
        
        // Observe if iCloud capabilities are changed on the phone
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.iCloudAccountAvailabilityChanged(_:)), name: NSUbiquityIdentityDidChangeNotification, object: nil);
        
        // If app launched for the first time with iCloud capabilities, ask for iCloud permission
        if (iCloudToken != nil) && !userDefaults.boolForKey("LaunchWithICloudOcurred") {
            userDefaults.setBool(true, forKey: "LaunchWithICloudOcurred");
            let storageAlert = UIAlertController(title: "Choose Storage Option", message: "Should documents be stored in iCloud and made available on all your devices?", preferredStyle: .Alert);
            let localOnlyAction = UIAlertAction(title: "Local Only", style: .Cancel, handler: nil);
            let useICloudAction = UIAlertAction(title: "Use iCloud", style: .Default) { _ in
                userDefaults.setBool(true, forKey: "iCloudOn");
            }
            storageAlert.addAction(localOnlyAction);
            storageAlert.addAction(useICloudAction);
            self.window?.rootViewController?.presentViewController(storageAlert, animated: true, completion: nil);
        }
        */
        
        return true
    }
    
    func iCloudAccountAvailabilityChanged(_ sender: AnyObject) {
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    

}

