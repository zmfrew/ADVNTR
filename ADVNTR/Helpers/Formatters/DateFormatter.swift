//
//  DateFormatter.swift
//  ADVNTR
//
//  Created by Zachary Frew on 8/23/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import Foundation

extension Date {
    
    func stringValue(from date: Date) -> String {
        let hour = getHour(from: date)
        let timeOfDay = getTimeOfDay(from: hour)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: self)
        return "\(timeOfDay) \(dateString)"
    }
    
    func getHour(from date: Date) -> Int {
        return Calendar.current.component(.hour, from: Date())
    }
    
    func getTimeOfDay(from hour: Int) -> String {
        if hour >= 17 && hour <= 24 {
            return "Evening"
        } else if hour >= 12  && hour < 17 {
            return "Afternoon"
        } else {
            return "Morning"
        }
    }
    
}

