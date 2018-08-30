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
import SwiftEntryKit

class ProfileViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var editAndSaveButton: UIBarButtonItem!
    @IBOutlet weak var activityTypeSegmentedController: UISegmentedControl!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var totalDistanceNameLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var totalElevationLabel: UILabel!
    
    // MARK: - Properties
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    // MARK: - Actions
    @IBAction func editAndSaveButtonTapped(_ sender: UIBarButtonItem) {
        toggleTextFieldColors()
        toggleUserInteraction()
        guard let displayName = displayNameTextField.text, !displayName.isEmpty, displayName != " ",
            let email = emailTextField.text, !email.isEmpty, email != " ",
            let photo = profileImageView.image
            else { return }
        
        let preferredActivity = updatePreferredActivityType(activityTypeSegmentedController.selectedSegmentIndex)
        
        if editAndSaveButton.title == "Save" {
            // Update on Firebase
            UserController.shared.updateProfileForUserWith(uid: UserController.shared.user.uid!, displayName: displayName, email: email, photo: photo, preferredActivityType: preferredActivity) { (success) in
                
                if success {
                    UserController.shared.fetchCurrentUserData(completion: { (success) in
                        let message = MessageController.shared.createSuccessAlertWith(title: "Success", description: "Your profile was successfully updated.")
                        DispatchQueue.main.async {
                            SwiftEntryKit.display(entry: message.0, using: message.1)
                            self.updateViews()
                        }
                    })
                } else {
                    print("Failed to update user's profile.")
                }
            }
        }
        toggleEditOrSaveButtonText()
    }
    
    @IBAction func defaultActivitySegmentedController(_ sender: UISegmentedControl) {
        UserController.shared.user.preferredActivityType = updatePreferredActivityType(sender.selectedSegmentIndex)
    }
    
    // MARK: - Methods
    func updateViews() {
        if (Auth.auth().currentUser?.isAnonymous)! {
            profileImageView.image = UIImage(named: "defaultProfile")
        }
        
        let profileImageRef = UserController.shared.profileImageReference.child(UserController.shared.user.uid!).child("profilePhoto").child("photo")
        profileImageView?.sd_setImage(with: profileImageRef)
        
        let travelSpelling = UserController.shared.user.defaultUnits == "imperial" ? "Traveled" : "Travelled"
        totalDistanceNameLabel.text = "Total Distance \(travelSpelling):"
        
        activityTypeSegmentedController.selectedSegmentIndex = setActivityTypeSegmentedControllerFor(user: UserController.shared.user)
        profileNameLabel.text = UserController.shared.user.displayName
        displayNameTextField.text = UserController.shared.user.displayName
        emailTextField.text = UserController.shared.user.email
        
        let distanceUnits = UserController.shared.user.defaultUnits == "imperial" ? "mi" : "km"
        let distanceMeasurement = Measurement(value: Double(UserController.shared.user.totalActivityDistance ?? 0), unit: UnitLength.meters)
        let distanceToDisplay = UserController.shared.user.defaultUnits == "imperial" ? ActivityUnitConverter.milesFromMeters(distance: distanceMeasurement) : ActivityUnitConverter.kilometersFromMeters(distance: distanceMeasurement)
        totalDistanceLabel.text = "\(distanceToDisplay.roundedDoubleString) \(distanceUnits)"
        
        let elevationUnits = UserController.shared.user.defaultUnits == "imperial" ? "ft" : "m"
        let elevationMeasurement = Measurement(value: Double(UserController.shared.user.totalElevationChange ?? 0), unit: UnitLength.meters)
        let elevationToDisplay = UserController.shared.user.defaultUnits == "imperial" ? Int(ActivityUnitConverter.feetFromMeters(distance: elevationMeasurement)) : UserController.shared.user.totalElevationChange
        totalDistanceLabel.text = "\(distanceToDisplay.roundedDoubleString) \(distanceUnits)"
        totalElevationLabel.text = "\(elevationToDisplay ?? 0) \(elevationUnits)"
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
