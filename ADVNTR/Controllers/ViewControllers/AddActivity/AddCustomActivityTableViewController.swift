//
//  AddCustomActivityTableViewController.swift
//  ADVNTR
//
//  Created by Owen Henley on 8/24/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit

class AddCustomActivityTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var activityTitleTextField: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Actions
    
    @IBAction func activityDatePicker(_ sender: UIDatePicker) {
    }
    
    @IBAction func saveActivityButtonTapped(_ sender: UIButton) {
    }
    
    // MARK: - Table view data source
    
    // Custom Header Color
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view:UIView, forSection: Int) {
        if let tableViewHeaderFooterView = view as? UITableViewHeaderFooterView {
            tableViewHeaderFooterView.textLabel?.textColor = UIColor.white
        }
    }

 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: Successful Sign Up Alert
extension AddCustomActivityTableViewController {
    
}

// MARK: Error Signing Up Alert (Boring iOS SDK AlertController)
extension AddCustomActivityTableViewController {
    
}
