//
//  AddCustomActivityTableViewController.swift
//  ADVNTR
//
//  Created by Owen Henley on 8/24/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit
import SwiftEntryKit

class AddCustomActivityTableViewController: UITableViewController {
    
    // MARK: - Properties
    var distanceFirstDigit: Int?
    var distanceSecondDigit: Double?
    var distanceUnits: String?
    var durationHours: Int?
    var durationMinutes: Int?
    var durationSeconds: Int?
    
    // Distance
    var unitDistance: [Int] {
        var unitDistance: [Int] = []
        for number in 0...99 {
            unitDistance.append(number)
        }
        return unitDistance
    }
    
    var unitDistanceFraction: [Double] {
        return [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
    }
    
    var units: [String] {
        return ["Km's", "Miles"]
    }
    
    // Duration
    var hours: [Int] {
        var hours: [Int] = []
        for number in 0...23 {
            hours.append(number)
        }
        return hours
    }
    
    var minutes: [Int] {
        var minutes: [Int] = []
        for number in 0...59 {
            minutes.append(number)
        }
        return minutes
    }
    
    var seconds: [Int] {
        var seconds: [Int] = []
        for number in 0...59 {
            seconds.append(number)
        }
        return seconds
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var activityTitleTextField: UITextField!
    @IBOutlet weak var distancePickerView: UIPickerView!
    @IBOutlet weak var durationPickerView: UIPickerView!
    @IBOutlet weak var activityTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImageView(image: UIImage(named: "DefaultNewActivity"))
        backgroundImage.frame = self.tableView.frame
        backgroundImage.contentMode = .scaleToFill
        backgroundImage.clipsToBounds = false
        self.tableView.backgroundView = backgroundImage;
        
        distancePickerView.delegate = self
        durationPickerView.delegate = self
        
        distancePickerView.dataSource = self
        durationPickerView.dataSource = self
    }
    
    // MARK: - Actions
    
    @IBAction func activityDatePicker(_ sender: UIDatePicker) {
    }
    
    @IBAction func saveActivityButtonTapped(_ sender: UIButton) {
        
        let activityType = setActivityTypeForActivityCreation(activityTypeSegmentedControl.selectedSegmentIndex)
        
        let date = datePicker.date
        // Convert to String fuckhead
        // let timestamp =
        
        let hour = date.getHour(from: date)
        let timeOfDay = date.getTimeOfDay(from: hour)
        let title = "\(timeOfDay) - \(activityType)"
        let name = activityTitleTextField.text ?? title
        
        var unitLength: UnitLength?
        if distanceUnits == "Km's" {
            unitLength = UnitLength.kilometers
        } else {
            unitLength = UnitLength.miles
        }
        
        let distanceLength = ((Double(distanceFirstDigit ?? 0)) + (distanceSecondDigit ?? 0))
        let distance = ActivityUnitConverter.convertToMeters(from: unitLength!, distance: distanceLength)
        
        let hours = durationHours ?? 0
        let minutes = durationMinutes ?? 0
        let seconds = durationSeconds ?? 0
        
        let duration = (hours * 3600) + (minutes * 60) + seconds
        
        let averageSpeed = ActivityUnitConverter.speed(distance: distance, seconds: duration)
        
        let image = UIImage(named: "defaultProfile")
        
        ActivityController.shared.saveActivity(type: activityType, name: name, distance: Int(distance.value), averageSpeed: averageSpeed.value, elevationChange: 0, timestamp: date.stringValue(from: date), duration: duration, image: image!) { (success) in
            
            if success {
                let message = MessageController.shared.createSuccessAlertWith(title: "New activity saved.", description: "Great job!")
                
                DispatchQueue.main.async {
                    SwiftEntryKit.display(entry: message.0, using: message.1)
                    self.tabBarController?.selectedIndex = 1
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    // Custom Header Color
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view:UIView, forSection: Int) {
        if let tableViewHeaderFooterView = view as? UITableViewHeaderFooterView {
            tableViewHeaderFooterView.textLabel?.textColor = UIColor.white
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - PickerView Delegte
extension AddCustomActivityTableViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            switch component {
            case 0:
                return String(unitDistance[row])
            case 1:
                var unitDistanceFractionAsString = String(unitDistanceFraction[row])
                unitDistanceFractionAsString.removeFirst()
                return unitDistanceFractionAsString
            case 2:
                return String(units[row])
            default:
                return ""
            }
        } else if pickerView.tag == 2 {
            switch component {
            case 0:
                var hoursAsString = String(hours[row])
                hoursAsString.append(" h")
                return hoursAsString
            case 1:
                var minutesAsString = String(minutes[row])
                minutesAsString.append(" m")
                return minutesAsString
            case 2:
                var secondsAsString = String(seconds[row])
                secondsAsString.append(" s")
                return secondsAsString
            default:
                return ""
            }
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            switch component {
            case 0:
                self.distanceFirstDigit = unitDistance[pickerView.selectedRow(inComponent: 0)]
            case 1:
                self.distanceSecondDigit = unitDistanceFraction[pickerView.selectedRow(inComponent: 1)]
            case 2:
                self.distanceUnits = units[pickerView.selectedRow(inComponent: 2)]
            default:
                return
            }
        }
        
        if pickerView.tag == 2 {
            switch component {
            case 0:
                self.durationHours = hours[pickerView.selectedRow(inComponent: 0)]
            case 1:
                self.durationMinutes = minutes[pickerView.selectedRow(inComponent: 1)]
            case 2:
                self.durationSeconds = seconds[pickerView.selectedRow(inComponent: 2)]
            default:
                return
            }
        }
    }
}

// MARK: - PickerView Datasource
extension AddCustomActivityTableViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            switch component {
            case 0:
                return unitDistance.count
            case 1:
                return unitDistanceFraction.count
            case 2:
                return units.count
            default:
                return 0
            }
        } else if pickerView.tag == 2 {
            switch component {
            case 0:
                return hours.count
            case 1:
                return minutes.count
            case 2:
                return seconds.count
            default:
                return 0
            }
        }
        return 0
    }
    
    func setActivityTypeForActivityCreation(_ index: Int) -> String {
        switch (index) {
        case 0:
            return "run"
        case 1:
            return "hike"
        case 2:
            return "bike"
        default:
            return "run"
        }
    }
}

// MARK: Successful Custom Activity Alert
extension AddCustomActivityTableViewController {
    
}

// MARK: Error Adding Custom Activity Alert (Boring iOS SDK AlertController)
extension AddCustomActivityTableViewController {
    
}
