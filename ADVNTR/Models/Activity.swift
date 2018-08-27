//
//  Activity.swift
//  ADVNTR
//
//  Created by Zachary Frew on 8/20/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Activity {
    
    // Firebase references
    let reference: DatabaseReference?
    let key: String
    
    // Firebase parameters
    var uid: String
    let type: String
    let name: String
    let distance: Int //metres
    let averageSpeed: Double //metres/sec
    let elevationChange: Int //metres
    var averageHeartRate: String //bpm
    let timestamp: String
    let duration: Int //seconds
    let imageURL: String
    
    // Keys
    fileprivate let uidKey = "uid"
    fileprivate let typeKey = "type"
    fileprivate let nameKey = "name"
    fileprivate let distanceKey = "distance"
    fileprivate let averageSpeedKey = "averageSpeed"
    fileprivate let elevationChangeKey = "elevationChange"
    fileprivate let averageHeartRateKey = "averageHeartRate"
    fileprivate let timestampKey = "timestamp"
    fileprivate let durationKey = "duration"
    fileprivate let imageURLKey = "imageURL"
    
    init(type: String, name: String, distance: Int, key: String = "", uid: String = "", averageSpeed: Double, elevationChange: Int, averageHeartRate: String, timestamp: String, duration: Int, imageURL: String) {
        self.reference = nil
        self.type = type
        self.name = name
        self.distance = distance
        self.key = key
        self.uid = uid
        self.averageSpeed = averageSpeed
        self.elevationChange = elevationChange
        self.averageHeartRate = averageHeartRate
        self.timestamp = timestamp
        self.duration = duration
        self.imageURL = imageURL
    }
    
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String : AnyObject],
            let uid = value[uidKey] as? String,
            let type = value[typeKey] as? String,
            let name = value[nameKey] as? String,
            let distance = value[distanceKey] as? Int,
            let averageSpeed = value[averageSpeedKey] as? Double,
            let elevationChange = value[elevationChangeKey] as? Int,
            let averageHeartRate = value[averageHeartRateKey] as? String,
            let timestamp = value[timestampKey] as? String,
            let duration = value[durationKey] as? Int,
            let imageURL = value[imageURLKey] as? String
            else { return nil }
        
        // Reference is the DatabaseReference to the data ('snapshot').
        // Key is the name of the JSON Key (e.g. bike, hike, run).
        // UID is the unique reference to each run/hike/bike that allows for deleting.
        self.reference = snapshot.ref
        self.key = snapshot.key
        self.type = type
        self.name = name
        self.distance = distance
        self.uid = uid
        self.averageSpeed = averageSpeed
        self.elevationChange = elevationChange
        self.averageHeartRate = averageHeartRate
        self.timestamp = timestamp
        self.duration = duration
        self.imageURL = imageURL
    }
    
    func toAnyObject() -> Any {
        return [
            typeKey: type,
            nameKey: name,
            distanceKey: distance,
            uidKey: uid,
            averageSpeedKey: averageSpeed,
            elevationChangeKey: elevationChange,
            averageHeartRateKey: averageHeartRate,
            timestampKey: timestamp,
            durationKey: duration,
            imageURLKey: imageURL
        ]
    }
}

