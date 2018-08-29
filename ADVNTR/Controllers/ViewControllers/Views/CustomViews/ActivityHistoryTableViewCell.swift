//
//  ActivityHistoryTableViewCell.swift
//  ADVNTR
//
//  Created by Zachary Frew on 8/20/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit
import FirebaseUI

class ActivityHistoryTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var activitySnapshotImageView: UIImageView!
    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var activityDateLabel: UILabel!
    @IBOutlet weak var activityLengthLabel: UILabel!
    @IBOutlet weak var activityDistanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!

    // MARK: - Properties
    var activity: Activity? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Methods
    func updateViews() {
        guard let activity = activity else { return }
        
        // Get a reference to the image on Firebase Storage and then pass it directly into SDWebImage.
        let imageReference = ActivityController.usersActivityImagesReference.child(activity.uid)
        self.activitySnapshotImageView?.sd_setImage(with: imageReference)
        
        activityTitleLabel.text = activity.name
        activityDateLabel.text = activity.timestamp
        activityLengthLabel.text = "\(activity.distance)"
        // TODO: - Check if user preferences are Imperial or Metric, convert units accordingly, and display unit type to user.
        activityDistanceLabel.text = "\(activity.distance)"

        if activity.type == "run" {
            // Convert distance, which is an Int, to a measurement in meters to get the correct formatted pace.
            let distance = Measurement.init(value: Double(activity.distance), unit: UnitLength.meters)
            let pace = ActivityUnitConverter.formatPace(distance: distance, seconds: activity.duration, outputUnit: UnitSpeed.milesPerHour)
            averageSpeedLabel.text = "Average pace: \(pace)"
        } else {
            averageSpeedLabel.text = "Average speed: \(activity.averageSpeed)"
        }
    }
    
}
