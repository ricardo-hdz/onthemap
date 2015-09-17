//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/6/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

struct StudentLocation {
    var createdAt: String
    var firstName: String
    var lastName: String
    var latitude: Double
    var longitude: Double
    var mapString: String
    var mediaURL: String
    var objectId: String
    var uniqueKey: String
    var updatedAt: String
    
    init(data: NSDictionary) {
        self.createdAt = data.valueForKey("createdAt") as! String
        self.createdAt = data.valueForKey("createdAt") as! String
        self.firstName = data.valueForKey("firstName") as! String
        self.lastName = data.valueForKey("lastName") as! String
        self.latitude = data.valueForKey("latitude") as! Double
        self.longitude = data.valueForKey("longitude") as! Double
        self.mapString = data.valueForKey("mapString") as! String
        self.mediaURL = data.valueForKey("mediaURL") as! String
        self.objectId = data.valueForKey("objectId") as! String
        self.uniqueKey = data.valueForKey("uniqueKey") as! String
        self.updatedAt = data.valueForKey("updatedAt") as! String
    }
}