//
//  OnTheMapConstants.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/1/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

import Foundation

extension OnTheMapHelper {

    struct Authentication {
        static let facebookAppId: String = "365362206864879"
    }
    
    struct API {
        static let udacityEndpoint: String = "https://www.udacity.com/api/"
        struct Methods {
            static let session: String = "session"
            static let users: String = "users/{id}"
        }
        struct Parameters {
            static let username: String = "username"
            static let password: String = "password"
        }
        struct Cookies {
            static let auth_token: String = "XSRF-TOKEN"
        }
    }
    
    struct Response {
        static let key: String = "key"
        
        struct Session {
            static let id: String = "id"
            static let expiration: String = "expiration"
        }
    }
}