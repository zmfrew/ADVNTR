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
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityTimeLabel: UILabel!
    @IBOutlet weak var activityDistanceLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var averageSpeedOrPaceLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    
    // MARK: - Properties
    let locationManager = LocationManager.shared
    var timer: Timer?
    var seconds = 0
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    var locationList: [CLLocation] = []
    var totalAltitudeChange = 0.0
    var currentAltitude = 0.0
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        distance = Measurement(value: 0, unit: UnitLength.meters)
    }
    
    // MARK: - Actions
    @IBAction func startButtonTapped(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        seconds = 0
//        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList = []
        
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
    }
    
    // TODO: - Create pause button.
    // TODO: - Create stop button.
    // TODO: - Create save button.
    
    // MARK: - Methods
    func updateViews() {
        let formattedDistance = FormatDisplay.distance(distance.value)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: UnitSpeed.minutesPerMile)
        // TODO: - Implement formatted speed display if it is not a run.
//        let formattedSpeed =
        // TODO: - Implement formatted heart rate display if it is not a run.
        
        activityTimeLabel.text = formattedTime
        activityDistanceLabel.text = formattedDistance
        
        altitudeLabel.text = "\(currentAltitude)"
        averageSpeedOrPaceLabel.text = formattedPace
    }
    
    func fireSecond() {
        seconds += 1
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
//    func takeSnapShot() {
//        let mapSnapShotOptions = MKMapSnapshotOptions()
//
//        let coordinates = locations.compactMap { $0.coordinate }
//        let polyline = MKPolyline(coordinates: coordinates, count: locations.count)
//        let region = MKCoordinateRegionForMapRect(polyline.boundingMapRect)
//
//        mapSnapShotOptions.region = region
//        mapSnapShotOptions.scale = UIScreen.main.scale
//        mapSnapShotOptions.size = CGSize(width: 343.0, height: 208.0)
//        mapSnapShotOptions.showsBuildings = true
//        mapSnapShotOptions.showsPointsOfInterest = true
//
//        let snapShotter = MKMapSnapshotter(options: mapSnapShotOptions)
//
//        snapShotter.start { (snapshot, error) in
//            if let error = error {
//                print("Error occurred snapshotting mapview: \(error.localizedDescription).")
//            }
//
//            guard let snapshot = snapshot else { return }
//
//            self.snapshotImageView.isHidden = false
//            self.snapshotImageView.image = self.drawLineOnImage(snapshot: snapshot)
//        }
//
//    }
//
//    func drawLineOnImage(snapshot: MKMapSnapshot) -> UIImage {
//        let image = snapshot.image
//        UIGraphicsBeginImageContextWithOptions(self.snapshotImageView.frame.size, true, 0)
//        // draw original image into the context
//        image.draw(at: CGPoint.zero)
//        let context = UIGraphicsGetCurrentContext()
//        context!.setLineWidth(2.0)
//        context!.setStrokeColor(UIColor.blue.cgColor)
//
//        context!.move(to: snapshot.point(for: coordinates[0]))
//        for i in 0...coordinates.count-1 {
//            context!.addLine(to: snapshot.point(for: coordinates[i]))
//            context!.move(to: snapshot.point(for: coordinates[i]))
//        }
//
//        context!.strokePath()
//        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return resultImage!
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
                totalAltitudeChange += abs(Double(newLocation.altitude))
                let locationCoordinates = locationList.compactMap { $0.coordinate }
                let polyline = MKPolyline(coordinates: locationCoordinates, count: locationCoordinates.count)
                mapView.add(polyline)
            }

            locationList.append(newLocation)
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
