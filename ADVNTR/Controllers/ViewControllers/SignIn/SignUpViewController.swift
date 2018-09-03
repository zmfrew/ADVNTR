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
    
    // MARK: - Outlets
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailAddressErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    // MARK: Properties
    var isSuccessfulSignUp = false
    var activityType: String?
    
    // MARK: - LifeCycleMethods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unblurBackground()
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Methods
    func setupLabels() {
        emailAddressTextField.delegate = self
        passwordTextField.delegate = self
        displayNameTextField.delegate = self
        emailAddressErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        
        setupToolbar()
    }
    
    func setupToolbar() {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextField))
        nextButton.tintColor = UIColor.darkGray
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        doneButton.tintColor = UIColor.darkGray
        toolbar.setItems([nextButton, flexibleSpace, doneButton], animated: true)
        displayNameTextField.inputAccessoryView = toolbar
        emailAddressTextField.inputAccessoryView = toolbar
        passwordTextField.inputAccessoryView = toolbar
    }
    
    @objc func nextField() {
        if displayNameTextField.isEditing {
            emailAddressTextField.becomeFirstResponder()
        } else if emailAddressTextField.isEditing {
            passwordTextField.becomeFirstResponder()
        } else {
            displayNameTextField.becomeFirstResponder()
        }
    }
    
    @objc func dismissKeyboard() {
        displayNameTextField.resignFirstResponder()
        emailAddressTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
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
    
    func unblurBackground() {
        guard let signInVC = self.presentingViewController as? SignInViewController else { return }
        for subView in signInVC.view.subviews {
            if subView is UIVisualEffectView {
                subView.removeFromSuperview()
            }
        }
    }
    
    // Convenience function that handles creating a new authenticated user from an anonymous user.
    // This function is called in shouldPerformSegue so that errors are handled before the user
    // is returned to the app to see their new Activity History.
    func signUpNewUser(completion: @escaping (Bool) -> Void) {
        
        // Show an alert if text is not entered in one or both fields.
        guard let displayName = displayNameTextField.text, !displayName.isEmpty,
            let email = emailAddressTextField.text, !email.isEmpty, ValidationManager.isValidEmail(email: email),
            let password = passwordTextField.text, !password.isEmpty, ValidationManager.isValidPassword(password: password)
            else { createEmptyFieldAlert() ; return }
        
        UserController.shared.createAuthenticatedUserWith(displayName: displayName, email: email, password: password) { (success, error) in
            if success {
                
                self.isSuccessfulSignUp = true
                DispatchQueue.main.async {
                    completion(true)
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
                completion(false)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var boolToReturn = false
        if identifier == "successfulSignUp" {
            signUpNewUser { (success) in
                if success {
                    self.isSuccessfulSignUp = true
                    boolToReturn = true
                } else {
                    let message = MessageController.shared.createAuthErrorAlertWith(title: "Error", description: "Failed to sign up. Please try again.")
                    DispatchQueue.main.async {
                        SwiftEntryKit.display(entry: message.0, using: message.1)
                    }
                }
            }
        }
        return boolToReturn
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "successfulSignUp" {
//            let destinationVC = segue.destination as? ActivityHistoryViewController
//            guard let activityType = activityType else { return }
            //destinationVC?.activityType = activityType
        }
    }
}

// MARK: UITextFieldDelegate Conformance
extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == displayNameTextField {
            emailAddressTextField.becomeFirstResponder()
        } else if textField == emailAddressTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailAddressTextField {
            ValidationManager.validateEmail(errorLabel: emailAddressErrorLabel, textField: emailAddressTextField)
        } else if textField == passwordTextField {
            ValidationManager.validatePassword(errorLabel: passwordErrorLabel, textField: passwordTextField)
        }
    }
    
}

// MARK: Empty Sign Up Fields Alert Extension
// Called when the user hasn't entered text in either or both of the sign up/in text fields.
extension SignUpViewController {
    
    func createEmptyFieldAlert() {
        let alertController = UIAlertController(title: "Error", message: "Please enter a valid email and password. Your password must be at least 6 characters in length.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
