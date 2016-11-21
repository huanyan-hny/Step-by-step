//
//  SecondViewController.swift
//  Step by step
//
//  Created by Troy on 15/4/18.
//  Copyright (c) 2015年 Huanyan's. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import CoreData
import MapKit

class RunningViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    
    @IBOutlet weak var startRunningButton: UIButton!
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
    
    var locationManager:CLLocationManager!
    var managedObjectContext:NSManagedObjectContext?
    
    func initLocationManager() {
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.activityType = .fitness
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let lastUpdatedLocation = locations.last! as CLLocation
//    
//        let center = CLLocationCoordinate2D(latitude: lastUpdatedLocation.coordinate.latitude, longitude: lastUpdatedLocation.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//    
//        mapView.setRegion(region, animated: true)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
//        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Running";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 127/255, green: 224/255, blue: 127/255, alpha: 1)
        self.startRunningButton.layer.cornerRadius = 20
        initLocationManager()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? InRunningViewController {
            destination.managedObjectContext = self.managedObjectContext
            destination.locationManager = self.locationManager
            destination.startRunning()
        }
    }
    
}

