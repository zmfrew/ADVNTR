//
//  LocationManager.swift
//  ADVNTR
//
//  Created by Zachary Frew on 8/20/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager {
    
    // MARK: - Singleton
    static let shared = CLLocationManager() ; private init() { }
    
}
