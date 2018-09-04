//
//  CountdownViewController.swift
//  ADVNTR
//
//  Created by Zachary Frew on 9/4/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var countdownLabel: UILabel!
    
    // MARK: - Properties
    var countdownTimer = Timer()
    var seconds = 4
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        countdown()
    }
    
    // MARK: - Methods
    func countdown() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimerLabel() {
        seconds -= 1
        countdownLabel.text = seconds > 0 ? "\(seconds)" : "Go!"
        
        if seconds == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
