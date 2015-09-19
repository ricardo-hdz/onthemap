//
//  StudnetLocationHelper.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/19/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

class StudentLocationHelper {
    
    class func requestStudentLocations(callback: (studentLocations: [StudentLocation]?, error: String?) -> Void) {
        var endpoint = OnTheMapHelper.ParseApi.Endpoint + OnTheMapHelper.ParseApi.ClassApi + OnTheMapHelper.ParseApi.Methods.studentlocation
        
        var headers: NSMutableDictionary = [
            OnTheMapHelper.ParseApi.Headers.AppIdKey: OnTheMapHelper.ParseApi.Headers.AppIdValue,
            OnTheMapHelper.ParseApi.Headers.RestApiKey: OnTheMapHelper.ParseApi.Headers.RestApiValue
        ]
        
        let task = OnTheMapHelper.getInstance().serviceRequest("GET", serviceEndpoint: endpoint, headers: headers, jsonBody: nil, postProcessor: nil) { result, error in
            if let error = error {
                callback(studentLocations: nil, error:error.localizedDescription)
            } else {
                if let locations = result.valueForKey("results") as? [[String: AnyObject]] {
                    var studentLocations: [StudentLocation] = [StudentLocation]()
                    for location in locations {
                        var studentLocation = StudentLocation(data: location)
                        studentLocations.append(studentLocation)
                    }
                    callback(studentLocations: studentLocations, error: nil)
                } else {
                    callback(studentLocations: nil, error: "Error while translating locations from bits to pins")
                }
            }
        }
    }
    
}