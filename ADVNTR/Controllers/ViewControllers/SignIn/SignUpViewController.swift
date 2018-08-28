//
//  SignUpViewController.swift
//  ADVNTR
//
//  Created by Owen Henley & Jeter Pow on 8/23/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftEntryKit

class SignUpViewController: UIViewController {
    
    // MARK: Properties
    
    var isSuccessfulSignUp = false
    var activityType: String?
    
    // MARK: - Outlets
    
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        signUpNewUser()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Methods
    
    // Convenience function that handles creating a new authenticated user from an anonymous user.
    // This function is called in shouldPerformSegue so that errors are handled before the user
    // is returned to the app to see their new Activity History.
    func signUpNewUser() {
        
        // Show an alert if text is not entered in one or both fields.
        // TODO: Handle password complexity requirements.
        guard let displayName = displayNameTextField.text, !displayName.isEmpty,
            let email = emailAddressTextField.text, !email.isEmpty, isValidEmail(email: email),
            let password = passwordTextField.text, !password.isEmpty else { createEmptyFieldAlert() ; return }
        
        UserController.shared.createAuthenticatedUserWith(displayName: displayName, email: email, password: password) { (success, error) in
            if success {
                
                self.isSuccessfulSignUp = true
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "successfulSignUp", sender: self)
                }
            } else {
                if let errorCode = AuthErrorCode(rawValue: (error?._code)!) {
                    switch errorCode {
                    case .emailAlreadyInUse:
                        let alert = MessageController.shared.createAuthErrorAlertWith(title: "Email Error", description: errorCode.errorMessage)
                        DispatchQueue.main.async {
                            SwiftEntryKit.display(entry: alert.0, using: alert.1)
                        }
                        
                    case .invalidEmail:
                        let alert = MessageController.shared.createAuthErrorAlertWith(title: "Email Error", description: errorCode.errorMessage)
                        DispatchQueue.main.async {
                            SwiftEntryKit.display(entry: alert.0, using: alert.1)
                        }
                        
                    case .wrongPassword:
                        let alert = MessageController.shared.createAuthErrorAlertWith(title: "Incorrect Password", description: errorCode.errorMessage)
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
    
    // Prevents the unwind segue from performing unless the user's sign up/in has been successful.
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "successfulSignUp" {
            if self.isSuccessfulSignUp {
                return true
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "successfulSignUp" {
            let destinationVC = segue.destination as? SelectedActivityDetailsTableViewController
            guard let activityType = activityType else { return }
            destinationVC?.activityType = activityType
        }
    }
}

// MARK: Email Validator Extension
// Confirms that the entered email is of the correct format, including two letter domains.
extension SignUpViewController {
    
    func isValidEmail(email:String?) -> Bool {
        guard email != nil else { return false }
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
}

// MARK: Empty Sign Up Fields Alert Extension
// Called when the user hasn't entered text in either or both of the sign up/in text fields.
extension SignUpViewController {
    
    func createEmptyFieldAlert() {
        let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
