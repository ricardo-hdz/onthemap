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
    
    func taskForGet() {
    }
    
    func taskforPOST(method: String, params: [String: AnyObject], jsonBody: [String: AnyObject], callback: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlString = API.udacityEndpoint + method + self.escapedParameters(params)
        
        let url = NSURL(string: urlString)
        
        // Request
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = self.parseJSONBody(jsonBody)

        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                callback(result: nil, error: error)
            } else {
                // parse data
                self.parseResponseData(data, callback: callback)
            }
        }
        task.resume();
        return task;
    }
    

}
