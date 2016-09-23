//
//  AddMultipleGuestsTableViewController.swift
//  Table Planner
//
//  Created by Alex Erviti on 6/24/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import UIKit

class AddMultipleGuestsTableViewController: UITableViewController, UITextViewDelegate {

    // MARK: Properties
    @IBOutlet weak var textView: UITextView!
    
    var guestArray : [Guest]? = nil;
    
    // MARK: - View Prep
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the text view delegate
        textView.delegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = getTextViewHeight(textView.text);
        if (height < 100) {
            return 130
        }else {
            return height + 30;
        }
    }
    
    /* Helper function that returns the height that a string will occupy in a text view. */
    fileprivate func getTextViewHeight(_ string: String) -> CGFloat {
        let attributes = [NSFontAttributeName: textView.font!] ;
        let text = NSMutableAttributedString(string: string, attributes: attributes);
        let width = view.frame.width - 16;
        let size = text.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil);
        return size.height;
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    // MARK: - TextView Delegate
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates();
        tableView.endUpdates();
        
        //scrollToCursor
    }
    
    func scrollToCursor(_ textView: UITextView) {
        var cursorRect = textView.caretRect(for: textView.selectedTextRange!.start);
        cursorRect = tableView.convert(cursorRect, from: textView);
        
    }
    
    // MARK: - Button Actions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil);
    }
    
    // MARK: - Navigation

    // Create array of guests to be added when unwinded
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let textViewString = textView.text;
        guestArray = [Guest]();
        let guests = textViewString?.characters.split(separator: ",").map(String.init);
        for guest in guests! {
            let names = guest.characters.split(separator: " ").map(String.init);
            if (names.count > 1) {
                guestArray! += [Guest(firstName: names[0], lastName: names[1], table: nil, seat: nil)];
            }
        }
    }

}
