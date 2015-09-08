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
    
    func taskForGet(method: String, params: [String: AnyObject]?, callback: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let urlString = ParseApi.Endpoint + ParseApi.ClassApi + method// + self.escapedParameters(params!)
        
        let URL = NSURL(string: urlString)
        
        let request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.addValue(ParseApi.Headers.AppIdValue, forHTTPHeaderField: ParseApi.Headers.AppIdKey)
        request.addValue(ParseApi.Headers.RestApiValue, forHTTPHeaderField: ParseApi.Headers.RestApiKey)
        
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
    
    func taskforPOST(method: String, serviceEndpoint: String, headers: NSMutableDictionary, jsonBody: [String: AnyObject], callback: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlString = serviceEndpoint + method
        
        let url = NSURL(string: urlString)
        
        // Request
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        // Add headers
        headers["application/json"] = "Accept"
        headers["application/json"] = "Content-Type"
        
        for (headerValue, headerField) in headers {
            request.addValue(headerValue as? String, forHTTPHeaderField: (headerField as? String)! )
        }

        request.HTTPBody = self.parseJSONBody(jsonBody)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                callback(result: nil, error: error)
            } else {
                self.parseResponseData(data, postProcessor: self.trimResponse, callback: callback)
            }
        }
        task.resume();
        return task;
    }
    

}
