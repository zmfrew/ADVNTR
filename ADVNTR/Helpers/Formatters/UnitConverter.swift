//
//  UnitConverter.swift
//  ADVNTR
//
//  Created by Zachary Frew on 8/22/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import Foundation

class ActivityUnitConverter: UnitConverter {
    
    static func milesPerHourFromMetersPerSecond(seconds: Int, meters: Measurement<UnitLength>) -> Double {
        let hours = Double(seconds) / 3600
        let miles = meters.converted(to: .miles)
        return miles.value / hours
    }
    
    static func kilometersPerHourFrom(seconds: Int, distance: Measurement<UnitLength>) -> Double {
        let kilometers = distance.value / 100
        let hours = Double(seconds) / 3600
        return kilometers / hours
    }
    
    static func pacePerMile(seconds: Int, meters: Measurement<UnitLength>) -> String {
        let mph = milesPerHourFromMetersPerSecond(seconds: seconds, meters: meters)
        var secondsRemaining = seconds
        // Get the remainder of 3600 / seconds.
        let hours = 3600 % secondsRemaining
        var hoursPerMile = 0
        // Convert meters to miles.
        let miles = meters.converted(to: UnitLength.miles).value
        // Check if hours is greater than 0, and find hoursPerMile. Decrement secondsRemaining by the hoursPerMile * miles * seconds (hours * 3600).
        if hours > 0 {
            hoursPerMile = Int(miles) % hours
            secondsRemaining = secondsRemaining - hoursPerMile * Int(miles) * 3600
        }
        
        // Repeat the above steps for minutes.
        let minutes = secondsRemaining / 60
        var minutesPerMile = 0
        if minutes > 0 {
            minutesPerMile = Int(miles) % minutes
            secondsRemaining = secondsRemaining - minutesPerMile * Int(miles) * 60
        }
        
        // Check if seconds remaining is greater than 0. If it is, decrement secondsRemaining by the distance traveled * seconds. Finally, divide the secondsRemaining by the speed the user was traveling and round to nearest whole number.
        if secondsRemaining > 0 {
            secondsRemaining = secondsRemaining - Int(miles) * 60
            secondsRemaining =  secondsRemaining / Int(mph.rounded())
            print(secondsRemaining)
        }
        print(secondsRemaining)
        // Return the pace as a string with format HH:MM:SS.
        if hoursPerMile == 0 {
            return "\(minutesPerMile):\(secondsRemaining)"
        }
        return "\(hoursPerMile):\(minutesPerMile):\(secondsRemaining)"
    }
    
    static func pacePerKilometer() {
        
    }
    
}
