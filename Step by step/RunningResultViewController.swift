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

class RunningResultViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var run:Run?
    
    
    func updateUI() {
        let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: run!.duration!.doubleValue)
        timeLabel.text = secondsQuantity.description
        let displayDistance = Double(round(run!.distance!.doubleValue*100)/100)
        distanceLabel.text = "\(displayDistance) km"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateLabel.text = dateFormatter.string(from: run!.timestamp! as Date)
        loadMap()
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
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1,
                longitudeDelta: (maxLng - minLng)*1.1))
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        updateUI()
        
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? RunningViewController {
            destination.locationManager.delegate = destination
        }
    }
    
}
