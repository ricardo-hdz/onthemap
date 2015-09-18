//
//  LocationHelper.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/17/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

import MapKit
import CoreLocation

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
    
    class func searchGeocodeByString(location: String, callback: (placemark: CLPlacemark?, error: String?) -> Void) {
        CLGeocoder().geocodeAddressString(location) { placemarks, error in
            if let error = error {
                callback(placemark: nil, error: error.localizedDescription)
            } else {
                if let placemarks = placemarks as? [CLPlacemark] {
                    if placemarks[0].location != nil {
                        callback(placemark: placemarks[0], error: nil)
                    } else {
                        callback(placemark: nil, error: "No location found for \(location)")
                    }
                } else {
                    callback(placemark: nil, error: "Unable to geocode this location.")
                }
            }
        }
    }
}