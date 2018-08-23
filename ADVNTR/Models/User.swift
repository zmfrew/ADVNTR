//
//  User.swift
//  ADVNTR
//
//  Created by Zachary Frew on 8/20/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit

class User {
    
    // MARK: - Properties
    var uid: String?
    var email: String?
    var displayName: String
    var image: UIImage
    var totalActivityDuration: Int // seconds
    var totalActivityDistance: Int // meters
    var totalElevationChange: Int // meters
    var totalActivityCount: Int
    var preferredActivityType: String
    var defaultUnits: String
    
    // MARK: - Initializers
    init(uid: String, email: String?, displayName: String, image: UIImage, totalActivityDuration: Int, totalActivityDistance: Int, totalElevationChange: Int, totalActivityCount: Int, preferredActivityType: String, defaultUnits: String) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.image = image
        self.totalActivityDuration = totalActivityDuration
        self.totalActivityDistance = totalActivityDistance
        self.totalElevationChange = totalElevationChange
        self.totalActivityCount = totalActivityCount
        self.preferredActivityType = preferredActivityType
        self.defaultUnits = defaultUnits
    }
    
}
