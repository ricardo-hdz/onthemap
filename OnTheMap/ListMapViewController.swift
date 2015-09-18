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
    
    let networkClient = Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationBarItems()
        self.getStudentLocations(false, callback: self.displayStudentLocations)
    }
    
    func displayStudentLocations(locations: [StudentLocation]) {
        // Function must be overriden
    }
    
    /**
        Sets the navigation bar buttons
    **/
    func setNavigationBarItems() {
        // FB log out Button
        
        var logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutAction")
        self.navigationItem.leftBarButtonItem = logoutButton
        
        // Refresh Button
        var refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshAction")
        
        // Pin Button
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        let pinIcon = UIImage(named: "pinIcon")

        var pinButton = UIBarButtonItem(image: pinIcon, style: UIBarButtonItemStyle.Plain, target: self, action: "postAction")
        
        self.navigationItem.rightBarButtonItems = [refreshButton, pinButton]
        
        self.tabBarController?.tabBar.hidden = false
    }
    
    func refreshAction() {
        self.getStudentLocations(true, callback: self.displayStudentLocations)
    }
    
    func logoutAction() {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            var fbLoginManager = FBSDKLoginManager()
            fbLoginManager.logOut()
            self.displayLogin()
        } else {
            LoginHelper.deleteSession { result, error in
                if let error = error {
                    self.handleError("On the Map - Logout", error: error)
                } else {
                    self.displayLogin()
                }
            }
        }
    }
    
    func displayLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("loginController") as! LoginViewController
            self.presentViewController(controller, animated: true, completion: nil)
        })
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
                    self.handleError("On the Map - Error", error: error.localizedDescription)
                } else {
                    if let locations = result.valueForKey("results") as? [[String: AnyObject]] {
                        var studentLocations: [StudentLocation] = [StudentLocation]()
                        for location in locations {
                            var studentLocation = StudentLocation(data: location)
                            studentLocations.append(studentLocation)
                        }
                        self.setStoredLocations(studentLocations)
                        dispatch_async(dispatch_get_main_queue(), {
                            callback(locations: studentLocations)
                        })
                    } else {
                        self.handleError("On the Map - Error", error:"Error while converting results to Dictionary")
                    }
                }
            }
        } else {
            callback(locations: locations)
        }
    }
    
    func setStoredLocations(locations: [StudentLocation]) {
        DataStore.getInstance().studentLocations = locations
    }
    
    func getStoredLocations() -> [StudentLocation] {
        return DataStore.getInstance().studentLocations
    }
    
    func handleError(alertTitle: String, error: String) {
        let alertController = UIAlertController(title: alertTitle, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
}