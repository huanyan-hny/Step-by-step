//
//  RunningResultViewController.swift
//  Step by step
//
//  Created by Troy on 15/10/30.
//  Copyright © 2015年 Huanyan's. All rights reserved.
//

import UIKit
import MapKit
import HealthKit
import CoreData
import AWSDynamoDB


class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String!
}

class RunningResultViewController: UIViewController,MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var averagePaceLabel: UILabel!
    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var weathers: [UIButton]!
    @IBOutlet weak var notes: UITextField!

    var textField:UITextField?
    var notesEdited = false
    
    var weather = "Sunny"
    var managedObjectContext:NSManagedObjectContext?
    
    var seconds = 0
    var distance = 0.0
    var pace = 0
    var energy = 0
    var date:Date?
    var locations:NSOrderedSet?
    var pauseLocations:NSOrderedSet?
    var city:String?
    var country:String?
    var address:String?
    
    let objectMapper = AWSDynamoDBObjectMapper.default()
    let activityView = UIView(frame:CGRect(x:0,y:0,width:80,height:80))
    let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
    let component = Calendar.current.dateComponents([.weekOfYear, .day, .month,.year,.weekday], from: Date())
    let userID = UserDefaults.standard.string(forKey: "userID")
    let language = UserDefaults.standard.array(forKey: "AppleLanguages")!.first as! String
    
    func updateUI() {
        let displayTime = Time.secondsFormatted(seconds: seconds)
        let displayEnergy = energy
        let displayDistance:String
        let displayPace:String
        if (language == "zh-Hans") {
            displayDistance = String(format:"%.2f", Double(round(distance*100)/100))
            displayPace = Time.secondsFormatted(seconds: pace)
        } else {
            displayDistance = String(format:"%.2f", Double(round((distance/1.60934)*100)/100))
            displayPace = Time.secondsFormatted(seconds:(Int(Double(pace)*1.60934)))
        }
        
        timeLabel.text = displayTime
        distanceLabel.text = displayDistance
        averagePaceLabel.text = displayPace
        energyLabel.text = "\(displayEnergy)"

        
        if (address != nil && city != nil) {
            locationLabel.text = address! + ", " + city!
        }
        
        
        loadMap()
        markAnnotations()
    }
    
    func markAnnotations() {
        let locations = self.locations!.array as! [Location]
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
        
        let pauseLocations = self.pauseLocations!.array as! [PauseLocation]
        
        for pause in pauseLocations {
            let pauseAnno = CustomPointAnnotation()
            pauseAnno.coordinate = CLLocationCoordinate2D(latitude: pause.latitude!.doubleValue, longitude: pause.longitude!.doubleValue)
            pauseAnno.imageName = "runningPause"
            mapView.addAnnotation(pauseAnno)
        }
    }
    
    
    func mapRegion() -> MKCoordinateRegion {
        
        let initialLoc = self.locations!.firstObject as! Location
        
        var minLat = initialLoc.latitude!.doubleValue
        var minLng = initialLoc.longitude!.doubleValue
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = self.locations?.array as! [Location]
        
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
        
        let locations = self.locations!.array as! [Location]
        for location in locations {
            coords.append(CLLocationCoordinate2D(latitude: location.latitude!.doubleValue,
                longitude: location.longitude!.doubleValue))
        }
        
        return MKPolyline(coordinates: &coords, count: self.locations!.count)
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
    
    @IBAction func setWeatherSunny(_ sender: UIButton) {
        weathers[0].setImage(#imageLiteral(resourceName: "Sunny"), for: .normal)
        weathers[1].setImage(#imageLiteral(resourceName: "Partly Cloudy-gray"), for: .normal)
        weathers[2].setImage(#imageLiteral(resourceName: "Cloudy-gray"), for: .normal)
        weathers[3].setImage(#imageLiteral(resourceName: "Rainy-gray"), for: .normal)
        weathers[4].setImage(#imageLiteral(resourceName: "Snowy-gray"), for: .normal)
        self.weather = "Sunny"
    }
    @IBAction func setWeatherPartlyCloudy(_ sender: UIButton) {
        weathers[0].setImage(#imageLiteral(resourceName: "Sunny-gray"), for: .normal)
        weathers[1].setImage(#imageLiteral(resourceName: "Partly Cloudy"), for: .normal)
        weathers[2].setImage(#imageLiteral(resourceName: "Cloudy-gray"), for: .normal)
        weathers[3].setImage(#imageLiteral(resourceName: "Rainy-gray"), for: .normal)
        weathers[4].setImage(#imageLiteral(resourceName: "Snowy-gray"), for: .normal)
        self.weather = "Partly Cloudy"
    }
    @IBAction func setWeatherCloudy(_ sender: UIButton) {
        weathers[0].setImage(#imageLiteral(resourceName: "Sunny-gray"), for: .normal)
        weathers[1].setImage(#imageLiteral(resourceName: "Partly Cloudy-gray"), for: .normal)
        weathers[2].setImage(#imageLiteral(resourceName: "Cloudy"), for: .normal)
        weathers[3].setImage(#imageLiteral(resourceName: "Rainy-gray"), for: .normal)
        weathers[4].setImage(#imageLiteral(resourceName: "Snowy-gray"), for: .normal)
        self.weather = "Cloudy"
    }
    @IBAction func setWeatherRainy(_ sender: UIButton) {
        weathers[0].setImage(#imageLiteral(resourceName: "Sunny-gray"), for: .normal)
        weathers[1].setImage(#imageLiteral(resourceName: "Partly Cloudy-gray"), for: .normal)
        weathers[2].setImage(#imageLiteral(resourceName: "Cloudy-gray"), for: .normal)
        weathers[3].setImage(#imageLiteral(resourceName: "Rainy"), for: .normal)
        weathers[4].setImage(#imageLiteral(resourceName: "Snowy-gray"), for: .normal)
        self.weather = "Rainy"
    }
    @IBAction func setWeatherSnowy(_ sender: UIButton) {
        weathers[0].setImage(#imageLiteral(resourceName: "Sunny-gray"), for: .normal)
        weathers[1].setImage(#imageLiteral(resourceName: "Partly Cloudy-gray"), for: .normal)
        weathers[2].setImage(#imageLiteral(resourceName: "Cloudy-gray"), for: .normal)
        weathers[3].setImage(#imageLiteral(resourceName: "Rainy-gray"), for: .normal)
        weathers[4].setImage(#imageLiteral(resourceName: "Snowy"), for: .normal)
        self.weather = "Snowy"
    }

    func persistRun() {
        textField!.resignFirstResponder()
        notes.resignFirstResponder()
        startLoadingAnimation()
        let savedRun = NSEntityDescription.insertNewObject(forEntityName: "Run", into:managedObjectContext!) as! Run
        savedRun.userID = UserDefaults.standard.string(forKey: "userID")
        savedRun.distance = distance as NSNumber?
        savedRun.time = seconds as NSNumber?
        savedRun.energy = energy as NSNumber?
        savedRun.pace = pace as NSNumber?
        savedRun.locations = locations
        savedRun.pausedLocations = pauseLocations
        savedRun.weather = weather
        savedRun.notes = notes.text
        savedRun.date = date
        savedRun.address = address
        savedRun.city = city
        savedRun.country = country

        if (distance>=6) {
            updateRunAchievement(id: 3)
        }
        
        if (distance>=13) {
            updateRunAchievement(id: 4)
        }
        
        if (distance>=26) {
            updateRunAchievement(id: 5)
        }
        updateRunRecord(run: savedRun)
        
        let savedAllTimeRun = AllTimeRun()
        savedAllTimeRun?._userId = UserDefaults.standard.string(forKey: "userID")
        savedAllTimeRun?._distance = distance as NSNumber?
        savedAllTimeRun?._duration = seconds as NSNumber?
        savedAllTimeRun?._energy = energy as NSNumber?
        savedAllTimeRun?._pace = pace as NSNumber?
        savedAllTimeRun?._weather = weather
        savedAllTimeRun?._date = date?.timeIntervalSince1970 as NSNumber?
        savedAllTimeRun?._address = address
        savedAllTimeRun?._city = city
        savedAllTimeRun?._country = country
        if (notes.text != "") {
            savedAllTimeRun?._notes = notes.text
        }
        
        objectMapper.save(savedAllTimeRun!, completionHandler: {(error:Error?) in
            DispatchQueue.main.async {
                if (error != nil) {
                    self.stopLoadingAnimation()
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to upload to server", comment: ""), message: NSLocalizedString("You can upload the run later in running history", comment: "") + "(Error:\(error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        savedRun.synchronized = 0
                        do{ try self.managedObjectContext!.save()} catch _ { print("Could not save run!")}
                        self.performSegue(withIdentifier: "unwindToRvc", sender: self)
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    if (self.pace < 250 && self.pace > 0) {
                        self.stopLoadingAnimation()
                        let alertController = UIAlertController(title: NSLocalizedString("You ran too fast", comment: ""), message: NSLocalizedString("This run will not get ranked", comment:""), preferredStyle: .alert)
                        
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                            savedRun.synchronized = 1
                            do{ try self.managedObjectContext!.save()} catch _ { print("Could not save run!")}
                            self.performSegue(withIdentifier: "unwindToRvc", sender: self)
                        }
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        self.updateWeeklyRankingTable(savedRun:savedRun)
                    }
                }
            }
        })
        
    }
    
    func updateWeeklyRankingTable(savedRun:Run) {
        let weekNumString = String(component.year!) + String(component.weekOfYear!)
        let weekNum = NSNumber.init(value: Int(weekNumString)!)
        objectMapper.load(WeeklyRanking.classForCoder(), hashKey: weekNum, rangeKey:userID).continue(with: AWSExecutor.default(), with: {(task:AWSTask!) -> Any! in
            DispatchQueue.main.async {
                if (task.error != nil) {
                    self.stopLoadingAnimation()
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to upload to server", comment: ""), message: NSLocalizedString("You can upload the run later in running history", comment: "") + "(Error:\(task.error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        savedRun.synchronized = 0
                        do{ try self.managedObjectContext!.save()} catch _ { print("Could not save run!")}
                        self.performSegue(withIdentifier: "unwindToRvc", sender: self)
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else if (task.result != nil) {
                    let weeklyRanking = task.result as! WeeklyRanking
                    weeklyRanking._distance = NSNumber(value: weeklyRanking._distance!.doubleValue + savedRun.distance!.doubleValue)
                    weeklyRanking._appear = UserDefaults.standard.bool(forKey: "appear") as NSNumber
                    self.objectMapper.save(weeklyRanking)
                    self.updateMonthlyRankingTable(savedRun: savedRun)
                } else if (task.result == nil) {
                    let weeklyRanking = WeeklyRanking()
                    weeklyRanking?._userId = self.userID!
                    weeklyRanking?._week = weekNum
                    weeklyRanking?._distance = savedRun.distance
                    weeklyRanking?._appear = UserDefaults.standard.bool(forKey: "appear") as NSNumber
                    self.objectMapper.save(weeklyRanking!)
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
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to upload to server", comment: ""), message: NSLocalizedString("You can upload the run later in running history", comment: "") + "(Error:\(task.error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        savedRun.synchronized = 0
                        do{ try self.managedObjectContext!.save()} catch _ { print("Could not save run!")}
                        self.performSegue(withIdentifier: "unwindToRvc", sender: self)
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else if (task.result != nil) {
                    let monthlyRanking = task.result as! MonthlyRanking
                    monthlyRanking._distance = NSNumber(value: monthlyRanking._distance!.doubleValue + savedRun.distance!.doubleValue)
                    monthlyRanking._appear = UserDefaults.standard.bool(forKey: "appear") as NSNumber
                    self.objectMapper.save(monthlyRanking)
                    self.updateUserTable(savedRun: savedRun)
                } else if (task.result == nil) {
                    let monthlyRanking = MonthlyRanking()
                    monthlyRanking?._userId = self.userID!
                    monthlyRanking?._month = monthNum
                    monthlyRanking?._distance = savedRun.distance
                    monthlyRanking?._appear = UserDefaults.standard.bool(forKey: "appear") as NSNumber
                    self.objectMapper.save(monthlyRanking!)
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
                    let alertController = UIAlertController(title: NSLocalizedString("Fail to upload to server", comment: ""), message: NSLocalizedString("You can upload the run later in running history", comment: "") + "(Error:\(task.error!.localizedDescription))", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel)  {(action) in
                        savedRun.synchronized = 0
                        do{ try self.managedObjectContext!.save()} catch _ { print("Could not save run!")}
                        self.performSegue(withIdentifier: "unwindToRvc", sender: self)
                    }
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else if (task.result != nil) {
                    self.stopLoadingAnimation()
                    let user = task.result as! User
                    user._totalRunningDistance = NSNumber(value:user._totalRunningDistance!.doubleValue + savedRun.distance!.doubleValue)
                    self.objectMapper.save(user)
                    savedRun.synchronized = 1
                    do{ try self.managedObjectContext!.save()} catch _ { print("Could not save run!")}
                    self.performSegue(withIdentifier: "unwindToRvc", sender: self)
                }
                
            }
        })
    }
    
    
    
    func discardRun() {
        textField!.resignFirstResponder()
        notes.resignFirstResponder()
        let alertController = UIAlertController(title: NSLocalizedString("Discard Run?", comment: ""), message: NSLocalizedString("Are you sure you want to discard this run?", comment: ""), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        let discardAction = UIAlertAction(title:NSLocalizedString("Discard", comment: ""), style: .destructive) {(action) in
            self.performSegue(withIdentifier: "unwindToRvc", sender: self)
        }
        alertController.addAction(discardAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func startLoadingAnimation() {
        activityIndicator.startAnimating()
        activityView.isHidden = false
    }
    
    func stopLoadingAnimation() {
        activityIndicator.stopAnimating()
        activityView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        updateUI()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(persistRun))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image:#imageLiteral(resourceName: "deleteButton"), style:.plain, target: self, action: #selector(discardRun))
    
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: UserDefaults.standard.string(forKey: "AppleLocale")!)
        self.navigationItem.title = dateFormatter.string(from: date!)
        
        
        let keyboardToolBar = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        keyboardToolBar.backgroundColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        notes.delegate = self
        textField = UITextField.init(frame: CGRect(x: 5, y: 0, width: self.view.frame.width-5, height: 40))
        textField!.borderStyle = .roundedRect
        textField!.text = notes.text
        textField?.returnKeyType = .done
        textField?.delegate = self
        keyboardToolBar.addSubview(textField!)
        notes.inputAccessoryView = keyboardToolBar
        NotificationCenter.default.addObserver(self, selector: #selector(changeFirstResponder), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        self.view.addSubview(activityView)
        self.view.addSubview(activityIndicator)
        activityView.center = self.view.center
        activityView.backgroundColor = UIColor(red:0,green:0,blue:0,alpha:0.7)
        activityView.layer.cornerRadius = 10
        activityView.clipsToBounds = true
        activityView.isHidden = true
        activityIndicator.center = self.view.center
    }
    
    func changeFirstResponder() {
        textField?.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        notes.text = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        notesEdited = true
        notes.text = textField.text
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField == notes) {
            if (notesEdited) {
                notes.resignFirstResponder()
                notesEdited = false
                return false
            }
        }
        return true
    }
}
 
