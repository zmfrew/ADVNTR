//
//  StoreReviewManager.swift
//  ADVNTR
//
//  Created by Zachary Frew on 8/27/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import Foundation
import StoreKit

class StoreReviewManager {
    
    // MARK: - Singleton
    static let shared = StoreReviewManager() ; private init() { }
    
    // MARK: - Properties
    let totalActivities = UserController.shared.user.totalActivityCount ?? 0
    let minimumActivityCount = 3
    
    // MARK: - Methods
    func showReview() {
        // Checks if the user has iOS 10.3 or later, and uses the built in request review to display the review dialog.
        if (totalActivities > minimumActivityCount) {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        }
    }
    
}
