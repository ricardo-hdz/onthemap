//
//  LocationHelper.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/17/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

import MapKit

class LocationHelper {

    class func postLocation(location: [String: AnyObject], callback: (result: Bool, error: String?) -> Void ) {
        //post
        let serviceEndpoint = OnTheMapHelper.ParseApi.Endpoint + OnTheMapHelper.ParseApi.ClassApi + OnTheMapHelper.ParseApi.Methods.studentlocation
        
        var headers : NSMutableDictionary = [
            OnTheMapHelper.ParseApi.Headers.AppIdKey: OnTheMapHelper.ParseApi.Headers.AppIdValue,
            OnTheMapHelper.ParseApi.Headers.RestApiKey: OnTheMapHelper.ParseApi.Headers.RestApiValue
        ]
        
        let task = OnTheMapHelper.getInstance().serviceRequest("POST", serviceEndpoint: serviceEndpoint, headers: headers, jsonBody: location, postProcessor: nil) { result, error in
            if let error = error {
                callback(result: false, error: "Location was not updated. Please try again.")
            } else {
                if let createdAt = result.valueForKey("createdAt") as? String {
                    callback(result: true, error: nil)
                } else {
                    callback(result: false, error: "Location was not updated. Please try again.")
                }
            }
        }
    }
    
    class func searchMapRequest(location: String, callback: (annotationView: MKAnnotationView?, region: MKCoordinateRegion?, error: String?) -> Void ) {
        var searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = location
        var search = MKLocalSearch(request: searchRequest)
        
        search.startWithCompletionHandler() { response, error in
            if let error = error {
                callback(annotationView: nil, region: nil, error: "Unable to locate it. Please try again.")
            } else {
                if (response == nil) {
                    callback(annotationView: nil, region: nil, error: "Location not found. Please try again.")
                } else {
                    // display location in map
                    var annotationPoint = MKPointAnnotation()
                    annotationPoint.title = location
                    
                    var locationCoord = CLLocationCoordinate2D(latitude: response.boundingRegion.center.latitude, longitude: response.boundingRegion.center.longitude)
                    annotationPoint.coordinate = locationCoord
                    
                    var annotationView = MKAnnotationView(annotation: annotationPoint, reuseIdentifier: nil)
                    
                    // Set Region
                    var mapSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                    var mapRegion = MKCoordinateRegion(center: locationCoord, span: mapSpan)
                    
                    callback(annotationView: annotationView, region: mapRegion, error: nil)
                }
            }
        }
    }
}