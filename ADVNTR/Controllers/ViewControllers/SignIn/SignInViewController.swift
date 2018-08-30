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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: - Actions
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toSignUp", sender: self)
    }
    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toForgotPassword", sender: self)
    }
    
    func signInUser(completion: @escaping (Bool) -> Void) {
        guard let email = emailAddressTextField.text, !email.isEmpty, isValidEmail(email: email),
            let password = passwordTextField.text, !password.isEmpty else {
                showEmptyFieldsAlert()
                completion(false)
                return
        }
        
        UserController.shared.signInAuthenticatedUserWith(email: email, password: password) { (success, error) in
            
            if success {
                self.isSuccessfulSignIn = true
                completion(true)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "unwindFromSignIn", sender: self)
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
                    completion(false)
                }
            }
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let activityType = activityType else { return }
        if segue.identifier == "unwindFromSignIn" {
//            let destinationVC = segue.destination as? ActivityHistoryViewController
//            destinationVC?.activityType = activityType
        }
        
        if segue.identifier == "toSignUp" {
            let destinationVC = segue.destination as? SignUpViewController
            destinationVC?.activityType = activityType
        }
    }
    
    // Prevents the unwind segue from performing unless the user's sign up/in has been successful.
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var boolToReturn = false
        if identifier == "unwindFromSignIn" {
            signInUser { (success) in
                if success {
                    boolToReturn = true
                } else {
                    let message = MessageController.shared.createAuthErrorAlertWith(title: "Error", description: "Failed to sign in. Please try again.")
                    DispatchQueue.main.async {
                        SwiftEntryKit.display(entry: message.0, using: message.1)
                    }
                }
            }
        }
        
        return boolToReturn
    }
    
    // Required so that pressing the back button on the Sign Up View Controller will
    // allow the user to pop that screen off the view stack.
    @IBAction func unwindFromSignUpVC(_ sender: UIStoryboardSegue) {
        
        let source = sender.source
        if source.isKind(of: SignUpViewController.self) {
            guard let sourceVC = source as? SignUpViewController else { return }
            if sourceVC.isSuccessfulSignUp {
                performSegue(withIdentifier: "unwindFromSignIn", sender: self)
            }
        }
    }
    
    
    // MARK: Helper Methods
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






