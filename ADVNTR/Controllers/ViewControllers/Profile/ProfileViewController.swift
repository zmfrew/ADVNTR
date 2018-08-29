//
//  ProfileViewController.swift
//  ADVNTR
//
//  Created by Zachary Frew & Owen Henley on 8/20/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var editAndSaveButton: UIBarButtonItem!
    @IBOutlet weak var activityTypeSegmentedController: UISegmentedControl!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    // MARK: - Properties
    let user = UserController.shared.user
    let imagePickerController = UIImagePickerController()
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        prohibitUserInteraction()
        updateViews()
        
        let tapGestureForImageView = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        profileImageView.addGestureRecognizer(tapGestureForImageView)
        imagePickerController.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func editAndSaveButtonTapped(_ sender: UIBarButtonItem) {
        toggleEditOrSaveButtonText()
        allowUserInteraction()
        guard let displayName = displayNameLabel.text, !displayName.isEmpty, displayName != " ",
            let email = emailLabel.text, !email.isEmpty, email != " "
            else { return }
        
        let preferredActivty = updatePreferredActivityType(activityTypeSegmentedController.selectedSegmentIndex)
        
        // TODO: - Implement update and save logic for displayName, image, preferredActivity, and email.
    }
    
    @IBAction func defaultActivitySegmentedController(_ sender: UISegmentedControl) {
        user.preferredActivityType = updatePreferredActivityType(sender.selectedSegmentIndex)
    }
    
    // MARK: - Methods
    func updateViews() {
        let data = try? Data(contentsOf: URL(string: user.photoURL!)!)
        let userImage = UIImage(data: data!) ?? UIImage(named: "defaultProfile")
        
        activityTypeSegmentedController.selectedSegmentIndex = setActivityTypeSegmentedControllerFor(user: user)
        profileImageView.image = userImage
        profileNameLabel.text = user.displayName
        displayNameLabel.text = user.displayName
        emailLabel.text = user.email
    }
    
    func allowUserInteraction() {
        activityTypeSegmentedController.isUserInteractionEnabled = true
        profileImageView.isUserInteractionEnabled = true
        profileNameLabel.isUserInteractionEnabled = true
        displayNameLabel.isUserInteractionEnabled = true
        emailLabel.isUserInteractionEnabled = true
    }
    
    func prohibitUserInteraction() {
        activityTypeSegmentedController.isUserInteractionEnabled = false
        profileImageView.isUserInteractionEnabled = false
        profileNameLabel.isUserInteractionEnabled = false
        displayNameLabel.isUserInteractionEnabled = false
        emailLabel.isUserInteractionEnabled = false
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
