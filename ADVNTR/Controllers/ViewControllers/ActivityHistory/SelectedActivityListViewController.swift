//
//  SelectedActivityListViewController.swift
//  ADVNTR
//
//  Created by Zachary Frew, Jeter Pow & Owen Henley on 8/20/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseUI

class SelectedActivityListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var activities: [Activity] = []
    var activityType: String?
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // This value is set in prepareForSegue on ActivityHistoryVC so that the table view
        // will only display data for a single type of activity.
        guard let activityType = activityType else { return }
        
        // This is the equivalent of a fetch. We get all the activities in the form of a
        // Firebase 'snapshot'. The snapshot is essentially a dictionary from which each of its
        // 'children' can be compactMapped into an array of activities that is stored in a local
        // variable for the table view data source.
        ActivityController.shared.ref.child(activityType).queryOrdered(byChild: "distance").observe(.value) { (snapshot) in
            let activities = snapshot.children.compactMap { Activity(snapshot: $0 as! DataSnapshot)}
            self.activities = activities
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SelectedActivityListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "activityHistoryCell", for: indexPath) as? ActivityHistoryTableViewCell else { return UITableViewCell() }
        
        let activity = activities[indexPath.row]
        
        cell.activity = activity
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let activity = activities[indexPath.row]
            guard let activityType = activityType else { return }
            
            // Using the uid set when the activity was originally saved to Firebase allows us to know exactly
            // which value to delete on the Firebase Database.
            ActivityController.shared.deleteActivity(ofType: activityType, uid: activity.uid) { (success) in
                if success {
                    // We don't need to call tableView:deleteRows:at: with Firebase.
                    print("Successfully deleted activity from table view")
                } else {
                    print("Error deleting from tableview")
                }
            }
        }
    }
    
}














