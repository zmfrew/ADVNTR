//
//  ActivityHistoryViewController.swift
//  ADVNTR
//
//  Created by Zachary Frew on 8/20/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit

class ActivityHistoryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func runButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func hikeButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func bikeButtonTapped(_ sender: UIButton) {
    }
    
    
    // MARK: - Navigation

    // Set the current activity type for the selected activity table view.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? SelectedActivityListViewController else { return }
        
        if segue.identifier == "toHikeDetails" {
            destinationVC.activityType = "hike"
        } else if segue.identifier == "toBikeDetails" {
            destinationVC.activityType = "bike"
        } else {
            destinationVC.activityType = "bike"
        }
    }
}
