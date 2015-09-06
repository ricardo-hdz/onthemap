//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/1/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: ListMapViewController, UINavigationControllerDelegate, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var locations : [MKPointAnnotation] = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getStudentLocations(self.displayStudentLocations)
    }
    
    func displayStudentLocations() {
        println("Trying to map \(self.studentLocations.count) locations")
        for location in self.studentLocations {
            let lat = CLLocationDegrees(location.latitude)
            let lon = CLLocationDegrees(location.longitude)
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = coord
            annotation.title = "\(location.firstName) \(location.lastName)"
            annotation.subtitle = location.mediaURL
            
            locations.append(annotation)
        }
        
        map.addAnnotations(locations)
    }
    
    func refreshAction() {
        self.studentLocations = [StudentLocation]() // reset locations
        self.getStudentLocations(self.displayStudentLocations)
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let pinIdentifier = "pin"
    
        var pinView = map.dequeueReusableAnnotationViewWithIdentifier(pinIdentifier) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
}