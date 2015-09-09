//
//  OnTheMapUtilities.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/2/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

import Foundation

extension OnTheMapHelper {

    /*
    * Post-process responses from Udacity API to skip the
    * first five chars of the response
    */
    func trimResponse(data: AnyObject) -> NSData {
        let processedData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        return processedData
    }
    
    func replaceParamsInUrl(url: String, paramId: String, paramValue:String) -> String? {
        if url.rangeOfString("{\(paramId)}") != nil {
            return url.stringByReplacingOccurrencesOfString("{\(paramId)}", withString: paramValue)
        } else {
            return nil
        }
    }
    
    func parseJSONBody(body: [String: AnyObject]) -> NSData? {
        var parseError: NSError? = nil
        return NSJSONSerialization.dataWithJSONObject(body
            , options: nil, error: &parseError)
    }
    
    func parseResponseData(data: NSData, postProcessor: ((data: AnyObject) -> NSData)?, callback: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parseError: NSError? = nil
        var postProcessedResponse: NSData = data
        
        if ((postProcessor) != nil) {
            postProcessedResponse = postProcessor!(data: data)
        }
        
        //println(NSString(data: data, encoding: NSUTF8StringEncoding))
        println("Parsed data:")
        println(NSString(data: postProcessedResponse, encoding: NSUTF8StringEncoding))

        let parsedData: AnyObject? = NSJSONSerialization.JSONObjectWithData(postProcessedResponse, options: .AllowFragments, error: &parseError)
        
        if let error = parseError {
            println("Parse error")
            callback(result: nil, error: parseError)
        } else {
            println("Sucessfully parsed JSON data")
            callback(result: parsedData, error: nil)
        }
    }
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        //if (parameters != nil) {
            for (key, value) in parameters {
                let stringValue = "\(value)"
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                urlVars += [key + "=" + "\(escapedValue!)"]
            }
        //}
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }

}