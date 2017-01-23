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



class InRunningViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var averagePaceLabel: UILabel!
    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var higherSeparateView: UIView!
    @IBOutlet weak var lowerSeparateView: UIView!
    @IBOutlet weak var gpsStrengthIcon: UIImageView!
    @IBOutlet weak var gpsStrengthText: UILabel!
    
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
    
    var locationManager:CLLocationManager!
    var managedObjectContext:NSManagedObjectContext?
    
    var seconds = 0
    var distance = 0.0
    var pace = 0
    var energy = 0
    var paused = false
    var resumedFromPausing = false
    var city: String?
    var country:String?
    var address:String?
    
    lazy var locations = [CLLocation]()
    lazy var pauseLocations = [CLLocation]()
    lazy var timer = Timer()
    
    let pedometer = Pedometer.sharedInstance
    let language = UserDefaults.standard.array(forKey: "AppleLanguages")!.first as! String
    var startTime = Date()
    
    
    func startRunning() {
        print("Started running")
        startTime = Date()
        seconds = 0
        distance = 0.0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(InRunningViewController.eachSecond(_:)), userInfo: nil, repeats: true)
        getLocation()
    }
    
    func getLocation() {
        CLGeocoder().reverseGeocodeLocation(locations.first!, completionHandler: {(placemarks, error) -> Void in
            if error == nil {
                if let addr = placemarks?.first?.addressDictionary {
                    print (addr)
                    
                    if let address = addr["Thoroughfare"] as? String {
                        print (address)
                        self.address = address
                    }
                    
                    if let city = addr["City"] as? String {
                        print(city)
                        self.city = city
                    }
                    
                    if let country = addr["Country"] as? String {
                        print(country)
                        self.country = country
                    }
                }
            }
        })

    }
    
    
    func eachSecond(_ timer:Timer) {
        if !paused {
            print(seconds)
            seconds += 1
            
            let displayDistance:String
            if (language == "zh_Hans") {
                displayDistance = String(format:"%.1f", Double(round(distance*10)/10))
            } else {
                displayDistance = String(format:"%.1f", Double(round((distance/1.60934)*10)/10))
            }
            
            let displayTime = Time.secondsFormatted(seconds: seconds)
            
            timeLabel.text = displayTime
            distanceLabel.text = displayDistance
            
            pedometer.queryPedometerData(from: startTime, to: Date(), withHandler: {data, error in
                if (error==nil) {
                    DispatchQueue.main.async {
                        self.stepLabel.text = "\(Int(data!.numberOfSteps.int32Value))"
                    }
                }
            })
            
            
            if (seconds>0 && distance>0 && seconds%4==0) {
                pace = Int(Double(seconds)/distance)
                let displayPace:String
                if (language == "zh_Hans") {
                    displayPace = Time.secondsFormatted(seconds:pace)
                } else {
                    displayPace = Time.secondsFormatted(seconds:(Int(Double(pace)*1.60934)))
                }
                averagePaceLabel.text = displayPace
                
                if (seconds%10==0) {
                    energy = Int(70*distance*1.036)
                    energyLabel.text = "\(energy)"
                }
            }
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updated")
        let lastUpdatedLocation = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: lastUpdatedLocation.coordinate.latitude, longitude: lastUpdatedLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta:0.001))
        
        mapView.setRegion(region, animated: true)
        
        if let accuracy = locationManager.location?.horizontalAccuracy {
            if (accuracy<0) {
                gpsStrengthIcon.image = #imageLiteral(resourceName: "signal_none")
                gpsStrengthText.text = NSLocalizedString("No GPS", comment: "")
                gpsStrengthText.textColor = UIColor(red: 207.0/255.0, green: 216.0/255.0, blue: 220.0/255.0, alpha: 1)
            } else if (accuracy < 48) {
                gpsStrengthIcon.image = #imageLiteral(resourceName: "signal_good")
                gpsStrengthText.text = NSLocalizedString("Good GPS", comment: "")
                gpsStrengthText.textColor = UIColor(red: 139.0/255.0, green: 195.0/255.0, blue: 74.0/255.0, alpha: 1)
            } else if (accuracy > 163) {
                gpsStrengthIcon.image = #imageLiteral(resourceName: "signal_poor")
                gpsStrengthText.text = NSLocalizedString("Poor GPS", comment: "")
                gpsStrengthText.textColor = UIColor(red: 237.0/255.0, green: 28.0/255.0, blue: 36.0/255.0, alpha: 1)
            } else {
                gpsStrengthIcon.image = #imageLiteral(resourceName: "signal_fair")
                gpsStrengthText.text = NSLocalizedString("Fair GPS", comment: "")
                gpsStrengthText.textColor = UIColor(red: 248.0/255.0, green: 127.0/255.0, blue: 39.0/255.0, alpha: 1)
            }
        }
        
        if !paused {
            for location in locations {
                if location.horizontalAccuracy < 163 {
                    if self.locations.count>0 && seconds>1 {
                        let increment = location.distance(from: self.locations.last!) / 1000.0
                        print(increment)
                        if increment > 0.005 {
                            if !resumedFromPausing {
                                distance += increment
                            } else {
                                resumedFromPausing = false
                            }
                            self.locations.append(location)
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    @IBAction func togglePause(_ sender: UIButton) {
        if let pauseLocation = mapView.userLocation.location {
            pauseLocations.append(pauseLocation)
        }
        if (paused == false){
            paused = true
            pauseButton.setTitle(NSLocalizedString("Resume", comment: ""), for: .normal)
            pauseButton.backgroundColor = UIColor(red:53.0/255.0, green:204.0/255.0, blue:113.0/255.0, alpha:1.0)
        } else {
            paused = false
            resumedFromPausing = true
            pauseButton.setTitle(NSLocalizedString("Pause", comment: ""), for: .normal)
            pauseButton.backgroundColor = UIColor(red:49.0/255.0,green:168.0/255.0,blue:213.0/255.0,alpha:1.0)
        }
    }
    
    @IBAction func stopRunning(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("Stop running?", comment: ""), preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) {(action) in}
        
        alertController.addAction(cancelAction)
        
        let changeAction = UIAlertAction(title: NSLocalizedString("Stop", comment: ""), style:.destructive) { (action) in
            self.performSegue(withIdentifier: "stopRunning", sender: self)
        }
        alertController.addAction(changeAction)
        
        self.navigationController?.present(alertController, animated: true,completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.hidesBackButton = true
        self.pauseButton.layer.cornerRadius = 20
        self.stopButton.layer.cornerRadius = 20
        self.higherSeparateView.layer.borderWidth = 0.5
        self.higherSeparateView.layer.borderColor = UIColor(red: 221.0/255.0, green: 221.0/255.0, blue: 221.0/255.0, alpha: 1).cgColor
        self.lowerSeparateView.layer.borderWidth = 0.5
        self.lowerSeparateView.layer.borderColor = UIColor(red: 221.0/255.0, green: 221.0/255.0, blue: 221.0/255.0, alpha: 1).cgColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        timer.invalidate()
        if let destination = segue.destination as? RunningResultViewController {
            locationManager.stopUpdatingLocation()
            destination.managedObjectContext = self.managedObjectContext
            destination.seconds = seconds
            destination.distance = distance
            destination.pace = pace
            destination.energy = energy
            destination.date = Date()
            var savedLocations = [Location]()
            for location in locations {
                let savedLocation = NSEntityDescription.insertNewObject(forEntityName: "Location",
                                                                        into: managedObjectContext!) as! Location
                savedLocation.timestamp = location.timestamp
                savedLocation.latitude = location.coordinate.latitude as NSNumber?
                savedLocation.longitude = location.coordinate.longitude as NSNumber?
                savedLocations.append(savedLocation)
            }
            
            var savedPauseLocations = [PauseLocation]()
            for pauseLocation in pauseLocations {
                let savedPauseLocation = NSEntityDescription.insertNewObject(forEntityName: "PauseLocation", into: managedObjectContext!) as! PauseLocation
                savedPauseLocation.timestamp = pauseLocation.timestamp
                savedPauseLocation.latitude = pauseLocation.coordinate.latitude as NSNumber?
                savedPauseLocation.longitude = pauseLocation.coordinate.longitude as NSNumber?
                savedPauseLocations.append(savedPauseLocation)
            }
            destination.locations = NSOrderedSet(array: savedLocations)
            destination.pauseLocations = NSOrderedSet(array: savedPauseLocations)
            destination.city = self.city
            destination.country = self.country
            destination.address = self.address
        }
    }
}
