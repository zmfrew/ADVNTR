//
//  AppDelegate.swift
//  ADVNTR
//
//  Created by Zachary Frew on 8/17/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Required initialiser for Firebase App
        FirebaseApp.configure()
        
        // Enable Firebase Persistence
        Database.database().isPersistenceEnabled = true
        
        // If the user is completely new, log in as a new anonymous user.
        if (Auth.auth().currentUser == nil)  {
            UserController.shared.logInAnonymousUser()
            return true
        }
        
        // If they're a returning anonymous user, set the UserController's 'User' model
        // object instance 'user' uid property to that of the anonymous user's Firebase UID.
        // If the user is a returning fully authenticated user, set both uid and email
        // properties on the UserController's user model object instance.
        guard let isAnonymous = Auth.auth().currentUser?.isAnonymous else { return true }
        if isAnonymous {
            UserController.shared.user.uid = Auth.auth().currentUser?.uid
        } else {
            UserController.shared.fetchCurrentUserData { (success) in
                if success {
                    print("Successful initialisation and download of user.")
                }
            }
        }
        return true
    }
}

