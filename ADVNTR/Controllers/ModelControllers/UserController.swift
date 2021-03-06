//
//  UserController.swift
//  ADVNTR
//
//  Created by Jeter Pow on 28/8/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

// TODO: More robust error handling including alerts.
class UserController {
    
    // Singleton
    static let shared = UserController()
    
    // Local model object
    var user = User()
    
    // Base reference to the location of the user's data dictionary on Firebase Database
    let userReference: DatabaseReference = Database.database().reference()
    
    // Reference to the location of the user's profile photo on Firebase Storage
    var profileImageReference: StorageReference = Storage.storage().reference()
    
    // Fetch current user data if previously signed up and authenticated with Firebase
    func fetchCurrentUserData(completion: @escaping (Bool) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        userReference.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else { return }
            self.user = user
            completion(true)
        }) { (error) in
            print("Error fetching user data from Firebase: \(error.localizedDescription)")
            completion(false)
            return
        }
    }

    
    // All users will have a Firebase UID as this function is called in AppDelegate.
    func logInAnonymousUser() {
        Auth.auth().signInAnonymously() { (authResult, error) in
            
            if let error = error {
                print("Error signing in with Firebase: \(error)")
                return
            } else {
                guard let result = authResult else { return }
                let user = result.user
                self.user.uid = user.uid

                self.setInitialValuesForUser(completion: { (success) in
                    if success {
                        UserController.shared.fetchCurrentUserData(completion: { (success) in
                            
                            if success {
                                print("Successfully signed in existing Firebase user.")
                            } else {
                                print("Error fetching data for newly signed-in user.")
                            }
                        })
                    }
                })
            }
        }
    }
    
    // Sign in an existing Firebase User using email and password.
    func signInAuthenticatedUserWith(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("Error signing in user with Firebase: \(error)")
                completion(false, error)
                return
            }
            
            guard let result = user else {
                print("Error retrieving authenticated user from Firebase.")
                completion(false, nil)
                return
            }
            
            UserController.shared.user.uid = result.user.uid
            UserController.shared.fetchCurrentUserData(completion: { (success) in
                if success {
                    print("Successfully signed in existing Firebase user.")
                    completion(true, nil)
                } else {
                    print("Error fetching data for newly signed-in user.")
                }
            })
        }
    }
    
    // Create an authenticated email/password account and merge the data from the user's
    // original anonymous account.
    func createAuthenticatedUserWith(displayName: String, email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        guard let user = Auth.auth().currentUser else { return }
        user.linkAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                print("Error creating email user with Firebase: \(error)")
                completion(false, error)
                return
            } else {
                guard let result = authResult else { return }
                self.user.uid = result.user.uid
                self.user.email = user.email
                
                // Create a FirebaseAuth change request to upload the displayName for the previously
                // anonymous user.
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges(completion: { (error) in
                    if let error = error {
                        print("Error setting displayName property for Firebase User: \(error)")
                    } else {
                        self.user.displayName = user.displayName
                    }
                })
                // Firebase Database is separate to Firebase Auth, so the displayName and other values
                // must be saved there too for ease of querying later.
                self.userReference.child("\(user.uid)/displayName").setValue(displayName)
                self.userReference.child("\(user.uid)/uid").setValue(user.uid)
                self.userReference.child("\(user.uid)/email").setValue(email)
                
                // Save the profile photo to Firebase Storage and save the URL to it under the user's
                // Firebase Database dictionary.
                let profileImageRef = self.profileImageReference.child("\(result.user.uid)/profilePhoto/photo.jpg")
                guard let defaultProfileImage = UIImage(named: "defaultProfile") else { completion(false, nil) ; return }
                guard let imageData = defaultProfileImage.jpegData(compressionQuality: 0.1) else { completion(false, nil) ; return }
                
                profileImageRef.putData(imageData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        print("Error saving activity image map view to Firebase Storage: \(error)")
                        completion(false, error)
                        return
                    }
                    
                    profileImageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            print("Error retrieving photoURL when saving image to Firebase Storage.")
                            return
                        }
                        
                        // Create a string describing the profile image's new URL in Firebase Storage that can
                        // be stored in the local User model object's photoURL property and thereafter
                        // uploaded to Firebase Realtime Database.
                        let photoURL = downloadURL.absoluteString
                        self.userReference.child("\(user.uid)/photoURL").setValue(photoURL)
                        completion(true, nil)
                    }
                }
            }
        }
    }
    
    func resetPasswordForUserWith(email: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                print("Error saving activity image map view to Firebase Storage: \(error)")
                completion(false, error)
                return
            } else {
                completion(true, nil)
            }
        }
    }
    
    func toggleDefaultUnits() {
        if user.defaultUnits == "imperial" {
            user.defaultUnits = "metric"
        } else if user.defaultUnits == "metric" {
            user.defaultUnits = "imperial"
        }
        
        let uid = user.uid ?? Auth.auth().currentUser?.uid
        let defaultUnits = user.defaultUnits as Any
        let values = ["defaultUnits" : defaultUnits] as [String : Any]
        self.userReference.child(uid!).updateChildValues(values) { (error, ref) in
            if let error = error {
                print("Error occurred toggling units: \(error.localizedDescription).")
            }
        }
    }
    
    func setInitialValuesForUser(completion: @escaping (Bool) -> Void) {
        // Create initial Firebase records for the new user
        guard let uid = self.user.uid else { print("Fucked it") ; return }
        
        let values = ["uid" : uid,
                      "email" : "email",
                      "displayName" : "AVNTRer",
                      "photoURL" : "photoURL",
                      "defaultUnits" : "imperial",
                      "totalActivityDuration" : 0,
                      "totalActivityDistance" : 0,
                      "totalElevationChange" : 0,
                      "totalActivityCount" : 0,
                      "preferredActivityType" : "run",
                      "totalRunDistance" : 0,
                      "totalRunTime" : 0,
                      "totalRunElevationChange" : 0,
                      "totalHikeDistance" : 0,
                      "totalHikeTime" : 0,
                      "totalHikeElevationChange" : 0,
                      "totalBikeDistance" : 0,
                      "totalBikeTime" : 0,
                      "totalBikeElevationChange" : 0] as [String : Any]
        
        userReference.child((Auth.auth().currentUser?.uid)!).updateChildValues(values) { (error, ref) in
            if let error = error {
                print("Error saving initial data values to Firebase: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func updateProfileForUserWith(uid: String, displayName: String, email: String, photo: UIImage?, preferredActivityType: String, completion: @escaping (Bool) -> Void) {
        
        let values = ["email" : email,
                      "displayName" : displayName,
                      "preferredActivityType": preferredActivityType]
        
        userReference.child(uid).updateChildValues(values) { (error, ref) in
            if let error = error {
                print("Error saving initial data values to Firebase: \(error)")
                completion(false)
            } else {
                if photo != nil {
                    // Save the profile photo to Firebase Storage and save the URL to it under the user's
                    // Firebase Database dictionary.
                    let profileImageRef = self.profileImageReference.child("\(uid)/profilePhoto/photo.jpg")
                    guard let photo = photo else { completion(false) ; return }
                    guard let photoData = photo.jpegData(compressionQuality: 0.1) else { completion(false) ; return }
                    
                    profileImageRef.putData(photoData, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error saving activity image map view to Firebase Storage: \(error)")
                            completion(false)
                            return
                        }
                        
                        profileImageRef.downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                print("Error retrieving photoURL when saving image to Firebase Storage.")
                                return
                            }
                            
                            // Create a string describing the profile image's new URL in Firebase Storage that can
                            // be stored in the local User model object's photoURL property and thereafter
                            // uploaded to Firebase Realtime Database.
                            let photoURL = downloadURL.absoluteString
                            self.userReference.child("\(uid)/photoURL").setValue(photoURL, withCompletionBlock: { (error, ref) in
                                if let error = error {
                                    print("Error updating profile image URL on Firebase Database: \(error.localizedDescription)")
                                    completion(false)
                                    return
                                } else {
                                    print("Successfully updated user's profile")
                                    completion(true)
                                }
                            })
                        }
                    }
                } else {
                    completion(true)
                }
            }
        }
    }
}








