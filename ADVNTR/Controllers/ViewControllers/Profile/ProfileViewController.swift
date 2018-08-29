//
//  ProfileViewController.swift
//  ADVNTR
//
//  Created by Zachary Frew & Owen Henley on 8/20/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var editAndSaveButton: UIBarButtonItem!
    @IBOutlet weak var activityTypeSegmentedController: UISegmentedControl!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    // MARK: - Properties
    lazy var user = UserController.shared.user
    let imagePickerController = UIImagePickerController()
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldColors()
        toggleUserInteraction()
        updateViews()
        
        
        let tapGestureForImageView = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        profileImageView.addGestureRecognizer(tapGestureForImageView)
        imagePickerController.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func editAndSaveButtonTapped(_ sender: UIBarButtonItem) {
        toggleEditOrSaveButtonText()
        toggleTextFieldColors()
        toggleUserInteraction()
        guard let displayName = displayNameTextField.text, !displayName.isEmpty, displayName != " ",
            let email = emailTextField.text, !email.isEmpty, email != " "
            else { return }
        
        let preferredActivty = updatePreferredActivityType(activityTypeSegmentedController.selectedSegmentIndex)
        
        // TODO: - Implement update and save logic for displayName, image, preferredActivity, and email.
    }
    
    @IBAction func defaultActivitySegmentedController(_ sender: UISegmentedControl) {
        user.preferredActivityType = updatePreferredActivityType(sender.selectedSegmentIndex)
    }
    
    // MARK: - Methods
    func updateViews() {
        if (Auth.auth().currentUser?.isAnonymous)! {
            profileImageView.image = UIImage(named: "defaultProfile")
        }
        
        let profileImageRef = UserController.shared.profileImageReference.child(user.uid!).child("profilePhoto").child("photo")
        profileImageView?.sd_setImage(with: profileImageRef)
        
        activityTypeSegmentedController.selectedSegmentIndex = setActivityTypeSegmentedControllerFor(user: user)
        profileNameLabel.text = user.displayName
        displayNameTextField.text = user.displayName
        emailTextField.text = user.email
    }
    
    func setTextFieldColors() {
        displayNameTextField.textColor = UIColor.white
        displayNameTextField.backgroundColor = UIColor.black
        emailTextField.textColor = UIColor.white
        emailTextField.backgroundColor = UIColor.black
    }
    
    func toggleUserInteraction() {
        activityTypeSegmentedController.isUserInteractionEnabled = !activityTypeSegmentedController.isUserInteractionEnabled
        profileImageView.isUserInteractionEnabled = !profileImageView.isUserInteractionEnabled
        profileNameLabel.isUserInteractionEnabled = !profileNameLabel.isUserInteractionEnabled
        displayNameTextField.isUserInteractionEnabled = !displayNameTextField.isUserInteractionEnabled
        emailTextField.isUserInteractionEnabled = !emailTextField.isUserInteractionEnabled
    }

    func toggleTextFieldColors() {
        displayNameTextField.textColor = toggleColorToOppositeOf(displayNameTextField.textColor!)
        displayNameTextField.backgroundColor = toggleColorToOppositeOf(displayNameTextField.backgroundColor!)
        emailTextField.textColor = toggleColorToOppositeOf(emailTextField.textColor!)
        emailTextField.backgroundColor = toggleColorToOppositeOf(emailTextField.backgroundColor!)
    }
    
    func toggleColorToOppositeOf(_ currentColor: UIColor) -> UIColor {
        if currentColor == UIColor.white {
            return UIColor.black
        } else {
            return UIColor.white
        }
    }
    
    func setActivityTypeSegmentedControllerFor(user: User) -> Int {
        switch (user.preferredActivityType) {
        case "run":
            return 0
        case "hike":
            return 1
        case "bike":
            return 2
        default:
            return 0
        }
    }
    
    // Sets the activityType based on the selected segment in segmented controller.
    func updatePreferredActivityType(_ index: Int) -> String {
        switch (index) {
        case 0:
            return "run"
        case 1:
            return "hike"
        case 2:
            return "bike"
        default:
            return "run"
        }
    }
    
    func toggleEditOrSaveButtonText() {
        if editAndSaveButton.title == "Edit" {
            editAndSaveButton.title = "Save"
        } else {
            editAndSaveButton.title = "Edit"
        }
    }
    
    @objc func imageViewTapped() {
        present(imagePickerController, animated: true)
    }
    
}

// MARK: - UINavigationControllerDelegate & UIImagePickerControllerDelegate Conformance
extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = image
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
