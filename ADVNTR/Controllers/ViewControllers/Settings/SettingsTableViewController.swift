//
//  SettingsTableViewController.swift
//  ADVNTR
//
//  Created by Owen Henley on 8/22/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var unitsOfMeasureButton: UIButton!
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        unitsOfMeasureButton.setTitle(UserController.shared.user.defaultUnits, for: .normal)
    }
    
    // MARK: - Actions
    @IBAction func unitsOfMeasureButtonTapped(_ sender: UIButton) {
        UserController.shared.toggleDefaultUnits()
        unitsOfMeasureButton.setTitle(UserController.shared.user.defaultUnits, for: .normal)
    }

    // MARK: - Table view data source
    
    // Custom Header/Footer Color
//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view:UIView, forSection: Int) {
//        if let tableViewHeaderFooterView = view as? UITableViewHeaderFooterView {
//            tableViewHeaderFooterView.detailTextLabel?.textColor = UIColor.white
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
