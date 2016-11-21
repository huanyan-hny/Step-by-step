//
//  InRunningViewController.swift
//  Step by step
//
//  Created by Troy on 15/11/25.
//  Copyright © 2015年 Huanyan's. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import CoreData
import MapKit


class InRunningViewController: UIViewController,CLLocationManagerDelegate {

    
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var averagePaceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var locationManager:CLLocationManager!
    var managedObjectContext:NSManagedObjectContext?
    var run:Run?
    
    var seconds = 0.0
    var distance = 0.0
    
    lazy var locations = [CLLocation]()
    lazy var timer = Timer()
    
    func startRunning() {
        locationManager.startUpdatingLocation()
        print("Started running")
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepingCapacity: false)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(InRunningViewController.eachSecond(_:)), userInfo: nil, repeats: true)
    }
    
    
    func eachSecond(_ timer:Timer) {
        print("ticking")
        seconds += 1
        let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: seconds)
        timeLabel.text = secondsQuantity.description
        let displayDistance = Double(round(distance*100)/100)
        distanceLabel.text = "\(displayDistance) km"
    }
    
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updated location")
        for location in locations {
            if location.horizontalAccuracy < 20 {
                if self.locations.count>0 {
                    distance += location.distance(from: self.locations.last!) / 1000.0
                }
            }
            self.locations.append(location)
        }
    }
    
    func saveRun() {
        
        let savedRun = NSEntityDescription.insertNewObject(forEntityName: "Run", into:managedObjectContext!) as! Run
        
        savedRun.distance = distance as NSNumber?
        savedRun.duration = seconds as NSNumber?
        savedRun.timestamp = Date()
        
        var savedLocations = [Location]()
        for location in locations {
            let savedLocation = NSEntityDescription.insertNewObject(forEntityName: "Location",
                into: managedObjectContext!) as! Location
            savedLocation.timestamp = location.timestamp
            savedLocation.latitude = location.coordinate.latitude as NSNumber?
            savedLocation.longitude = location.coordinate.longitude as NSNumber?
            savedLocations.append(savedLocation)
        }
        
        savedRun.locations = NSOrderedSet(array: savedLocations)
        run = savedRun
        
        do{ try managedObjectContext!.save()} catch _ { print("Could not save run!")}
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager?.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.hidesBackButton = true
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        locationManager.stopUpdatingLocation()
        saveRun()
        if let destination = segue.destination as? RunningResultViewController {
            destination.run = self.run
        }
    }
}

