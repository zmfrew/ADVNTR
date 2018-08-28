//
//  SignInViewController.swift
//  ADVNTR
//
//  Created by Owen Henley & Jeter Pow on 8/24/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftEntryKit

class SignInViewController: UIViewController {
    
    // MARK: Properties
    var activityType: String?
    var isSuccessfulSignIn = false

    // MARK: - Outlets
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Actions
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        signInUser()
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toSignUp", sender: self)
    }
    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toForgotPassword", sender: self)
    }
    
    func signInUser() {
        guard let email = emailAddressTextField.text, !email.isEmpty, isValidEmail(email: email),
            let password = passwordTextField.text, !password.isEmpty else { showEmptyFieldsAlert() ; return }
        
        UserController.shared.signInAuthenticatedUserWith(email: email, password: password) { (success, error) in
            
            if success {
                self.isSuccessfulSignIn = true
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "successfulSignIn", sender: self)
                }
            } else {
                if let errorCode = AuthErrorCode(rawValue: (error?._code)!) {
                    switch errorCode {
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
    
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let activityType = activityType else { return }
        if segue.identifier == "successfulSignIn" {
            let destinationVC = segue.destination as? SelectedActivityDetailsTableViewController
            destinationVC?.activityType = activityType
        }
        
        if segue.identifier == "toSignUp" {
            let destinationVC = segue.destination as? SignUpViewController
            destinationVC?.activityType = activityType
        }
    }
    
    // Prevents the unwind segue from performing unless the user's sign up/in has been successful.
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "successfulSignIn" {
            signInUser()
            if self.isSuccessfulSignIn {
                return true
            }
        }
        return false
    }
    
    // Required so that pressing the back button on the Sign Up View Controller will
    // allow the user to pop that screen off the view stack.
    @IBAction func unwindFromSignUpVC(_ sender: UIStoryboardSegue) {
    }
    
    
    // MARK: Helper Methods
    
    func showEmptyFieldsAlert() {
        let alertController = MessageController.shared.createEmptyFieldAlert()
        present(alertController, animated: true, completion: nil)
    }
    
    // TODO: This appears in two View Controllers - move to manager?
    func isValidEmail(email:String?) -> Bool {
        guard email != nil else { return false }
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
}

// MARK: FIRAuth Error Codes Extension
// Creates custom strings to show in error popups during sign up process.
// These are used in the AuthErrorCode switch statement above.
extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "That email is already in use with another ADVNTR account."
        case .userDisabled:
            return "Your account has been disabled. Please contact support."
        case .invalidEmail:
            return "Please enter a valid email, for example adventurer@advntr.com"
        case .networkError:
            return "Network error. Please try again."
        case .wrongPassword:
            return "The password you entered does not match the password for the selected email."
        default:
            return "Unknown error occurred."
        }
    }
}






