//
//  ForgotPasswordViewController.swift
//  ADVNTR
//
//  Created by Owen Henley & Jeter Pow on 8/23/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit
import SwiftEntryKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - Actions
    @IBAction func resetPasswordButtonTapped(_ sender: UIButton) {
        guard let email = emailAddressTextField.text, !email.isEmpty else { return }
        UserController.shared.resetPasswordForUserWith(email: email) { (success, error) in
            if success {
                let title = "Password reset email sent"
                let description = "Please check your email to reset your ADVNTR password."
                let message = MessageController.shared.createSuccessAlertWith(title: title, description: description)
                let entry = message.0
                var attributes = message.1
                
                // Describe the actions to occur when the alert disappears. In this case, after being
                // notified that their sign up was successful, the user will be taken back to the
                // SignUpViewController ready for them to sign in with their new password.
                attributes.lifecycleEvents.didDisappear = {
                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.3, execute: {
                        self.performSegue(withIdentifier: "unwindToSignIn", sender: self)
                    })
                }
                
                // Display the alert
                DispatchQueue.main.async {
                    SwiftEntryKit.display(entry: entry, using: attributes)
                }
                
            } else {
                if let errorCode = AuthErrorCode(rawValue: (error?._code)!) {
                    switch errorCode {
                    case .invalidEmail:
                        let alert = MessageController.shared.createAuthErrorAlertWith(title: "Email Error", description: errorCode.errorMessage)
                        DispatchQueue.main.async {
                            SwiftEntryKit.display(entry: alert.0, using: alert.1)
                        }
                        
                    case .networkError:
                        let alert = MessageController.shared.createAuthErrorAlertWith(title: "Network Error", description: errorCode.errorMessage)
                        DispatchQueue.main.async {
                            SwiftEntryKit.display(entry: alert.0, using: alert.1)
                        }
                        
                    case .userDisabled:
                        let alert = MessageController.shared.createAuthErrorAlertWith(title: "Account Error", description: errorCode.errorMessage)
                        DispatchQueue.main.async {
                            SwiftEntryKit.display(entry: alert.0, using: alert.1)
                        }
                        
                    default:
                        let alert = MessageController.shared.createAuthErrorAlertWith(title: "Unknown Error", description: errorCode.errorMessage)
                        DispatchQueue.main.async {
                            SwiftEntryKit.display(entry: alert.0, using: alert.1)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
        self.view.frame.origin.y = 0
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


