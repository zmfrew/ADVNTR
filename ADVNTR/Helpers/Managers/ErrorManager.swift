//
//  ErrorManager.swift
//  ADVNTR
//
//  Created by Zachary Frew on 9/3/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import Foundation
import FirebaseAuth

// MARK: FIRAuth Error Codes Extension
// Firebase error mapping extension
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

// MARK: - Password Validation
enum PasswordError: String {
    case passwordRequired = "A password is required."
    case passwordNotValid = "Your password must be at least 6 characters."
}
