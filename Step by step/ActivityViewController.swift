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
    
    var run:Run?
    
    func updateUI() {
        let displayTime = secondsToHoursMinutesSeconds(seconds: run!.time!.intValue)
        let displayDistance = String(format:"%.2f", Double(round(run!.distance!.doubleValue*100)/100))
        let displayPace = secondsToHoursMinutesSeconds(seconds: run!.pace!.intValue)
        let displayEnergy = run!.energy!.intValue
        
        timeLabel.text = displayTime
        distanceLabel.text = displayDistance
        averagePaceLabel.text = displayPace
        energyLabel.text = "\(displayEnergy)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        
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
        
        if (run!.address != nil && run!.city != nil) {
            locationLabel.text = run!.address! + ", " + run!.city!
        }
        
        let notes = run!.notes
        if (notes==""){
            notesLabel.text = "There are no notes"
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
        if run!.locations!.count > 0 {
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
    
    func deleteRun() {
        
        let alertController = UIAlertController(title: nil, message: "Delete this run?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {(action) in}
        
        alertController.addAction(cancelAction)
        
        let changeAction = UIAlertAction(title: "Delete", style:.destructive) { (action) in
            self.managedObjectContext?.delete(self.run!)
            do{ try self.managedObjectContext?.save()} catch _ { print("Could not save!")}
            _=self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(changeAction)
        
        self.navigationController?.present(alertController, animated: true,completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, YYYY"
        self.navigationItem.title = dateFormatter.string(from: run!.date!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        updateUI()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image:#imageLiteral(resourceName: "deleteButton"), style:.plain, target: self, action: #selector(deleteRun))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
}
