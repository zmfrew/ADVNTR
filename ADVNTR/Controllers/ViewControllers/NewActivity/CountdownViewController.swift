//
//  CountdownViewController.swift
//  ADVNTR
//
//  Created by Zachary Frew on 9/4/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit
import SRCountdownTimer

class CountdownViewController: UIViewController {
    
    @IBOutlet weak var countdownTimer: SRCountdownTimer!
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCountdownTimer()
        countdownTimer.start(beginingValue: 3, interval: 1)
        dismissView()
    }
    
    func setupCountdownTimer() {
        countdownTimer.labelFont = UIFont(name: "Avenir Next", size: 50.0)
        countdownTimer.labelTextColor = UIColor.white
        countdownTimer.timerFinishingText = "Go!"
        countdownTimer.lineWidth = 4
    }
    
    func dismissView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.75) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
