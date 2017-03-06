//
//  ViewController.swift
//  GeoTargeting
//
//  Created by Eugene Trapeznikov on 4/23/16.
//  Copyright © 2016 Evgenii Trapeznikov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications
import Firebase

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

	@IBOutlet weak var mapView: MKMapView!

	let locationManager = CLLocationManager()
	var monitoredRegions: Dictionary<String, Date> = [:]
    

	override func viewDidLoad() {
		super.viewDidLoad()

		// setup locationManager
		locationManager.delegate = self;
		locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;

		// setup mapView
		mapView.delegate = self
		mapView.showsUserLocation = true
		mapView.userTrackingMode = .follow

		// setup test data
		setupData()
        print(getDate())
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// status is not determined
		if CLLocationManager.authorizationStatus() == .notDetermined {
			locationManager.requestAlwaysAuthorization()
		}
		// authorization were denied
		else if CLLocationManager.authorizationStatus() == .denied {
			showAlert("Location services were previously denied. Please enable location services for this app in Settings.")
		}
		// we do have authorization
		else if CLLocationManager.authorizationStatus() == .authorizedAlways {
			locationManager.startUpdatingLocation()
		}
	}
    func getDate()->String{
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        _ = formatter.string(from: date as Date)
        // "2014-07-23 11:01:35 -0700" <-- same date, local, but with seconds
        formatter.timeZone = TimeZone.current
        let utcTimeZoneStr = formatter.string(from: date as Date)
        return utcTimeZoneStr
    }
    
    func appendData(data:String, type:String){
        let ref = FIRDatabase.database().reference().child("putcygov").child("Recs")
        ref.childByAutoId().setValue([data,type])
        
    }
    
    func notify(text:String, type:String){
        print("arrived")
        
        appendData(data:getDate(), type:type)
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "Hello!", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: text, arguments: nil)
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "notify-test"
            
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest.init(identifier: "notify-test", content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request)
        } else {
            // Fallback on earlier versions
        }
        
    }
	func setupData() {
		// check if can monitor regions
		if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {

			// region data
			let title = "Dilax"
			let coordinate = CLLocationCoordinate2DMake(52.52383,13.3428113)
//            let coordinate = CLLocationCoordinate2DMake(52.5240818,13.415317)//Home
			let regionRadius = 300.0

			// setup region
			let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
				longitude: coordinate.longitude), radius: regionRadius, identifier: title)
			locationManager.startMonitoring(for: region)

			// setup annotation
			let restaurantAnnotation = MKPointAnnotation()
			restaurantAnnotation.coordinate = coordinate;
			restaurantAnnotation.title = "\(title)";
			mapView.addAnnotation(restaurantAnnotation)

			// setup circle
			let circle = MKCircle(center: coordinate, radius: regionRadius)
			mapView.add(circle)
		}
		else {
			print("System can't track regions")
		}
	}

	// MARK: - MKMapViewDelegate

	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let circleRenderer = MKCircleRenderer(overlay: overlay)
		circleRenderer.strokeColor = UIColor.red
		circleRenderer.lineWidth = 1.0
		return circleRenderer
	}

	// MARK: - CLLocationManagerDelegate

	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		notify(text: "enter \(region.identifier)", type: "enter")
//        showAlert("enter \(region.identifier)")
		monitoredRegions[region.identifier] = Date()
	}

	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		notify(text: "exit \(region.identifier)", type: "leave")
//        showAlert("exit \(region.identifier)")
		monitoredRegions.removeValue(forKey: region.identifier)
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		updateRegionsWithLocation(locations[0])
	}

	// MARK: - Comples business logic

	func updateRegionsWithLocation(_ location: CLLocation) {

		let regionMaxVisiting = 10.0
		var regionsToDelete: [String] = []

		for regionIdentifier in monitoredRegions.keys {
			if Date().timeIntervalSince(monitoredRegions[regionIdentifier]!) > regionMaxVisiting {
//				showAlert("Thanks for visiting our restaurant")

				regionsToDelete.append(regionIdentifier)
			}
		}

		for regionIdentifier in regionsToDelete {
			monitoredRegions.removeValue(forKey: regionIdentifier)
		}
	}

	// MARK: - Helpers

	func showAlert(_ title: String) {
		let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
			alert.dismiss(animated: true, completion: nil)
		}))
		self.present(alert, animated: true, completion: nil)

	}
}

