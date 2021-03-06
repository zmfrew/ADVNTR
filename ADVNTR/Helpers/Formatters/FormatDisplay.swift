//
//  FormatDisplay.swift
//  ADVNTR
//
//  Created by Zachary Frew on 8/22/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import Foundation

struct FormatDisplay {
    static func distance(_ distance: Double) -> String {
        let distanceMeasurement = Measurement(value: distance, unit: UnitLength.meters)
        return FormatDisplay.distance(distanceMeasurement)
    }
    
    static func distance(_ distance: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        formatter.numberFormatter = numberFormatter
        return formatter.string(from: distance)
    }
    
    static func time(_ seconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(seconds))!
    }
    
    static func roundToTwoDecimals(value: Double) -> String {
        let doubleFormatter = NumberFormatter()
        doubleFormatter.maximumFractionDigits = 2
        let stringValue = doubleFormatter.string(from: NSNumber(value: value))
        return stringValue ?? "\(value)"
    }
    
}
