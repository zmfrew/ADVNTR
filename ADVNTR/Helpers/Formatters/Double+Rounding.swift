//
//  Double+Rounding.swift
//  ADVNTR
//
//  Created by Zachary Frew on 8/22/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import Foundation

extension Double {
    func roundTo(places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        return Darwin.round(self * multiplier) / multiplier
    }
}
