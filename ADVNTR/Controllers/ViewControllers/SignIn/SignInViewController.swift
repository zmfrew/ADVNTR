//
//  SignInViewController.swift
//  ADVNTR
//
//  Created by Owen Henley on 8/24/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Actions
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
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
