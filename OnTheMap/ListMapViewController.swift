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
        var locations = self.getSortedLocations()
        if (locations.count == 0 || forceRefresh) {
            StudentLocationHelper.requestStudentLocations() { studentLocations, error in
                if let error = error {
                    self.handleError("On the Map - Error", error: error)
                } else {
                    self.setStoredLocations(studentLocations!)
                    var sortedLocations = self.getSortedLocations()
                    dispatch_async(dispatch_get_main_queue(), {
                        callback(locations: sortedLocations)
                    })
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
    
    func getSortedLocations() -> [StudentLocation] {
        return DataStore.getInstance().getSortedLocations()
    }
    
    func handleError(alertTitle: String, error: String) {
        let alertController = UIAlertController(title: alertTitle, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
}