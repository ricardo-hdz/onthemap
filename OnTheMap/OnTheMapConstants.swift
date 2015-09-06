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
        static let udacityEndpoint: String = "https://www.udacity.com"
        static let udacityApi: String = "/api/"
        
        struct Methods {
            static let session: String = "session"
            static let users: String = "users/{id}"
            static let studentlocation: String = "StudentLocation"
            static let updateStudentlocationUpdate: String = Methods.studentlocation + "/{objectId}"
        }
        
        struct Parameters {
            static let username: String = "username"
            static let password: String = "password"
        }
        
        struct Cookies {
            static let auth_token: String = "XSRF-TOKEN"
        }
    }
    
    struct ParseApi {
        
        static let Endpoint: String = "https://api.parse.com"
        static let ClassApi: String = "/1/classes/"
        
        struct Headers {
            static let AppIdKey: String = "X-Parse-Application-Id"
            static let RestApiKey: String = "X-Parse-REST-API-Key"
            
            static let AppIdValue: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
            static let RestApiValue: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        }
        
        struct Methods {
            static let studentlocation: String = "StudentLocation"
            static let updateStudentlocationUpdate: String = Methods.studentlocation + "/{objectId}"
        }
        
        struct Parameters {
            static let limit:String = "limit"
            static let skip: String = "slip"
            static let order: String = "order"
            static let keyId: String = "keyId"
            static let whereQuery: String = "?where={\"uniqueKey\": \"{keyId}\")}"
        }
    
    }
    
    struct Response {
        
        struct Account {
            static let key: String = "key"
        }
        
        struct Session {
            static let id: String = "id"
            static let expiration: String = "expiration"
        }
    }
}