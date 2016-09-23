//
//  TablePlanDocument.swift
//  Table Plan
//
//  Created by Alex Erviti on 8/17/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class TablePlanDocument: UIDocument {
    
    var tablePlans: [TablePlan] = [TablePlan]();
    
    override func contents(forType typeName: String) throws -> Any {
        return NSKeyedArchiver.archivedData(withRootObject: tablePlans);
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let userContent = contents as? Data, let loadedTablePlans = NSKeyedUnarchiver.unarchiveObject(with: userContent) as? [TablePlan] {
            self.tablePlans = loadedTablePlans;
        }
    }
    
}
