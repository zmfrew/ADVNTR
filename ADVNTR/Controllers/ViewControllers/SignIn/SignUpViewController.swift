//
//  SignUpViewController.swift
//  ADVNTR
//
//  Created by Owen Henley on 8/23/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Methods
    
    func signUpNewUser() {
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

// MARK: Email Validator Extension
// Confirms that the entered email is of the correct format, including two letter domains.
extension SignUpViewController {
    
}

// MARK: Empty Sign Up Fields Alert Extension
// Called when the user hasn't entered text in either or both of the sign up/in text fields.
extension SignUpViewController {
    
}

        // MARK: FIRAuth Error Codes Extension
        // Creates custom strings to show in error popups during sign up process.
        // These are used in the AuthErrorCode switch statement above.
//extension AuthErrorCode {
//var errorMessage: String {
//    switch self {
//    case .emailAlreadyInUse:
//        return "That email is already in use with another ADVNTR account."
//    case .userDisabled:
//        return "Your account has been disabled. Please contact support."
//    case .invalidEmail:
//        return "Please enter a valid email, for example adventurer@advntr.com"
//    case .networkError:
//        return "Network error. Please try again."
//    case .wrongPassword:
//        return "The password you entered does not match the password for the selected email."
//    default:
//        return "Unknown error occurred."
//    }
//}
//}
