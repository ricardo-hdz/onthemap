//
//  UdacityProfile.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/2/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

import Foundation

class UdacityProfile: NSObject {
    var sessionId: String = ""
    var userId: String = ""
    
    init(sessionId: String, userId: String) {
        self.sessionId = sessionId
        self.userId = userId
    }

}