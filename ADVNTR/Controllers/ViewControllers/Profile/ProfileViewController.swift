//
//  ProfileViewController.swift
//  ADVNTR
//
//  Created by Zachary Frew & Owen Henley on 8/20/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit
import Photos
import FirebaseUI
import FirebaseAuth
import SwiftEntryKit
import TwicketSegmentedControl

class ProfileViewController: UIViewController, TwicketSegmentedControlDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var editAndSaveButton: UIBarButtonItem!
    @IBOutlet weak var activityTypeSegmentedController: TwicketSegmentedControl!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var totalDistanceNameLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var totalElevationLabel: UILabel!
    @IBOutlet weak var totalActivitiesLabel: UILabel!
    @IBOutlet weak var totalRunningTimeLabel: UILabel!
    @IBOutlet weak var totalHikingTimeLabel: UILabel!
    @IBOutlet weak var totalBikingTimeLabel: UILabel!
    
    // MARK: - Properties
    let imagePickerController = UIImagePickerController()
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTextFields()
        toggleUserInteraction()
        updateViews()
        setUpSegmentedController()
        
        imagePickerController.delegate = self
        let tapGestureForImageView = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        profileImageView.addGestureRecognizer(tapGestureForImageView)
        imagePickerController.sourceType = .photoLibrary
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    // MARK: - Actions
    @IBAction func editAndSaveButtonTapped(_ sender: UIBarButtonItem) {
        toggleTextFieldColors()
        toggleTextFieldAlignment()
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
    
    func didSelect(_ segmentIndex: Int) {
        UserController.shared.user.preferredActivityType = updatePreferredActivityType(segmentIndex)
    }
    
    // MARK: - Methods
    func setUpSegmentedController() {
        let titles = ["Run", "Hike", "Bike"]
        activityTypeSegmentedController.setSegmentItems(titles)
        activityTypeSegmentedController.delegate = self
        activityTypeSegmentedController.defaultTextColor = UIColor.white
        activityTypeSegmentedController.highlightTextColor = UIColor.yellow
        activityTypeSegmentedController.segmentsBackgroundColor = UIColor.black
        activityTypeSegmentedController.sliderBackgroundColor = UIColor.clear
        activityTypeSegmentedController.isSliderShadowHidden = true
        activityTypeSegmentedController.layer.backgroundColor = UIColor.clear.cgColor
        activityTypeSegmentedController.sizeToFit()
    }
    
    func updateViews() {
        if (Auth.auth().currentUser?.isAnonymous)! {
            profileImageView.image = UIImage(named: "SplashScreen")
        }
        
        let profileImageRef = UserController.shared.profileImageReference.child(UserController.shared.user.uid!).child("profilePhoto").child("photo")
        profileImageView?.sd_setImage(with: profileImageRef)
        
        let travelSpelling = UserController.shared.user.defaultUnits == "imperial" ? "Traveled" : "Travelled"
        totalDistanceNameLabel.text = "Total Distance \(travelSpelling):"
        
        activityTypeSegmentedController.move(to: setActivityTypeSegmentedControllerFor(user: UserController.shared.user))
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
        
        totalActivitiesLabel.text = "\(UserController.shared.user.totalActivityCount ?? 0)"
        totalRunningTimeLabel.text = "\(FormatDisplay.time(UserController.shared.user.totalRunTime ?? 0))"
        totalBikingTimeLabel.text = "\(FormatDisplay.time(UserController.shared.user.totalHikeTime ?? 0))"
        totalHikingTimeLabel.text = "\(FormatDisplay.time(UserController.shared.user.totalBikeTime ?? 0))"
    }
    
    func setUpTextFields() {
        displayNameTextField.textColor = UIColor.white
        displayNameTextField.backgroundColor = UIColor.black
        displayNameTextField.textAlignment = .right
        emailTextField.textColor = UIColor.white
        emailTextField.backgroundColor = UIColor.black
        emailTextField.textAlignment = .right
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
    
    func toggleTextFieldAlignment() {
        toggleTextFieldAlignmentToOppositeOf(displayNameTextField)
        toggleTextFieldAlignmentToOppositeOf(emailTextField)
    }

    func toggleColorToOppositeOf(_ currentColor: UIColor) -> UIColor {
        if currentColor == UIColor.white {
            return UIColor.black
        } else {
            return UIColor.white
        }
    }
    
    func toggleTextFieldAlignmentToOppositeOf(_ textField: UITextField) {
        if textField.textAlignment == .right {
            textField.textAlignment = .left
        } else {
            textField.textAlignment = .right
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
        
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) in
                
            })
        } else if PHPhotoLibrary.authorizationStatus() == .authorized {
            present(imagePickerController, animated: true)
        }
    }
    
}

// MARK: - UINavigationControllerDelegate & UIImagePickerControllerDelegate Conformance
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = image
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

