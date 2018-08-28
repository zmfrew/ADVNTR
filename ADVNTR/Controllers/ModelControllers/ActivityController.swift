//
//  ActivityController.swift
//  ADVNTR
//
//  Created by Zachary Frew & Jeter Pow on 8/20/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class ActivityController {
    
    // Singleton
    static let shared = ActivityController()
    
    // Reference to the base level Firebase JSON dictionary for the logged in user
    var ref: DatabaseReference! = Database.database().reference(withPath: (Auth.auth().currentUser?.uid)!)
    
    static var usersActivityImagesReference = Storage.storage().reference().child((Auth.auth().currentUser?.uid)!).child("activityImages")
    
    // Create an Activity model object. Create a new reference for the activity, under its associated
    // activity type, with it's own auto-generated UID. Then use the toAnyObject() helper method to save
    // the values (distance, name, speed etc) to that UID.
    func saveActivity(type: String, name: String, distance: Int, averageSpeed: Double, elevationChange: Int, timestamp: String, duration: Int, image: UIImage, completion: @escaping (Bool) -> Void) {
        
        // Create a reference first to the intended location of the new activity's data on Firebase
        // Realtime Database
        let activityRef = self.ref.child(type.lowercased()).childByAutoId()
        let activityUID = activityRef.key
        
        // Get the latest totals for the user's activities
        UserController.shared.fetchCurrentUserData { (success) in
            if success {
                // Create a reference to the database location for the user's totals
                let userRef = UserController.shared.userReference.child(UserController.shared.user.uid!)
                
                // Calculate grand totals
                let newTotalActivityDuration = duration + (UserController.shared.user.totalActivityDuration ?? 0)
                let newTotalActivityDistance = distance + (UserController.shared.user.totalActivityDistance ?? 0)
                let newTotalActivityElevation = elevationChange + (UserController.shared.user.totalElevationChange ?? 0)
                let newTotalActivityCount = 1 + (UserController.shared.user.totalActivityCount ?? 0)
                
                // Calculate totals for the individual type of activity conducted
                var newIndividualActivityDistance = Int()
                var newIndividualActivityTime = Int()
                var newIndividualActivityElevationChange = Int()
                var distanceKey = ""
                var timeKey = ""
                var elevationChangeKey = ""
                
                switch type {
                case "run":
                    newIndividualActivityDistance = distance + (UserController.shared.user.totalRunDistance ?? 0)
                    newIndividualActivityTime = duration + (UserController.shared.user.totalRunTime ?? 0)
                    newIndividualActivityElevationChange = elevationChange + (UserController.shared.user.totalRunElevationChange ?? 0)
                    distanceKey = User.totalRunDistanceKey
                    timeKey = User.totalRunTimeKey
                    elevationChangeKey = User.totalRunElevationChangeKey
                    
                case "hike":
                    newIndividualActivityDistance = distance + (UserController.shared.user.totalHikeDistance ?? 0)
                    newIndividualActivityTime = duration + (UserController.shared.user.totalHikeTime ?? 0)
                    newIndividualActivityElevationChange = elevationChange + (UserController.shared.user.totalHikeElevationChange ?? 0)
                    distanceKey = User.totalHikeDistanceKey
                    timeKey = User.totalHikeTimeKey
                    elevationChangeKey = User.totalHikeElevationChangeKey
                    
                case "bike":
                    newIndividualActivityDistance = distance + (UserController.shared.user.totalBikeDistance ?? 0)
                    newIndividualActivityTime = duration + (UserController.shared.user.totalBikeTime ?? 0)
                    newIndividualActivityElevationChange = elevationChange + (UserController.shared.user.totalBikeElevationChange ?? 0)
                    distanceKey = User.totalBikeDistanceKey
                    timeKey = User.totalBikeTimeKey
                    elevationChangeKey = User.totalBikeElevationChangeKey
                    
                default:
                    return
                }
                
                // Combine all updates into a dictionary
                let totalsUpdates = [User.totalActivityDurationKey: newTotalActivityDuration,
                                     User.totalActivityDistanceKey: newTotalActivityDistance,
                                     User.totalElevationChangeKey: newTotalActivityElevation,
                                     User.totalActivityCountKey: newTotalActivityCount,
                                     distanceKey: newIndividualActivityDistance,
                                     timeKey: newIndividualActivityTime,
                                     elevationChangeKey: newIndividualActivityElevationChange
                ]
                
                // Update all values on Firebase Database
                userRef.updateChildValues(totalsUpdates) { (error, ref) in
                    if let error = error {
                        print("Error updating new activity parameters to Firebase: \(error)")
                        completion(false)
                        return
                    }
                    
                    // Create a Firebase Storage reference for the activity's map image/screenshot
                    let activityImageReference = ActivityController.usersActivityImagesReference.child(activityUID)
                    
                    // Turn the activity/map screenshot image into data for upload to Firebase Storage
                    // TODO: Check that 0.1 is enough/too much compression for the image to reduce Firebase Storage usage
                    // and download times.
                    guard let imageData = UIImageJPEGRepresentation(image, 0.1) else { completion(false) ; return }
                    
                    // Perform the upload task to store the image on Firebase Storage and retrieve it's URL for saving in
                    // the Firebase Realtime Database record for that activity.
                    activityImageReference.putData(imageData, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error saving activity image map view to Firebase Storage: \(error)")
                            completion(false)
                            return
                        }
                        
                        activityImageReference.downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                print("Error retrieving imageURL when saving image to Firebase Storage.")
                                return
                            }
                            
                            // Create a string describing the image's new URL in Firebase Storage that can be stored
                            // in the local Activity model object's imageURL property and thereafter uploaded to
                            // Firebase Realtime Database.
                            let imageURL = downloadURL.absoluteString
                            
                            // Create a new Activity model object and save it Firebase Realtime Database
                            var activity = Activity(type: type, name: name, distance: distance, averageSpeed: averageSpeed, elevationChange: elevationChange, timestamp: timestamp, duration: duration, imageURL: imageURL)
                            
                            activity.uid = activityUID
                            activityRef.setValue(activity.toAnyObject())
                            
                            print("Successfully saved new activity and its associated image.")
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    // Delete an activity using a reference to each saved activity's UID, as well as its image
    // stored on Firebase Storage.
    func deleteActivity(ofType: String, uid: String, completion: @escaping (Bool) -> Void) {
        
        // Get the latest totals for the user's activities
        UserController.shared.fetchCurrentUserData { (success) in
            // Variable to store the activity retrieved below
            var activityToDelete: Activity?
            
            // Get the values of the activity to be deleted
            self.ref.child(ofType).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                activityToDelete = Activity(snapshot: snapshot) ?? nil
                
                // Calculate grand totals
                let newTotalActivityDuration = (UserController.shared.user.totalActivityDuration ?? 0) - (activityToDelete?.duration)!
                let newTotalActivityDistance = (UserController.shared.user.totalActivityDistance ?? 0) - (activityToDelete?.distance)!
                let newTotalActivityElevation = (UserController.shared.user.totalElevationChange ?? 0) - (activityToDelete?.elevationChange)!
                let newTotalActivityCount = (UserController.shared.user.totalActivityCount ?? 0) - 1
                
                // Calculate totals for the individual type of activity conducted
                var newIndividualActivityDistance = Int()
                var newIndividualActivityTime = Int()
                var newIndividualActivityElevationChange = Int()
                var distanceKey = ""
                var timeKey = ""
                var elevationChangeKey = ""
                
                switch ofType {
                case "run":
                    newIndividualActivityDistance = (UserController.shared.user.totalRunDistance ?? 0) - (activityToDelete?.distance)!
                    newIndividualActivityTime = (UserController.shared.user.totalRunTime ?? 0) - (activityToDelete?.duration)!
                    newIndividualActivityElevationChange = (UserController.shared.user.totalRunElevationChange ?? 0) - (activityToDelete?.elevationChange)!
                    distanceKey = User.totalRunDistanceKey
                    timeKey = User.totalRunTimeKey
                    elevationChangeKey = User.totalRunElevationChangeKey
                    
                case "hike":
                    newIndividualActivityDistance = (UserController.shared.user.totalHikeDistance ?? 0) - (activityToDelete?.distance)!
                    newIndividualActivityTime = (UserController.shared.user.totalHikeTime ?? 0) - (activityToDelete?.duration)!
                    newIndividualActivityElevationChange = (UserController.shared.user.totalHikeElevationChange ?? 0) - (activityToDelete?.elevationChange)!
                    distanceKey = User.totalHikeDistanceKey
                    timeKey = User.totalHikeTimeKey
                    elevationChangeKey = User.totalHikeElevationChangeKey
                    
                case "bike":
                    newIndividualActivityDistance = (UserController.shared.user.totalBikeDistance ?? 0) - (activityToDelete?.distance)!
                    newIndividualActivityTime = (UserController.shared.user.totalBikeTime ?? 0) - (activityToDelete?.duration)!
                    newIndividualActivityElevationChange = (UserController.shared.user.totalBikeElevationChange ?? 0) - (activityToDelete?.elevationChange)!
                    distanceKey = User.totalBikeDistanceKey
                    timeKey = User.totalBikeTimeKey
                    elevationChangeKey = User.totalBikeElevationChangeKey
                    
                default:
                    return
                }
                
                // Combine all updates into a dictionary
                let totalsUpdates = [User.totalActivityDurationKey: newTotalActivityDuration,
                                     User.totalActivityDistanceKey: newTotalActivityDistance,
                                     User.totalElevationChangeKey: newTotalActivityElevation,
                                     User.totalActivityCountKey: newTotalActivityCount,
                                     distanceKey: newIndividualActivityDistance,
                                     timeKey: newIndividualActivityTime,
                                     elevationChangeKey: newIndividualActivityElevationChange
                ]
                
                // Update all values on Firebase Database
                self.ref.updateChildValues(totalsUpdates)
                
                self.ref.child(ofType).child(uid).removeValue { (error, _) in
                    if let error = error {
                        print("Error deleting activity from Firebase: \(error)")
                        completion(false)
                        return
                    } else {
                        let imageRef = ActivityController.usersActivityImagesReference.child(uid)
                        imageRef.delete(completion: { (error) in
                            if let error = error {
                                print("Error deleting image associated with deleted Activity: \(error)")
                            } else {
                                print("Successfully deleted Activity and its associated image.")
                                completion(true)
                            }
                        })
                    }
                }
                
            }) { (error) in
                print("Error fetching activity to delete from Firebase: \(error.localizedDescription)")
            }
        }
    }
    
}

