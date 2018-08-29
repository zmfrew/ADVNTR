//
//  SettingsTableViewController.swift
//  ADVNTR
//
//  Created by Owen Henley on 8/22/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var unitsOfMeasureButton: UIButton!
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        unitsOfMeasureButton.setTitle(UserController.shared.user.defaultUnits?.capitalized ?? "Imperial", for: .normal)
    }
    
    // MARK: - Actions
    @IBAction func unitsOfMeasureButtonTapped(_ sender: UIButton) {
        UserController.shared.toggleDefaultUnits()
        unitsOfMeasureButton.setTitle(UserController.shared.user.defaultUnits?.capitalized ?? "Metric", for: .normal)
        self.loadViewIfNeeded()
    }
    
}
