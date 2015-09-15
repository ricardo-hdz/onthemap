//
//  ListMapViewController.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/5/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

import UIKit
import MapKit


class ListMapViewController: UIViewController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getStudentLocations(false, callback: self.displayStudentLocations)
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationBarItems()
    }
    
    func displayStudentLocations(locations: [StudentLocation]) {
        // Function must be overriden
    }
    
    /**
        Sets the navigation bar buttons
    **/
    func setNavigationBarItems() {
        // FB log out Button
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            var logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "fbLogoutAction")
            self.navigationItem.leftBarButtonItem = logoutButton
        }
        
        // Refresh Button
        var refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshAction")
        
        // Pin Button
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let pinIcon = UIImage(named: "pin")
        
        var pinButton = UIBarButtonItem(image: pinIcon, style: UIBarButtonItemStyle.Plain, target: self, action: "postAction")
        
        self.navigationItem.rightBarButtonItems = [pinButton, refreshButton]
        
        self.tabBarController?.tabBar.hidden = false
    }
    
    func refreshAction() {
        self.getStudentLocations(true, callback: self.displayStudentLocations)
    }
    
    func fbLogoutAction() {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            var fbLoginManager = FBSDKLoginManager()
            fbLoginManager.logOut()
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    func postAction() {
        let postLocationController = self.storyboard?.instantiateViewControllerWithIdentifier("postLocationViewController") as! PostLocationViewController
        let nav = UINavigationController(rootViewController: postLocationController)
        self.showDetailViewController(nav, sender: self)
    }
    
    func getStudentLocations(forceRefresh: Bool, callback: (locations: [StudentLocation]) -> Void) {
        var locations = self.getStoredLocations()
        if (locations.count == 0 || forceRefresh) {
            var endpoint = OnTheMapHelper.ParseApi.Endpoint + OnTheMapHelper.ParseApi.ClassApi + OnTheMapHelper.ParseApi.Methods.studentlocation
            
            var headers: NSMutableDictionary = [
                OnTheMapHelper.ParseApi.Headers.AppIdKey: OnTheMapHelper.ParseApi.Headers.AppIdValue,
                OnTheMapHelper.ParseApi.Headers.RestApiKey: OnTheMapHelper.ParseApi.Headers.RestApiValue
            ]
            
            let task = OnTheMapHelper.getInstance().serviceRequest("GET", serviceEndpoint: endpoint, headers: headers, jsonBody: nil, postProcessor: nil) { result, error in
                if let error = error {
                    self.handleError(error.localizedDescription)
                } else {
                    // get data
                    if let locations = result.valueForKey("results") as? [[String: AnyObject]] {
                        var studentLocations: [StudentLocation] = [StudentLocation]()
                        for location in locations {
                            var studentLocation = StudentLocation(
                                createdAt: location["createdAt"] as! String,
                                firstName: location["firstName"] as! String,
                                lastName: location["lastName"] as! String,
                                latitude: location["latitude"] as! Double,
                                longitude: location["longitude"] as! Double,
                                mapString: location["mapString"] as! String,
                                mediaURL: location["mediaURL"] as! String,
                                objectId: location["objectId"] as! String,
                                uniqueKey: location["uniqueKey"] as! String,
                                updatedAt: location["updatedAt"]  as! String
                            )
                            studentLocations.append(studentLocation)
                        }
                        self.setStoredLocations(studentLocations)
                        dispatch_async(dispatch_get_main_queue(), {
                            callback(locations: studentLocations)
                        })
                    } else {
                        self.handleError("Error while converting results to Dictionary")
                    }
                }
            }
        } else {
            callback(locations: locations)
        }
    }
    
    func setStoredLocations(locations: [StudentLocation]) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.studentLocations = locations
    }
    
    func getStoredLocations() -> [StudentLocation] {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.studentLocations
    }
    
    func handleError(error: String) {
        dispatch_async(dispatch_get_main_queue(), {
            println("Error while retrieving studnet locations: \(error)")
        })
    }
}