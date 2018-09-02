//
//  NewActivityViewController.swift
//  ADVNTR
//
//  Created by Zachary Frew on 8/21/18.
//  Copyright © 2018 ADVNTR. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import SwiftEntryKit

class NewActivityViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var activityTypeLabel: UILabel!
    @IBOutlet weak var activityTypeSegmentedController: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityTimeLabel: UILabel!
    @IBOutlet weak var activityDistanceLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var averageSpeedOrPaceLabel: UILabel!
    
    @IBOutlet weak var altitudeNameLabel: UILabel!
    @IBOutlet weak var averageSpeedOrPaceNameLabel: UILabel!
    
    @IBOutlet weak var activitySnapshotImageView: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    // MARK: - Properties
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    var averageSpeed: Double?
    var currentAltitude = 0.0
    var elevationChange = 0.0
    var pace: Int?
    var timestamp: String?
    var durationInSeconds = 0
    
    let locationManager = LocationManager.shared
    var secondsTimer: Timer?
    var distanceTimer: Timer?
    var altitudeAndPaceOrSpeedTimer: Timer?
    var currentDate: Date?
    var locationList: [CLLocation] = []
    var coordinates: [CLLocationCoordinate2D] = []
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocationManager()
        hideInitialViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityTypeLabel.text = UserController.shared.user.preferredActivityType?.capitalized ?? "Run"
        activityTypeSegmentedController.selectedSegmentIndex = setActivityTypeSegmentedControllerFor(user: UserController.shared.user)
        
        invalidateTimers()
        
        locationManager.stopUpdatingLocation()
        distance = Measurement(value: 0, unit: UnitLength.meters)
    }
    
    // MARK: - Actions
    @IBAction func activitySegmentedControllerDidChange(_ sender: UISegmentedControl) {
        let activityType = setActivityTypeForActivityCreation(sender.selectedSegmentIndex)
        activityTypeLabel.text = activityType.capitalized
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        unhideInitialViews()
        durationInSeconds = 0
        currentDate = Date()
        locationList = []
        coordinates = []
        
        activityTypeSegmentedController.isUserInteractionEnabled = false
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status != .authorizedWhenInUse && status != .authorizedAlways {
            presentLocationAlert()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            activateTimers()
            
            updateAverageSpeedOrPaceLabelText()
            updateAltitudeAndPaceOrSpeedViews()
            
            pauseButton.isHidden = false
            startButton.isHidden = true
            
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
    
    @IBAction func resumeButtonTapped(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        updateAltitudeAndPaceOrSpeedViews()
        resumeButton.isHidden = true
        stopButton.isHidden = true
        pauseButton.isHidden = false
        
        activateTimers()
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        locationManager.stopUpdatingLocation()
        
        resumeButton.isHidden = false
        stopButton.isHidden = false
        pauseButton.isHidden = true
        
        invalidateTimers()
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        pauseButton.isHidden = true
        resumeButton.isHidden = true
        startButton.isHidden = false
        locationManager.stopUpdatingLocation()
        stopButton.isHidden = true
        invalidateTimers()
        
        if locationList.count >= 3 && averageSpeed != nil {
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            let mapSize = MKMapSize(width: polyline.boundingMapRect.size.width + 32, height: polyline.boundingMapRect.size.height + 32)
            let region = MKCoordinateRegionForMapRect(MKMapRect(origin: polyline.boundingMapRect.origin, size: mapSize))
            
            mapView.setVisibleMapRect(polyline.boundingMapRect, animated: true)
            mapView.setRegion(region, animated: true)
            
            saveNewWorkout()
        } else {
            resetLocalProperties()
            resetViews()
        }
        
        activityTypeSegmentedController.isUserInteractionEnabled = true
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let activityType = setActivityTypeForActivityCreation(activityTypeSegmentedController.selectedSegmentIndex)
        if segue.identifier == "toLoginScreen" {
            let destinationVC = segue.destination as? SignInViewController
            destinationVC?.activityType = activityType
        }
    }
    
    // MARK: - Methods
    func updateAverageSpeedOrPaceLabelText() {
        if activityTypeSegmentedController.selectedSegmentIndex == 0 {
            averageSpeedOrPaceNameLabel.text = "Pace"
        } else {
            averageSpeedOrPaceNameLabel.text = "Speed"
        }
    }
    
    func hideInitialViews() {
        activityTimeLabel.text = "0:00:00"
        activityTimeLabel.isHidden = true
        altitudeLabel.isHidden = true
        averageSpeedOrPaceLabel.isHidden = true
        altitudeNameLabel.isHidden = true
        averageSpeedOrPaceNameLabel.isHidden = true
        activityDistanceLabel.isHidden = true
    }
    
    func unhideInitialViews() {
        activityTimeLabel.isHidden = false
        activityDistanceLabel.isHidden = false
        altitudeLabel.isHidden = false
        altitudeNameLabel.isHidden = false
        averageSpeedOrPaceLabel.isHidden = false
        averageSpeedOrPaceNameLabel.isHidden = false
    }
    
    func activateTimers() {
        secondsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (_) in
            self.fireSecond()
        })
        altitudeAndPaceOrSpeedTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (_) in
            self.updateAltitudeAndPaceOrSpeedViews()
        })
        distanceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { (_) in
            self.updateDistanceView()
        })
    }
    
    func invalidateTimers() {
        secondsTimer?.invalidate()
        altitudeAndPaceOrSpeedTimer?.invalidate()
        distanceTimer?.invalidate()
    }
    
    func updateTimerView() {
        let timeToDisplay = FormatDisplay.time(durationInSeconds)
        activityTimeLabel.text = timeToDisplay
    }
    
    func updateDistanceView() {
        let distanceUnits = UserController.shared.user.defaultUnits == "imperial" ? "mi" : "km"
        let distanceMeasurement = Measurement(value: Double(distance.value), unit: UnitLength.meters)
        let distanceToDisplay = UserController.shared.user.defaultUnits == "imperial" ? ActivityUnitConverter.milesFromMeters(distance: distanceMeasurement) : ActivityUnitConverter.kilometersFromMeters(distance: distanceMeasurement)
        activityDistanceLabel.text = "\(distanceToDisplay.roundedDoubleString) \(distanceUnits)"
    }
    
    func updateAltitudeAndPaceOrSpeedViews() {
        let pace = ActivityUnitConverter.formatPace(distance: distance, seconds: durationInSeconds)
        let distanceUnits = UserController.shared.user.defaultUnits == "imperial" ? "mi" : "km"

        let speedUnits = UserController.shared.user.defaultUnits == "imperial" ? "mph" : "km/h"
        let speed = UserController.shared.user.defaultUnits == "imperial" ? ActivityUnitConverter.milesPerHourFromMetersPerSecond(seconds: durationInSeconds, meters: distance) : ActivityUnitConverter.kilometersPerHourFrom(seconds: durationInSeconds, meters: distance)
        
        let activityType = setActivityTypeForActivityCreation(activityTypeSegmentedController.selectedSegmentIndex)
        
        if activityType == "run" {
            averageSpeedOrPaceLabel.text = "\(pace)/\(distanceUnits)"
        } else {
            averageSpeedOrPaceLabel.text = "\(speed.roundedDoubleString) \(speedUnits)"
        }
        
        let altitudeMeasurement = Measurement(value: currentAltitude, unit: UnitLength.meters)
        let altitudeToDisplay = UserController.shared.user.defaultUnits == "imperial" ? ActivityUnitConverter.feetFromMeters(distance: altitudeMeasurement) : currentAltitude
        let altitudeUnits = UserController.shared.user.defaultUnits == "imperial" ? "ft" : "m"
        if currentAltitude == 0 {
            altitudeLabel.text = "--"
        } else {
            altitudeLabel.text = "\(Int(altitudeToDisplay)) \(altitudeUnits)"
        }
    }
    
    func fireSecond() {
        durationInSeconds += 1
        updateTimerView()
    }
    
    func presentLocationAlert() {
        let alert = UIAlertController(title: "Your location services are disabled for this application.", message: "Please go to settings and enable location services to track your activities.", preferredStyle: .alert)
        let enableAction = UIAlertAction(title: "Go to Settings", style: .default) { (_) in
            if !CLLocationManager.locationServicesEnabled() {
                if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }
        }
        
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(enableAction)
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    
    func saveNewWorkout() {
        
        let message = MessageController.shared.createSuccessfulAddSnapShotAlertWith(title: "Saving Workout", description: "Saving your workout details and route!")
        SwiftEntryKit.display(entry: message.0, using: message.1)
        
        startButton.isHidden = false
        resumeButton.isHidden = true
        pauseButton.isHidden = true
        stopButton.isHidden = true
        mapView.showsUserLocation = false
        mapView.userTrackingMode = .none
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            
            self.takeSnapShot { (success) in
                if success {
                    
                    let activityType = self.setActivityTypeForActivityCreation(self.activityTypeSegmentedController.selectedSegmentIndex).lowercased()
                    let hour = self.currentDate?.getHour(from: self.currentDate!)
                    let timeOfDay = self.currentDate?.getTimeOfDay(from: hour!)
                    let name = "\(timeOfDay!) - \(activityType.capitalized)"
                    let averageSpeed = ActivityUnitConverter.milesPerHourFromMetersPerSecond(seconds: self.durationInSeconds, meters: self.distance)
                    let activitySnapshotImage = self.activitySnapshotImageView.image ?? UIImage(named: "defaultProfile")
                    
                    ActivityController.shared.saveActivity(type: activityType, name: name, distance: Int(self.distance.value), averageSpeed: averageSpeed, elevationChange: Int(self.elevationChange.rounded()), timestamp: (self.currentDate?.stringValue(from: self.currentDate!))!, duration: self.durationInSeconds, image: activitySnapshotImage!) { (success, activityUID) in
                        
                        if success {
                            self.resetLocalProperties()
                            guard let isAnonymousUser = Auth.auth().currentUser?.isAnonymous else { return }
                            
                            SwiftEntryKit.dismiss {
                                // Executed right after the entry has been dismissed
                                self.resetViews()
                                self.hideInitialViews()
                                if !isAnonymousUser {
                                    DispatchQueue.main.async {
                                        self.tabBarController?.selectedIndex = 1
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        self.performSegue(withIdentifier: "toLoginScreen", sender: self)
                                    }
                                }
                            }
                        } else {
                            print("Failed to save Activity.")
                        }
                    }
                } else {
                    print("Failure to save snapshot caused failure to save activity.")
                }
            }
        }
    }

    func takeSnapShot(completion: @escaping (Bool) -> Void) {
        self.activityDistanceLabel.isHidden = true
        self.activityTimeLabel.isHidden = true
        self.activityTypeLabel.isHidden = true
    
        let image = mapView.takeScreenshot(view: mapView)
        self.activitySnapshotImageView.image = image
        self.activityDistanceLabel.isHidden = false
        self.activityTimeLabel.isHidden = false
        self.activityTypeLabel.isHidden = false
        completion(true)
    }

    // Draws the polyline from the user's path onto the snapshot taken of the mapview.
    func drawLineOnImage(snapshot: MKMapSnapshot) -> UIImage {
        let image = snapshot.image
        UIGraphicsBeginImageContextWithOptions(self.activitySnapshotImageView.frame.size, true, 0)

        image.draw(at: CGPoint.zero)
        let context = UIGraphicsGetCurrentContext()
        context!.setLineWidth(2.0)
        context!.setStrokeColor(UIColor.blue.cgColor)

        context!.move(to: snapshot.point(for: coordinates[0]))
        for i in 0...coordinates.count-1 {
            context!.addLine(to: snapshot.point(for: coordinates[i]))
            context!.move(to: snapshot.point(for: coordinates[i]))
        }

        context!.strokePath()
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage!
    }
    
    // Allows for setting the default activityType based on the user's preference.
    func setActivityTypeSegmentedControllerFor(user: User) -> Int {
        switch (UserController.shared.user.preferredActivityType) {
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
    func setActivityTypeForActivityCreation(_ index: Int) -> String {
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
    
    // Clears out local properties to allow user to complete multiple activities without closing the app.
    func resetLocalProperties() {
        locationList = []
        coordinates = []
        distance = Measurement(value: 0, unit: UnitLength.meters)
        averageSpeed = 0
        currentAltitude = 0.0
        elevationChange = 0.0
        updateAltitudeAndPaceOrSpeedViews()
        durationInSeconds = 0
        activityTimeLabel.text = "0:00:00"
        mapView.removeOverlays(self.mapView.overlays)
    }
    
    func resetViews() {
        activityTimeLabel.text = ""
        activityDistanceLabel.text = ""
        altitudeLabel.text = ""
        averageSpeedOrPaceLabel.text = ""
    }
  
}

extension NewActivityViewController: CLLocationManagerDelegate {
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            currentAltitude = newLocation.altitude
            
            if let lastLocation = locationList.last {
                let distanceTraveled = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: distanceTraveled, unit: UnitLength.meters)
                elevationChange += abs(Double(newLocation.altitude))
                let locationCoordinates = locationList.compactMap { $0.coordinate }
                let polyline = MKPolyline(coordinates: locationCoordinates, count: locationCoordinates.count)
                mapView.add(polyline)
            }
            
            locationList.append(newLocation)
            coordinates.append(newLocation.coordinate)
        }
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager failed with error: \(error.localizedDescription).")
    }
}

extension NewActivityViewController: MKMapViewDelegate {
    
    func setupMapView() {
        mapView.delegate = self
        mapView.mapType = .standard
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 3
            return polylineRenderer
        }
        
        return MKOverlayRenderer()
    }
}

extension MKMapView {
    
    func takeScreenshot(view: MKMapView) -> UIImage {
        // Begin context
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, view.contentScaleFactor)
        
        // Draw view in that context
        drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}

