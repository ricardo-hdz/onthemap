//
//  DataStore.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/16/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

class DataStore : NSObject {
    var studentLocations = [StudentLocation]()
    
    /* Singleton */
    class func getInstance() -> DataStore {
        struct Singleton {
            static var instance = DataStore()
        }
        return Singleton.instance
    }
    
    func getSortedLocations() -> [StudentLocation] {
        self.studentLocations.sort{ $0.updatedAt > $1.updatedAt }
        return self.studentLocations
    }
}