//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/1/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: ListMapViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func displayStudentLocations(locations: [StudentLocation]) {
        // reset annotations (if any)
        var currentAnnotations = map.annotations
        map.removeAnnotations(currentAnnotations)
        
        var mapLocations : [MKPointAnnotation] = [MKPointAnnotation]()
        
        for location in locations {
            let lat = CLLocationDegrees(location.latitude)
            let lon = CLLocationDegrees(location.longitude)
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = coord
            annotation.title = "\(location.firstName) \(location.lastName)"
            annotation.subtitle = location.mediaURL
            
            mapLocations.append(annotation)
        }
        
        self.map.addAnnotations(mapLocations)
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let pinIdentifier = "pin"
        var pinView = self.map.dequeueReusableAnnotationViewWithIdentifier(pinIdentifier)
        
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