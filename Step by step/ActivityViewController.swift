//
//  ActivityViewController.swift
//  Step by step
//
//  Created by Troy on 16/9/2.
//  Copyright © 2016年 Huanyan's. All rights reserved.
//

import UIKit
import MapKit
import HealthKit
import CoreData
import AWSDynamoDB

class ActivityViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var averagePaceLabel: UILabel!
    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet var weahters: [UIImageView]!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    
    var managedObjectContext:NSManagedObjectContext?
    let objectMapper = AWSDynamoDBObjectMapper.default()
    let activityView = UIView(frame:CGRect(x:0,y:0,width:80,height:80))
    let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
    let component = Calendar.current.dateComponents([.weekOfYear, .day, .month,.year,.weekday], from: Date())
    let userID = UserDefaults.standard.string(forKey: "userID")
    let language = UserDefaults.standard.array(forKey: "AppleLanguages")!.first as! String
    
    
    var run:Run?
    
    func updateUI() {
        let displayTime = Time.secondsFormatted(seconds: run!.time!.intValue)
        let displayEnergy = run!.energy!.intValue
        let displayDistance:String
        let displayPace:String
        
        if (language == "zh-Hans") {
            displayDistance = String(format:"%.1f", Double(round(run!.distance!.doubleValue*10)/10))
            displayPace = Time.secondsFormatted(seconds: run!.pace!.intValue)
        } else {
            displayDistance = String(format:"%.1f", Double(round((run!.distance!.doubleValue/1.60934)*10)/10))
            displayPace = Time.secondsFormatted(seconds:(Int(Double(run!.pace!.intValue)*1.60934)))
        }
        
        timeLabel.text = displayTime
        distanceLabel.text = displayDistance
        averagePaceLabel.text = displayPace
        energyLabel.text = "\(displayEnergy)"
        
        let weather = run!.weather!
        
        switch weather {
            case "Sunny":
                weahters[0].image = #imageLiteral(resourceName: "Sunny")
            case "Partly Cloudy":
                weahters[1].image = #imageLiteral(resourceName: "Partly Cloudy")
            case "Cloudy":
                weahters[2].image = #imageLiteral(resourceName: "Cloudy")
            case "Rainy":
                weahters[3].image = #imageLiteral(resourceName: "Rainy")
            case "Snowy":
                weahters[4].image = #imageLiteral(resourceName: "Snowy")
            default:
                print("No weather information")
        }
        
        if (language == "zh-Hans") {
            if (run!.address_zh != nil && run!.city_zh != nil) {
                locationLabel.text = run!.address_zh! + ", " + run!.city_zh!
            }
        } else {
            if (run!.address != nil && run!.city != nil) {
                locationLabel.text = run!.address! + ", " + run!.city!
            }
        }
        
        
        let notes = run!.notes
        if (notes == "") {
            notesLabel.text = NSLocalizedString("There are no notes for this run", comment: "")
        } else {
            notesLabel.text = notes
        }
        markAnnotations()
        loadMap()
    }
    
    func markAnnotations() {
        let locations = run!.locations!.array as! [Location]
        let begin = locations[0]
        let end = locations.last
        let beginAnno = CustomPointAnnotation()
        let endAnno = CustomPointAnnotation()
        beginAnno.coordinate = CLLocationCoordinate2D(latitude: begin.latitude!.doubleValue, longitude: begin.longitude!.doubleValue)
        beginAnno.imageName = "runningBegin"
        endAnno.coordinate = CLLocationCoordinate2D(latitude: end!.latitude!.doubleValue, longitude: end!.longitude!.doubleValue)
        endAnno.imageName = "runningEnd"
        mapView.addAnnotation(beginAnno)
        mapView.addAnnotation(endAnno)
        
        let pauseLocations = run!.pausedLocations!.array as! [PauseLocation]
        
        for pause in pauseLocations {
            let pauseAnno = CustomPointAnnotation()
            pauseAnno.coordinate = CLLocationCoordinate2D(latitude: pause.latitude!.doubleValue, longitude: pause.longitude!.doubleValue)
            pauseAnno.imageName = "runningPause"
            mapView.addAnnotation(pauseAnno)
        }

    }
    
    func mapRegion() -> MKCoordinateRegion {
        
        let initialLoc = run!
            .locations!.firstObject as! Location
        
        var minLat = initialLoc.latitude!.doubleValue
        var minLng = initialLoc.longitude!.doubleValue
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = run!.locations!.array as! [Location]
        
        for location in locations {
            minLat = min(minLat, location.latitude!.doubleValue)
            minLng = min(minLng, location.longitude!.doubleValue)
            maxLat = max(maxLat, location.latitude!.doubleValue)
            maxLng = max(maxLng, location.longitude!.doubleValue)
        }
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                longitude: (minLng + maxLng)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.5,
                longitudeDelta: (maxLng - minLng)*1.5))
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 5
        return renderer
    }
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        let locations = run!.locations!.array as! [Location]
        for location in locations {
            coords.append(CLLocationCoordinate2D(latitude: location.latitude!.doubleValue,
                longitude: location.longitude!.doubleValue))
        }
        
        return MKPolyline(coordinates: &coords, count: run!.locations!.count)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let anView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        let cpa = annotation as! CustomPointAnnotation
        anView.image = UIImage(named: cpa.imageName)
        anView.centerOffset = CGPoint(x:0, y: -15)
        return anView
    }
    
    func loadMap() {
        mapView.isHidden = false
        mapView.region = mapRegion()
        mapView.add(polyline())
    }
    
    func updateWeeklyRankingTable(savedRun:Run) {
        let weekNumString = String(component.year!) + String(component.weekOfYear!)
        let weekNum = NSNumber.init(value: Int(weekNumString)!)
        objectMapper.load(WeeklyRanking.classForCoder(), hashKey: weekNum, rangeKey:userID).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
            DispatchQueue.main.async {
                if (task.error != nil) {
                    self.stopLoadingAnimation()
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to upload to server", comment: ""), message: NSLocalizedString("Please try again later", comment: "") + "(Error:\(task!.error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else if (task.result != nil) {
                    let weeklyRanking = task.result as! WeeklyRanking
                    weeklyRanking._distance = NSNumber(value: weeklyRanking._distance!.doubleValue + savedRun.distance!.doubleValue)
                    weeklyRanking._appear = UserDefaults.standard.bool(forKey: "appear") as NSNumber
                    self.objectMapper.save(weeklyRanking)
                    self.updateMonthlyRankingTable(savedRun: savedRun)
                }
                
            }
        })
    }
    
    func updateMonthlyRankingTable(savedRun:Run){
        let monthNumString = String(component.year!) + String(component.month!)
        let monthNum = NSNumber.init(value: Int(monthNumString)!)
        objectMapper.load(MonthlyRanking.classForCoder(), hashKey: monthNum, rangeKey:userID).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
            DispatchQueue.main.async {
                if (task.error != nil) {
                    self.stopLoadingAnimation()
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to upload to server", comment: ""), message: NSLocalizedString("Please try again later", comment: "") + "(Error:\(task!.error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else if (task.result != nil) {
                    let monthlyRanking = task.result as! MonthlyRanking
                    monthlyRanking._distance = NSNumber(value: monthlyRanking._distance!.doubleValue + savedRun.distance!.doubleValue)
                    monthlyRanking._appear = UserDefaults.standard.bool(forKey: "appear") as NSNumber
                    self.objectMapper.save(monthlyRanking)
                    self.updateUserTable(savedRun: savedRun)
                }
            }
        })
        
    }
    func updateUserTable(savedRun:Run) {
        objectMapper.load(User.classForCoder(), hashKey: userID!, rangeKey: nil).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
            DispatchQueue.main.async {
                if (task.error != nil) {
                    self.stopLoadingAnimation()
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to upload to server", comment: ""), message: NSLocalizedString("Please try again later", comment: "") + "(Error:\(task!.error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else if (task.result != nil) {
                    let user = task.result as! User
                    user._totalRunningDistance = NSNumber(value:user._totalRunningDistance!.doubleValue + savedRun.distance!.doubleValue)
                    self.objectMapper.save(user)
                    savedRun.synchronized = 1
                    self.stopLoadingAnimation()
                    do{ try self.managedObjectContext!.save()} catch _ { print("Could not save run!")}
                }
                
            }
        })
    }
    
    func uploadRun() {
        startLoadingAnimation()
        let savedAllTimeRun = AllTimeRun()
        savedAllTimeRun?._userId = UserDefaults.standard.string(forKey: "userID")
        savedAllTimeRun?._distance = run?.distance
        savedAllTimeRun?._duration = run?.time
        savedAllTimeRun?._energy = run?.energy
        savedAllTimeRun?._pace = run?.pace
        savedAllTimeRun?._weather = run?.weather
        savedAllTimeRun?._date = run?.date?.timeIntervalSince1970 as NSNumber?
        savedAllTimeRun?._address = run?.address
        savedAllTimeRun?._city = run?.city
        savedAllTimeRun?._country = run?.country
        
        objectMapper.save(savedAllTimeRun!, completionHandler: {(error:Error?) in
            DispatchQueue.main.async {
                if (error != nil) {
                    self.stopLoadingAnimation()
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to upload to server", comment: ""), message: NSLocalizedString("Please try again later", comment: "") + "(Error:\(error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.updateWeeklyRankingTable(savedRun:self.run!)
                }
            }
        })
        
    }

    
    func options() {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("Options", comment: ""), preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) {(action) in}
        
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style:.destructive) { (action) in
            self.deleteRun()
        }
        alertController.addAction(deleteAction)
        
        if(self.run?.synchronized?.boolValue == false) {
            let uploadAction = UIAlertAction(title: NSLocalizedString("Upload to server", comment: ""), style:.default) {(action) in
                self.uploadRun()
            }
            
            alertController.addAction(uploadAction)
        }
        
        self.navigationController?.present(alertController, animated: true,completion: nil)

    }
    
    
    
    func updateRemoveWeeklyRankingTable(savedRun:Run) {
        let weekNumString = String(component.year!) + String(component.weekOfYear!)
        let weekNum = NSNumber.init(value: Int(weekNumString)!)
        objectMapper.load(WeeklyRanking.classForCoder(), hashKey: weekNum, rangeKey:userID).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
            DispatchQueue.main.async {
                if (task.error != nil) {
                    self.stopLoadingAnimation()
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to delete run", comment: ""), message: NSLocalizedString("Please try again later", comment: "") + "(Error:\(task!.error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else if (task.result != nil) {
                    let weeklyRanking = task.result as! WeeklyRanking
                    weeklyRanking._distance = NSNumber(value: weeklyRanking._distance!.doubleValue - savedRun.distance!.doubleValue)
                    weeklyRanking._appear = UserDefaults.standard.bool(forKey: "appear") as NSNumber
                    self.objectMapper.save(weeklyRanking)
                    self.updateRemoveMonthlyRankingTable(savedRun: savedRun)
                }
                
            }
        })
    }
    
    func updateRemoveMonthlyRankingTable(savedRun:Run){
        let monthNumString = String(component.year!) + String(component.month!)
        let monthNum = NSNumber.init(value: Int(monthNumString)!)
        objectMapper.load(MonthlyRanking.classForCoder(), hashKey: monthNum, rangeKey:userID).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
            DispatchQueue.main.async {
                if (task.error != nil) {
                    self.stopLoadingAnimation()
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to delete run", comment: ""), message: NSLocalizedString("Please try again later", comment: "") + "(Error:\(task!.error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else if (task.result != nil) {
                    let monthlyRanking = task.result as! MonthlyRanking
                    monthlyRanking._distance = NSNumber(value: monthlyRanking._distance!.doubleValue - savedRun.distance!.doubleValue)
                    monthlyRanking._appear = UserDefaults.standard.bool(forKey: "appear") as NSNumber
                    self.objectMapper.save(monthlyRanking)
                    self.updateRemoveUserTable(savedRun: savedRun)
                }
            }
        })
        
    }
    func updateRemoveUserTable(savedRun:Run) {
        objectMapper.load(User.classForCoder(), hashKey: userID!, rangeKey: nil).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
            DispatchQueue.main.async {
                if (task.error != nil) {
                    self.stopLoadingAnimation()
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to delete run", comment: ""), message: NSLocalizedString("Please try again later", comment: "") + "(Error:\(task!.error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else if (task.result != nil) {
                    let user = task.result as! User
                    user._totalRunningDistance = NSNumber(value:user._totalRunningDistance!.doubleValue - savedRun.distance!.doubleValue)
                    self.objectMapper.save(user)
                    self.stopLoadingAnimation()
                    self.managedObjectContext?.delete(self.run!)
                    do{ try self.managedObjectContext?.save()} catch _ { print("Could not save!")}
                    _=self.navigationController?.popViewController(animated: true)
                }
                
            }
        })
    }
    
    func removeRunFromServer(removedRun:AllTimeRun) {
        objectMapper.remove(removedRun).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
            DispatchQueue.main.async {
                if (task.error != nil) {
                    self.stopLoadingAnimation()
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to delete run", comment: ""), message: NSLocalizedString("Please try again later", comment: "") + "(Error:\(task!.error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        return
                    }
                    
                    alertController.addAction(cancelAction)
                } else {
                    self.updateRemoveWeeklyRankingTable(savedRun: self.run!)
                }
            }
            
            return nil
        })
    }
    
    func deleteRun() {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("Delete this run?", comment: ""), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) {(action) in}
        
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style:.destructive) { (action) in
            if (self.run?.synchronized?.boolValue == false) {
                self.managedObjectContext?.delete(self.run!)
                do{ try self.managedObjectContext?.save()} catch _ { print("Could not save!")}
                _=self.navigationController?.popViewController(animated: true)
            } else {
                self.startLoadingAnimation()
                self.objectMapper.load(AllTimeRun.classForCoder(), hashKey: self.userID!, rangeKey: self.run?.date?.timeIntervalSince1970 as NSNumber?).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
                    DispatchQueue.main.async {
                        if (task.error != nil) {
                            self.stopLoadingAnimation()
                            let alertController = UIAlertController(title: NSLocalizedString("Fail to delete run", comment: ""), message: NSLocalizedString("Please try again later", comment: "") + "(Error:\(task!.error!.localizedDescription))", preferredStyle: .alert)
                            
                            let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                                return
                            }
                            
                            alertController.addAction(cancelAction)
                        } else if (task.result == nil){
                            self.stopLoadingAnimation()
                            self.managedObjectContext?.delete(self.run!)
                            do{ try self.managedObjectContext?.save()} catch _ { print("Could not save!")}
                            _=self.navigationController?.popViewController(animated: true)
                        } else if (task.result != nil) {
                            self.removeRunFromServer(removedRun: task.result as! AllTimeRun)
                        }
                    }
                    
                    return nil
                })

            }
            
        }
        alertController.addAction(deleteAction)
        
        self.navigationController?.present(alertController, animated: true,completion: nil)
    }
    
    
    func startLoadingAnimation() {
        activityIndicator.startAnimating()
        activityView.isHidden = false
    }
    
    func stopLoadingAnimation() {
        activityIndicator.stopAnimating()
        activityView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        self.navigationItem.title = dateFormatter.string(from: run!.date!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        updateUI()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:NSLocalizedString("Options", comment: ""), style:.plain, target: self, action: #selector(options))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        self.view.addSubview(activityView)
        self.view.addSubview(activityIndicator)
        activityView.center = self.view.center
        activityView.backgroundColor = UIColor(red:0,green:0,blue:0,alpha:0.7)
        activityView.layer.cornerRadius = 10
        activityView.clipsToBounds = true
        activityView.isHidden = true
        activityIndicator.center = self.view.center
    }
}

