//
//  LoginHelper.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/17/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

import Foundation

class LoginHelper {
    
    // Requests a session with the given credentials
    class func createSession(credentials: [String: AnyObject], callback: (userId: String?, sessionId: String?, error: String?) -> Void) {
        
        let serviceEndpoint = OnTheMapHelper.API.udacityEndpoint + OnTheMapHelper.API.udacityApi + OnTheMapHelper.API.Methods.session
        
        let headers: NSMutableDictionary = [:]
        
        var task = OnTheMapHelper.getInstance().serviceRequest("POST", serviceEndpoint: serviceEndpoint, headers: headers, jsonBody: credentials, postProcessor: OnTheMapHelper.getInstance().trimResponse) { result, error in
            if let error = error {
                callback(userId: nil, sessionId: nil, error: error.localizedDescription)
            } else {
                let account = result.valueForKey(OnTheMapHelper.Response.Session.account) as? NSDictionary
                let session = result.valueForKey(OnTheMapHelper.Response.Session.session) as? NSDictionary
                if (account != nil && session != nil) {
                    let userId = account?.valueForKey(OnTheMapHelper.Response.Session.accountKey) as? String
                    let sessionId = session?.valueForKey(OnTheMapHelper.Response.Session.sessionId) as? String
                    callback(userId: userId, sessionId: sessionId, error: nil)
                } else {
                    if let svcError = result.valueForKey("error") as? String {
                        callback(userId: nil, sessionId: nil, error: svcError)
                    }
                }
            }
        }
    }
    
    class func deleteSession(callback: (result: Bool, error: String?) -> Void) {
        let serviceEndpoint = OnTheMapHelper.API.udacityEndpoint + OnTheMapHelper.API.udacityApi + OnTheMapHelper.API.Methods.session
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        let headers: NSMutableDictionary = [
            OnTheMapHelper.API.Cookies.auth_token: xsrfCookie!.value!
        ]
        
        var task = OnTheMapHelper.getInstance().serviceRequest("DELETE", serviceEndpoint: serviceEndpoint, headers: headers, jsonBody: nil, postProcessor: OnTheMapHelper.getInstance().trimResponse) { result, error in
            if let error = error {
                callback(result: false, error: error.localizedDescription)
            } else {
                let session = result.valueForKey("session") as? NSDictionary
                let expiration: AnyObject? = session?.valueForKey("expiration")
                if (expiration != nil) {
                    callback(result: true, error: nil)
                } else {
                    callback(result: false, error: "Unable to log out. Please try again")
                }
            }
        }
    }
    
    class func getUdacityProfile(userId: String, callback: (profile: UdacityProfile?, error: String?) -> Void) {
        var method = OnTheMapHelper.getInstance().replaceParamsInUrl(OnTheMapHelper.API.Methods.users, paramId: "userId", paramValue: userId)
        var endpoint = OnTheMapHelper.API.udacityEndpoint + OnTheMapHelper.API.udacityApi + method!
        
        let headers: NSMutableDictionary = [:]
        
        var task = OnTheMapHelper.getInstance().serviceRequest("GET", serviceEndpoint: endpoint, headers: headers, jsonBody: nil, postProcessor: OnTheMapHelper.getInstance().trimResponse) { result, error in
            if let error = error {
                callback(profile: nil, error: error.localizedDescription)
            } else {
                if let user = result.valueForKey("user") as? NSDictionary {
                    let firstName = user.valueForKey("first_name") as? String
                    let lastName = user.valueForKey("last_name") as? String
                    // create profile
                    var profile = UdacityProfile(userId: userId, firstName: firstName!, lastName: lastName!)
                    // store it
                    callback(profile: profile, error: nil)
                    //self.setSessionProfile(profile)
                    // segue to map view
                    //self.displayMapView()
                }
            }
        }
    }
    
}