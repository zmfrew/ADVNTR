//
//  Double+Rounding.swift
//  ADVNTR
//
//  Created by Zachary Frew on 8/22/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import Foundation

extension Double {
    var roundedDoubleString: String {
        return String(format: "%.2f", self)
    }
}
