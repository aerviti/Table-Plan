//
//  PickerTextField.swift
//  Table Plan
//
//  Created by Alex Erviti on 9/28/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class PickerTextField: UITextField {

    /* Stops user from editing the text field manually through actions. */
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        //Is this necessary? Caused crash
        //self.resignFirstResponder();
        return false;
    }
    
    /* Stops user from editing field with an accessory keyboard. */
    override func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
        self.resignFirstResponder();
        return false;
    }
    
    /* Hides caret. */
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero;
    }
}
