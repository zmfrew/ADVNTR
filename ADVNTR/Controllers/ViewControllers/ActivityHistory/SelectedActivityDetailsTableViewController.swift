//
//  SelectedActivityDetailsTableViewController.swift
//  ADVNTR
//
//  Created by Owen Henley on 8/28/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseUI
import ViewAnimator

class SelectedActivityDetailsTableViewController: UITableViewController {
    
    // MARK: - Properties
    var activities: [Activity] = []
    var activityType: String? {
        didSet {
            self.title = activityType?.capitalized
        }
    }
    private let animations = [AnimationType.from(direction: .right, offset: 120.0), AnimationType.zoom(scale: 0.5)]

    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This value is set in prepareForSegue on ActivityHistoryVC so that the table view
        // will only display data for a single type of activity.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        self.refreshControl = refreshControl
        
        guard let activityType = activityType else { return }
        
        // This is the equivalent of a fetch. We get all the activities in the form of a
        // Firebase 'snapshot'. The snapshot is essentially a dictionary from which each of its
        // 'children' can be compactMapped into an array of activities that is stored in a local
        // variable for the table view data source.
        ActivityController.shared.ref.child(activityType).queryOrdered(byChild: "createdAt").observe(.value) { (snapshot) in
            var activities = snapshot.children.compactMap { Activity(snapshot: $0 as! DataSnapshot)}
            activities.reverse()
            self.activities = activities
            DispatchQueue.main.async {
                self.refreshTable()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTable()
    }
    
    // MARK: - Methods
    @objc func refreshTable() {
        self.tableView.reloadData()
        UIView.animate(views: tableView.visibleCells, animations: animations)
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "activityHistoryCell", for: indexPath) as? ActivityHistoryTableViewCell else { return UITableViewCell() }
        
        let activity = activities[indexPath.row]
        
        cell.activity = activity
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
