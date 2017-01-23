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

    @IBOutlet weak var userLocationView: UIView!
    @IBOutlet weak var gpsView: UIView!
    @IBOutlet weak var gpsStrengthIcon: UIImageView!
    @IBOutlet weak var gpsStrengthText: UILabel!
    @IBOutlet weak var startRunningButton: UIButton!
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
    
    var mapViewDidFinishLoading = false
    var poorGPS = false
    var locationManager:CLLocationManager!
    var managedObjectContext:NSManagedObjectContext?
    var inRunning = false
    
    
    func disableStartRunningButton() {
        startRunningButton.isEnabled = false
        startRunningButton.backgroundColor = UIColor.lightGray
    }
    
    func enableStartRunningButton() {
        startRunningButton.isEnabled = true
        startRunningButton.backgroundColor = UIColor(red:49.0/255.0,green:168.0/255.0,blue:213.0/255.0,alpha:1.0)
    }
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        self.userLocationView.backgroundColor = UIColor.groupTableViewBackground
    }
    
    @IBAction func returnToUser(_ sender: UIButton) {
    
        let userRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta:0.01))
        
        mapView.setRegion(userRegion, animated: true)
        
        self.userLocationView.backgroundColor = UIColor.white
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        print("rendered")
        startRunningButton.backgroundColor = UIColor(red:49.0/255.0,green:168.0/255.0,blue:213.0/255.0,alpha:1.0)
        startRunningButton.isEnabled = true
    }
    
    
    
    func initLocationManager() {
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.activityType = .fitness
            if #available(iOS 9.0, *) {
                locationManager.allowsBackgroundLocationUpdates = true
            }
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let accuracy = locationManager.location?.horizontalAccuracy {
            if (accuracy<0) {
                gpsStrengthIcon.image = #imageLiteral(resourceName: "signal_none")
                gpsStrengthText.text = NSLocalizedString("No GPS", comment: "")
                gpsStrengthText.textColor = UIColor(red: 207.0/255.0, green: 216.0/255.0, blue: 220.0/255.0, alpha: 1)
                poorGPS = true
            } else if (accuracy < 48) {
                gpsStrengthIcon.image = #imageLiteral(resourceName: "signal_good")
                gpsStrengthText.text = NSLocalizedString("Good GPS", comment: "")
                gpsStrengthText.textColor = UIColor(red: 139.0/255.0, green: 195.0/255.0, blue: 74.0/255.0, alpha: 1)
                poorGPS = false
            } else if (accuracy > 163) {
                gpsStrengthIcon.image = #imageLiteral(resourceName: "signal_poor")
                gpsStrengthText.text = NSLocalizedString("Poor GPS", comment: "")
                gpsStrengthText.textColor = UIColor(red: 237.0/255.0, green: 28.0/255.0, blue: 36.0/255.0, alpha: 1)
                poorGPS = true
            } else {
                gpsStrengthIcon.image = #imageLiteral(resourceName: "signal_fair")
                gpsStrengthText.text = NSLocalizedString("Fair GPS", comment: "")
                gpsStrengthText.textColor = UIColor(red: 248.0/255.0, green: 127.0/255.0, blue: 39.0/255.0, alpha: 1)
                poorGPS = false
            }
        }
    }
    
    func isLocationAccessAuthorized() -> Bool {
        let authStatus = CLLocationManager.authorizationStatus()
        if (authStatus == .restricted || authStatus == .denied || authStatus == .notDetermined) {
            let alertController = UIAlertController(title: "Location access denied", message: "Step by step is unable to track your run, please authorize access for in your phone's Settings", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title:"Go to Settings", style: .default) {(action) in
                if let settingURL = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(settingURL as URL)
                }
            }
            alertController.addAction(openAction)
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        
        return true

    }
    
    @IBAction func startRunning(_ sender: UIButton) {
        if (isLocationAccessAuthorized()) {
            if mapView.userLocation.location != nil {
                if (poorGPS) {
                    let alertController = UIAlertController(title: "Poor or no GPS signal", message: "Step by step might be unable to track your run accurately due to poor GPS signal, continue?", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    alertController.addAction(cancelAction)
                    
                    let continueAction = UIAlertAction(title:"Continue", style: .default) {(action) in
                        self.performSegue(withIdentifier: "startRunning", sender: self)
                    }
                    
                    alertController.addAction(continueAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: "startRunning", sender: self)
                }
            }
        }
    }
    
    func appWillResignActive() {
        if (!inRunning) {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func appDidBecomeActive() {
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.tintColor = UIColor(red:49.0/255.0,green:168.0/255.0,blue:213.0/255.0,alpha:1.0)
        locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        userLocationView.layer.cornerRadius = userLocationView.frame.width/2
        userLocationView.clipsToBounds = true
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Running", comment: "")
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.startRunningButton.layer.cornerRadius = 20
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        initLocationManager()
        gpsView.layer.cornerRadius = 10
        startRunningButton.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name:NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @IBAction func unwindToRvc(segue: UIStoryboardSegue) {
        inRunning = false
        print("I'm back")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        inRunning = true
        if let destination = segue.destination as? InRunningViewController {
            destination.managedObjectContext = self.managedObjectContext
            destination.locationManager = self.locationManager
            destination.locations.removeAll(keepingCapacity: false)
            destination.locations.append(mapView.userLocation.location!)
            destination.startRunning()
        }
    }
}

