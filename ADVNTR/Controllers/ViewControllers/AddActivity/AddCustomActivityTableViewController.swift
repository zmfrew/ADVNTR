//
//  AddCustomActivityTableViewController.swift
//  ADVNTR
//
//  Created by Owen Henley & Peter Gow on 8/24/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit

class AddCustomActivityTableViewController: UITableViewController {
    
    // MARK: - Properties
    
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
        return ["Kilometers", "Miles"]
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
       distancePickerView.delegate = self
       durationPickerView.delegate = self
        
       distancePickerView.dataSource = self
       durationPickerView.dataSource = self
    }
    
    // MARK: - Actions
    
    @IBAction func activityDatePicker(_ sender: UIDatePicker) {
    }
    
    @IBAction func saveActivityButtonTapped(_ sender: UIButton) {
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
            default:
                return ""
            }
        }
        return ""
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
}

// MARK: Successful Sign Up Alert
extension AddCustomActivityTableViewController {
    
}

// MARK: Error Signing Up Alert (Boring iOS SDK AlertController)
extension AddCustomActivityTableViewController {
    
}
