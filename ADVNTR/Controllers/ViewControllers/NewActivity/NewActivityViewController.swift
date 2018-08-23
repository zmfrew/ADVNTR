//
//  NewActivityViewController.swift
//  ADVNTR
//
//  Created by Owen Henley on 8/21/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit
import MapKit

class NewActivityViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var activityTypeLabel: UILabel!
    @IBOutlet weak var activityTypeSegmentedController: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityTimeLabel: UILabel!
    @IBOutlet weak var activityDistanceLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var averageSpeedOrPaceLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var activitySnapshotImageView: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Properties
    var user: User?
    
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    var averageSpeed: Double?
    var currentAltitude = 0.0
    var elevationChange = 0.0
    var averageHeartRate: String?
    var pace: Int?
    var timestamp: String?
    var durationInSeconds = 0
    var activitySnapShotImage: UIImage?
    
    let locationManager = LocationManager.shared
    var timer: Timer?
    var currentDate: Date?
    var locationList: [CLLocation] = []
    var coordinates: [CLLocationCoordinate2D] = []
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocationManager()
        activityTypeLabel.text = user?.preferredActivityType ?? "Run"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        distance = Measurement(value: 0, unit: UnitLength.meters)
    }
    
    // MARK: - Actions
    @IBAction func activitySegmentedControllerDidChange(_ sender: UISegmentedControl) {
        let activityType = setActivityTypeForActivityCreation(sender.selectedSegmentIndex)
        activityTypeLabel.text = activityType
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        durationInSeconds = 0
        currentDate = Date()
        locationList = []
        
        activityTypeSegmentedController.isUserInteractionEnabled = false
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status != .authorizedWhenInUse && status != .authorizedAlways {
            presentLocationAlert()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (_) in
            self.fireSecond()
        })
        updateViews()
        pauseButton.isHidden = false
        startButton.isHidden = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    @IBAction func resumeButtonTapped(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        updateViews()
        resumeButton.isHidden = true
        stopButton.isHidden = true
        pauseButton.isHidden = false
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        locationManager.stopUpdatingLocation()
        resumeButton.isHidden = false
        stopButton.isHidden = false
        pauseButton.isHidden = true
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        pauseButton.isHidden = true
        resumeButton.isHidden = true
        saveButton.isHidden = false
        locationManager.stopUpdatingLocation()
        stopButton.isHidden = true
//        takeSnapShot()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        startButton.isHidden = false
        resumeButton.isHidden = true
        pauseButton.isHidden = true
        stopButton.isHidden = true
        saveButton.isHidden = true
        // Stops tracking location
        mapView.showsUserLocation = false
        mapView.userTrackingMode = .none
        
        activityTypeSegmentedController.isUserInteractionEnabled = true
        
        // Pass all data forward and create new activity.
        let activityType = setActivityTypeForActivityCreation(activityTypeSegmentedController.selectedSegmentIndex)
        let hour = currentDate?.getHour(from: currentDate!)
        let timeOfDay = currentDate?.getTimeOfDay(from: hour!)
        let name = "\(timeOfDay!) - \(activityType)"
        let averageSpeed = ActivityUnitConverter.milesPerHourFromMetersPerSecond(seconds: durationInSeconds, meters: distance)
        
        let newActivity = Activity(uid: "uid", type: activityType, name: name, distance: distance.value, averageSpeed: averageSpeed, elevationChange: Int(elevationChange.rounded()), averageHeartRate: "Heart rate", pace: 8, timestamp: (currentDate?.stringValue(from: currentDate!))!, duration: durationInSeconds, activitySnapshotImage: activitySnapshotImageView.image ?? UIImage())
        // TODO: - Save new activity.
        resetLocalProperties()
    }
    
    // MARK: - Methods
    func updateViews() {
        let formattedDistance = FormatDisplay.distance(distance.value)
        let formattedTime = FormatDisplay.time(durationInSeconds)
        let formattedPace = FormatDisplay.pace(distance: distance, seconds: durationInSeconds, outputUnit: UnitSpeed.minutesPerMile)
        // TODO: - Implement formatted speed display if it is not a run.
//        let formattedSpeed =
        // TODO: - Implement formatted heart rate display.
        let currentSpeed = ActivityUnitConverter.milesPerHourFromMetersPerSecond(seconds: durationInSeconds, meters: distance)
        
        activityTimeLabel.text = formattedTime
        activityDistanceLabel.text = formattedDistance
        
        altitudeLabel.text = "\(currentAltitude)"
        averageSpeedOrPaceLabel.text = "\(currentSpeed.rounded())"
    }
    
    func fireSecond() {
        durationInSeconds += 1
        updateViews()
    }
    
    func presentLocationAlert() {
        let alert = UIAlertController(title: "Your location services are disabled for this application.", message: "Please enable location services to track your activity.", preferredStyle: .alert)
        let enableAction = UIAlertAction(title: "Go to Settings", style: .default) { (_) in
            if !CLLocationManager.locationServicesEnabled() {
                if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                    // If general location settings are disabled then open general location settings
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    // If general location settings are enabled then open location settings for the app
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(enableAction)
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
        
    // The following two methods are not useful until we have a Stop and Save feature. In addition, we will return a UIImage from takeSnapShot() to pass into the save function, thus saving to the model.
    func takeSnapShot() {
        let mapSnapShotOptions = MKMapSnapshotOptions()

        let coordinates = locationList.compactMap { $0.coordinate }
        let polyline = MKPolyline(coordinates: coordinates, count: locationList.count)
        let region = MKCoordinateRegionForMapRect(polyline.boundingMapRect)

        mapSnapShotOptions.region = region
        mapSnapShotOptions.scale = UIScreen.main.scale
        mapSnapShotOptions.size = CGSize(width: 343.0, height: 208.0)
        mapSnapShotOptions.showsBuildings = true
        mapSnapShotOptions.showsPointsOfInterest = true

        let snapShotter = MKMapSnapshotter(options: mapSnapShotOptions)

        snapShotter.start { (snapshot, error) in
            if let error = error {
                print("Error occurred snapshotting mapview: \(error.localizedDescription).")
            }

            guard let snapshot = snapshot else { return }

            self.activitySnapshotImageView.isHidden = false
            self.activitySnapshotImageView.image = self.drawLineOnImage(snapshot: snapshot)
        }
    }

    func drawLineOnImage(snapshot: MKMapSnapshot) -> UIImage {
        let image = snapshot.image
        UIGraphicsBeginImageContextWithOptions(self.activitySnapshotImageView.frame.size, true, 0)
        // draw original image into the context
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
        switch (user.preferredActivityType) {
        case "Run":
            return 0
        case "Hike":
            return 1
        case "Bike":
            return 2
        default:
            return 0
        }
    }

    // Sets the activityType based on the selected segment in segmented controller.
    func setActivityTypeForActivityCreation(_ index: Int) -> String {
        switch (index) {
        case 0:
            return "Run"
        case 1:
            return "Hike"
        case 2:
            return "Bike"
        default:
            return "Run"
        }
    }
    
    func resetLocalProperties() {
        timer?.invalidate()
        locationList = []
        coordinates = []
        distance = Measurement(value: 0, unit: UnitLength.meters)
        averageSpeed = 0
        currentAltitude = 0.0
        elevationChange = 0.0
        updateViews()
        activityTimeLabel.text = "0:00:00"
    }
  
}

extension NewActivityViewController: CLLocationManagerDelegate {
    
    func setupLocationManager() {
        locationManager.delegate = self
        // TODO: - Choose activity type based on the user's selection of the workout.
//        locationManager.activityType =
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
        // TODO: - Decide which map type we would like to display.
        mapView.mapType = .hybrid
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
