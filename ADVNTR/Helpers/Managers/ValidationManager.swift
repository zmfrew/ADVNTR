//
//  ValidationManager.swift
//  ADVNTR
//
//  Created by Zachary Frew on 9/3/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import Foundation
import FirebaseAuth

class ValidationManager {
    
    // MARK: - Properties
    static var emailErrors: [AuthErrorCode] = []
    static var passwordErrors: [PasswordError] = []
    
    // MARK: - Methods
    static func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with:email)
    }
    
    static func isValidPassword(password: String) -> Bool {
        let passwordRegex = "[A-Z0-9a-z._%+-!@#$^&*]{6,}"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with:password)
    }
    
    static func validateEmail(errorLabel: UILabel, textField: UITextField) {
        guard let email = textField.text?.trimmingCharacters(in: .whitespaces), !email.isEmpty else {
            errorLabel.isHidden = false
            errorLabel.text = AuthErrorCode.invalidEmail.errorMessage
            emailErrors = [.invalidEmail]
            textField.backgroundColor = UIColor.red.withAlphaComponent(0.2)
            return
        }
        
        if !ValidationManager.isValidEmail(email: email) {
            errorLabel.isHidden = false
            errorLabel.text = AuthErrorCode.invalidEmail.errorMessage
            emailErrors = [.invalidEmail]
            textField.backgroundColor = UIColor.red.withAlphaComponent(0.2)
            return
        } else {
            errorLabel.isHidden = true
            emailErrors = []
            errorLabel.text = ""
            textField.backgroundColor = UIColor.clear
        }
        
    }
    
    static func validatePassword(errorLabel: UILabel, textField: UITextField) {
        if textField.text == "" {
            errorLabel.isHidden = false
            errorLabel.text = PasswordError.passwordRequired.rawValue
            passwordErrors = [.passwordRequired]
            textField.backgroundColor = UIColor.red.withAlphaComponent(0.2)
            return
        } else if !ValidationManager.isValidPassword(password: textField.text!) {
            errorLabel.isHidden = false
            errorLabel.text = PasswordError.passwordNotValid.rawValue
            passwordErrors = [.passwordNotValid]
            textField.backgroundColor = UIColor.red.withAlphaComponent(0.2)
            return
        } else {
            errorLabel.isHidden = true
            passwordErrors = []
            errorLabel.text = ""
            textField.backgroundColor = UIColor.clear
        }
    }
    
}
