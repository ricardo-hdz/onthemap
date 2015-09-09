//
//  UdacityProfile.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/2/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

import Foundation

class UdacityProfile: NSObject {
    //var sessionId: String?
    var userId: String?
    var firstName: String?
    var lastName: String?
    
    init(userId: String, firstName: String, lastName: String) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
    }

}