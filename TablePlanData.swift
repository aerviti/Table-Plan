//
//  TablePlanData.swift
//  Table Plan
//
//  Created by Alex Erviti on 5/23/17.
//  Copyright © 2017 Alejandro Erviti. All rights reserved.
//

import Foundation

class TablePlanData {
    
    // MARK: - Properties
    
    // Data Queue
    static let serialDataQueue = DispatchQueue(label: "com.alexerviti.TablePlan.dataQueue");
    
    //Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!;
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("TablePlans");
    
    
    
    //MARK: - NSCoding Saving
    
    //Saves the current set of table plans on the serialDataQueue
    static func saveTablePlans(_ plans: [TablePlan]) {
        serialDataQueue.async {
            let successfulSave = NSKeyedArchiver.archiveRootObject(plans, toFile: ArchiveURL.path);
            if !successfulSave {
                print("Save error...");
            }
        }
    }
    
    //Loads the saved set of table plans on the serialDataQueue
    static func loadTablePlans() -> [TablePlan]? {
        var plans: [TablePlan]?;
        serialDataQueue.sync {
            plans = NSKeyedUnarchiver.unarchiveObject(withFile: ArchiveURL.path) as? [TablePlan];
        }
        return plans;
    }
}
