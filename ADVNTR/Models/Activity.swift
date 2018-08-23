//
//  Activity.swift
//  ADVNTR
//
//  Created by Zachary Frew on 8/20/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit

class Activity {
    
    // MARK: - Properties
    var uid: String
    let type: String
    var name: String // leave as var in case you need to change the name of the activity
    let distance: Double // meters
    let averageSpeed: Double // meters/sec
    let elevationChange: Int // meters
    let averageHeartRate: Int? // beats per minute
    let pace: Int // seconds/meter
    let timestamp: String // format to show "MM/DD/YY [MORNING/AFTERNOON/EVENING]"
    let duration: Int // seconds
    let activitySnapshotImage: UIImage // picture of the map with polyline showing the route
    
    // MARK: - Initializers
    init(uid: String, type: String, name: String, distance: Double, averageSpeed: Double, elevationChange: Int, averageHeartRate: Int, pace: Int, timestamp: String, duration: Int, activitySnapshotImage: UIImage) {
        self.uid = uid
        self.type = type
        self.name = name
        self.distance = distance
        self.averageSpeed = averageSpeed
        self.elevationChange = elevationChange
        self.averageHeartRate = averageHeartRate
        self.pace = pace
        self.timestamp = timestamp
        self.duration = duration
        self.activitySnapshotImage = activitySnapshotImage
    }
    
}
