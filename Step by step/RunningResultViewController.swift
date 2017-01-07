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
    var pace = "00:00"
    var energy = 0
    var date:Date?
    var locations:NSOrderedSet?
    var pauseLocations:NSOrderedSet?
    var city:String?
    var country:String?
    var address:String?
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = seconds / 60 % 60
        let seconds = seconds % 60
        if hours>10 {
            return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        } else if hours>0 {
            return String(format:"%01i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format:"%02i:%02i",minutes, seconds)
        }
    }
    
    func updateUI() {
        let displayTime = secondsToHoursMinutesSeconds(seconds: seconds)
        let displayDistance = String(format:"%.2f", Double(round(distance*100)/100))
        let displayPace = pace
        let displayEnergy = energy
        
        timeLabel.text = displayTime
        distanceLabel.text = displayDistance
        averagePaceLabel.text = displayPace
        energyLabel.text = "\(displayEnergy)"

        
        if address != nil && city != nil {
            locationLabel.text = address! + ", " + city!
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
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
        if self.locations!.count > 0 {
            mapView.isHidden = false
            mapView.region = mapRegion()
            mapView.add(polyline())
        }
        else {
            mapView.isHidden = true
            
            UIAlertView(title: "Error",
                message: "Sorry, this run has no locations saved",
                delegate:nil,
                cancelButtonTitle: "OK").show()
        }
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
        let savedRun = NSEntityDescription.insertNewObject(forEntityName: "Run", into:managedObjectContext!) as! Run
        savedRun.distance = distance as NSNumber?
        savedRun.time = seconds as NSNumber?
        savedRun.energy = energy as NSNumber?
        savedRun.locations = locations
        savedRun.pausedLocations = pauseLocations
        savedRun.pace = pace
        savedRun.weather = weather
        print(notes.text!)
        savedRun.notes = notes.text
        savedRun.date = date
        savedRun.address = address
        savedRun.city = city
        savedRun.country = country
        print("Saving")
        do{ try managedObjectContext!.save()} catch _ { print("Could not save run!")}
        performSegue(withIdentifier: "unwindToRvc", sender: self)
    }
    
    func discardRun() {
        let alertController = UIAlertController(title: "Discard Run?", message: "Are you sure you want to discard this run?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        let discardAction = UIAlertAction(title:"Discard", style: .default) {(action) in
            self.performSegue(withIdentifier: "unwindToRvc", sender: self)
        }
        alertController.addAction(discardAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        updateUI()
        self.navigationController?.isNavigationBarHidden = false

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(persistRun))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image:#imageLiteral(resourceName: "deleteButton"), style:.plain, target: self, action: #selector(discardRun))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, YYYY"
        self.navigationItem.title = dateFormatter.string(from: date!)
        
        
        let keyboardToolBar = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        keyboardToolBar.backgroundColor = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
        notes.delegate = self
        textField = UITextField.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        textField!.borderStyle = .roundedRect
        textField!.placeholder = "Input some notes"
        textField!.text = notes.text
        textField?.returnKeyType = .done
        textField?.delegate = self
        keyboardToolBar.addSubview(textField!)
        notes.inputAccessoryView = keyboardToolBar
        NotificationCenter.default.addObserver(self, selector: #selector(changeFirstResponder), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    func changeFirstResponder() {
        textField?.becomeFirstResponder()
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
