//
//  ActivityDetailViewController.swift
//  ADVNTR
//
//  Created by Zachary Frew & Owen Henley on 8/20/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit

class ActivityDetailViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var activitySnapshotImageView: UIImageView!
    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var activityDateLabel: UILabel!
    @IBOutlet weak var activityLengthLabel: UILabel!
    @IBOutlet weak var activityDistanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
