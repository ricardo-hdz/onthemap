//
//  OnTheMapHelper.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/1/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

import Foundation

class OnTheMapHelper: NSObject {
    
    var session: NSURLSession

    override init() {
        self.session = NSURLSession.sharedSession()
        super.init()
    }
    
    /* Singleton */
    class func getInstance() -> OnTheMapHelper {
        struct Singleton {
            static var instance = OnTheMapHelper()
        }
        return Singleton.instance
    }
    
    func serviceRequest(type: String, serviceEndpoint: String, headers: NSMutableDictionary, jsonBody: [String: AnyObject]?, postProcessor: ((data: AnyObject) -> NSData)?, callback: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let url = NSURL(string: serviceEndpoint)
        
        // Request
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = type
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        for (headerField, headerValue) in headers {
            request.addValue(headerValue as? String, forHTTPHeaderField: (headerField as? String)! )
        }
        
        if (jsonBody != nil) {
            request.HTTPBody = self.parseJSONBody(jsonBody!)
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                callback(result: nil, error: error)
            } else {
                self.parseResponseData(data, postProcessor: postProcessor, callback: callback)
            }
        }
        task.resume();
        return task;
    }
}
