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
    
    func taskForGet(method: String, serviceEndpoint: String, headers: NSMutableDictionary, params: [String: AnyObject]?, callback: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let urlString = serviceEndpoint + method
        
        let URL = NSURL(string: urlString)
        
        var request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = "GET"
        request = self.setRequestHeaders(request, headers: headers)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                callback(result: nil, error: error)
            } else {
                self.parseResponseData(data, postProcessor: nil, callback: callback)
            }
        }
        
        task.resume()
        return task
    }
    
    func taskforPOST(method: String, serviceEndpoint: String, headers: NSMutableDictionary, jsonBody: [String: AnyObject], postProcessor: ((data: AnyObject) -> NSData)?, callback: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlString = serviceEndpoint + method
        
        let url = NSURL(string: urlString)
        
        // Request
        var request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request = self.setRequestHeaders(request, headers: headers)

        request.HTTPBody = self.parseJSONBody(jsonBody)
        
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
    
    func setRequestHeaders(request: NSMutableURLRequest, headers: NSMutableDictionary) -> NSMutableURLRequest {
        headers["application/json"] = "Accept"
        headers["application/json"] = "Content-Type"
        
        for (headerField, headerValue) in headers {
            request.addValue(headerValue as? String, forHTTPHeaderField: (headerField as? String)! )
        }
        
        return request
    }
}
