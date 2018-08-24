//
//  ActivityUnitConverter.swift
//  ADVNTR
//
//  Created by Zachary Frew on 8/22/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import Foundation

class ActivityUnitConverter: UnitConverter {
    
    static func milesPerHourFromMetersPerSecond(seconds: Int, meters: Measurement<UnitLength>) -> Double {
        let hours = Double(seconds) / 3600
        let miles = milesFromMeters(distance: meters)
        return miles / hours
    }
    
    static func kilometersPerHourFrom(seconds: Int, distance: Measurement<UnitLength>) -> Double {
        let kilometers = kilometersFromMeters(distance: distance)
        let hours = Double(seconds) / 3600
        return kilometers / hours
    }
    
    static func speed(distance: Measurement<UnitLength>, seconds: Int) -> Measurement<UnitSpeed> {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.providedUnit]
        let speedMagnitude = seconds != 0 ? distance.value / Double(seconds) : 0
        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
        return speed
    }
    
    static func formatPace(distance: Measurement<UnitLength>, seconds: Int, outputUnit: UnitSpeed) -> String  {
        let currentSpeed = speed(distance: distance, seconds: seconds).converted(to: outputUnit).value
        let minutes = Int(currentSpeed)
        let seconds = Int((currentSpeed.roundTo(places: 2) - Double(minutes)) * 60)
        return "\(minutes):\(seconds)"
    }
    
    static func kilometersFromMeters(distance: Measurement<UnitLength>) -> Double {
        return distance.value / 100
    }
    
    static func milesFromMeters(distance: Measurement<UnitLength>) -> Double {
        return distance.converted(to: .miles).value
    }
    
}