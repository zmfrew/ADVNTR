//
//  User.swift
//  ADVNTR
//
//  Created by Zachary Frew & Jeter Pow on 8/20/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class User {
    
    var uid: String?
    var email: String?
    var displayName: String?
    var photoURL: String?
    var totalActivityDuration: Int? //seconds
    var totalActivityDistance: Int? //metres
    var totalElevationChange: Int? //metres
    var totalActivityCount: Int?
    var preferredActivityType: String? // run hike bike
    var defaultUnits: String? //metric or imperial
    
    // Totals for each individual activity type
    var totalRunDistance: Int? //metres
    var totalRunTime: Int? //seconds
    var totalRunElevationChange: Int? //metres
    var totalHikeDistance: Int? //metres
    var totalHikeTime: Int? //seconds
    var totalHikeElevationChange: Int? //metres
    var totalBikeDistance: Int? //metres
    var totalBikeTime: Int? //seconds
    var totalBikeElevationChange: Int? //metres
    
    // Keys
    fileprivate let uidKey = "uid"
    fileprivate let emailKey = "email"
    fileprivate let displayNameKey = "displayName"
    fileprivate let photoURLKey = "photoURL"
    static let totalActivityDurationKey = "totalActivityDuration"
    static let totalActivityDistanceKey = "totalActivityDistance"
    static let totalElevationChangeKey = "totalElevationChange"
    static let totalActivityCountKey = "totalActivityCount"
    fileprivate let preferredActivityTypeKey = "preferredActivityType"
    fileprivate let defaultUnitsKey = "defaultUnits"
    static let totalRunDistanceKey = "totalRunDistance"
    static let totalRunTimeKey = "totalRunTime"
    static let totalRunElevationChangeKey = "totalRunElevationChange"
    static let totalHikeDistanceKey = "totalHikeDistance"
    static let totalHikeTimeKey = "totalHikeTime"
    static let totalHikeElevationChangeKey = "totalHikeElevationChange"
    static let totalBikeDistanceKey = "totalBikeDistance"
    static let totalBikeTimeKey = "totalBikeTime"
    static let totalBikeElevationChangeKey = "totalBikeElevationChange"
    
    // Blank init to assist logging in anonymous users
    init() {
    }
    
    // Epic Memberwise Initialiser
    init(uid: String, email: String, displayName: String, photoURL: String, totalActivityDuration: Int, totalActivityDistance: Int, totalElevationChange: Int, totalActivityCount: Int, preferredActivityType: String, defaultUnits: String, totalRunDistance: Int, totalRunTime: Int, totalRunElevationChange: Int, totalHikeDistance: Int, totalHikeTime: Int, totalHikeElevationChange: Int, totalBikeDistance: Int, totalBikeTime: Int, totalBikeElevationChange: Int) {
        
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.totalActivityDuration = totalActivityDuration
        self.totalActivityDistance = totalActivityDistance
        self.totalElevationChange = totalElevationChange
        self.totalActivityCount = totalActivityCount
        self.preferredActivityType = preferredActivityType
        self.defaultUnits = defaultUnits
        self.totalRunDistance = totalRunDistance
        self.totalRunTime = totalRunTime
        self.totalRunElevationChange = totalRunElevationChange
        self.totalHikeDistance = totalHikeDistance
        self.totalHikeTime = totalHikeTime
        self.totalHikeElevationChange = totalHikeElevationChange
        self.totalBikeDistance = totalBikeDistance
        self.totalBikeTime = totalBikeTime
        self.totalBikeElevationChange = totalBikeElevationChange
    }
    
    // Turn a Firebase Database snapshot into an Activity model object
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String : AnyObject],
            let uid = value[uidKey] as? String,
            let email = value[emailKey] as? String,
            let displayName = value[displayNameKey] as? String,
            let photoURL = value[photoURLKey] as? String,
            let totalActivityDuration = value[User.totalActivityDurationKey] as? Int,
            let totalActivityDistance = value[User.totalActivityDistanceKey] as? Int,
            let totalElevationChange = value[User.totalElevationChangeKey] as? Int,
            let totalActivityCount = value[User.totalActivityCountKey] as? Int,
            let preferredActivityType = value[preferredActivityTypeKey] as? String,
            let defaultUnits = value[defaultUnitsKey] as? String,
            let totalRunDistance = value[User.totalRunDistanceKey] as? Int,
            let totalRunTime = value[User.totalRunTimeKey] as? Int,
            let totalRunElevationChange = value[User.totalRunElevationChangeKey] as? Int,
            let totalHikeDistance = value[User.totalHikeDistanceKey] as? Int,
            let totalHikeTime = value[User.totalHikeTimeKey] as? Int,
            let totalHikeElevationChange = value[User.totalHikeElevationChangeKey] as? Int,
            let totalBikeDistance = value[User.totalBikeDistanceKey] as? Int,
            let totalBikeTime = value[User.totalBikeTimeKey] as? Int,
            let totalBikeElevationChange = value[User.totalBikeElevationChangeKey] as? Int
            else { return nil }
        
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.totalActivityDuration = totalActivityDuration
        self.totalActivityDistance = totalActivityDistance
        self.totalElevationChange = totalElevationChange
        self.totalActivityCount = totalActivityCount
        self.preferredActivityType = preferredActivityType
        self.defaultUnits = defaultUnits
        self.totalRunDistance = totalRunDistance
        self.totalRunTime = totalRunTime
        self.totalRunElevationChange = totalRunElevationChange
        self.totalHikeDistance = totalHikeDistance
        self.totalHikeTime = totalHikeTime
        self.totalHikeElevationChange = totalHikeElevationChange
        self.totalBikeDistance = totalBikeDistance
        self.totalBikeTime = totalBikeTime
        self.totalBikeElevationChange = totalBikeElevationChange
    }
    
    init?(result: AuthDataResult) {
        self.uid = result.user.uid
        self.email = result.user.email
    }
    
}








