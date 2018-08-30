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
    @IBOutlet weak var activityDurationLabel: UILabel!
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
        activityDurationLabel.text = "\(FormatDisplay.time(activity.duration))"
        
        let distanceMeasurement = Measurement(value: Double(activity.distance), unit: UnitLength.meters)
        let distanceToDisplay = UserController.shared.user.defaultUnits == "imperial" ? ActivityUnitConverter.milesFromMeters(distance: distanceMeasurement) : ActivityUnitConverter.kilometersFromMeters(distance: distanceMeasurement)
        let distanceUnits = UserController.shared.user.defaultUnits == "imperial" ? "mi" : "km"
        activityDistanceLabel.text = "\(distanceToDisplay.roundedDoubleString)\(distanceUnits)"
        
        if activity.type == "run" {
            let distance = Measurement(value: Double(activity.distance), unit: UnitLength.meters)
            let speedUnit = UserController.shared.user.defaultUnits == "imperial" ? UnitSpeed.milesPerHour : UnitSpeed.kilometersPerHour
            let pace = ActivityUnitConverter.formatPace(distance: distance, seconds: activity.duration, outputUnit: speedUnit)
            activityDistanceLabel.text = "\(distanceToDisplay.roundedDoubleString) \(distanceUnits)"
            averageSpeedLabel.text = "Average pace: \(pace) / \(distanceUnits)"
        } else {
            let speedUnits = UserController.shared.user.defaultUnits == "imperial" ? "mph" : "km/h"
            averageSpeedLabel.text = "Average speed: \(activity.averageSpeed.roundedDoubleString)\(speedUnits)"
        }
    }
    
}
