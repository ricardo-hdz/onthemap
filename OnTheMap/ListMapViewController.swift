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
    
    var studentLocations: [StudentLocation] = [StudentLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        setNavigationBarItems()
    }
    
    /**
        Sets the navigation bar buttons
    **/
    func setNavigationBarItems() {
        // Logout Button
        var logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutAction")
        self.navigationItem.leftBarButtonItem = logoutButton
        
        // Refresh Button
        var refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshAction")
        // Pin Button
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        iconView.contentMode = UIViewContentMode.ScaleAspectFit
        let pinIcon = UIImage(named: "pin")
        iconView.image = pinIcon

        var pinButton2 = UIBarButtonItem(customView: iconView)
        pinButton2.action = "pinAction"
        pinButton2.target = self
        self.navigationItem.rightBarButtonItems = [pinButton2, refreshButton]
        
        self.tabBarController?.tabBar.hidden = false
    }
    
    func getStudentLocations(callback: () -> Void) {
        if (self.studentLocations.count == 0) {
            var endpoint = OnTheMapHelper.ParseApi.Endpoint + OnTheMapHelper.ParseApi.ClassApi
            
            var headers: NSMutableDictionary = [
                OnTheMapHelper.ParseApi.Headers.AppIdKey: OnTheMapHelper.ParseApi.Headers.AppIdValue,
                OnTheMapHelper.ParseApi.Headers.RestApiKey: OnTheMapHelper.ParseApi.Headers.RestApiValue
            ]
            
            let task = OnTheMapHelper.getInstance().taskForGet(OnTheMapHelper.ParseApi.Methods.studentlocation, serviceEndpoint: endpoint, headers: headers,  params: nil) { result, error in
                if let error = error {
                    self.handleError(error.localizedDescription)
                } else {
                    // get data
                    if let locations = result.valueForKey("results") as? [[String: AnyObject]] {
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
                            self.studentLocations.append(studentLocation)
                        }
                        println("Completed GET")
                        dispatch_async(dispatch_get_main_queue(), {
                            callback()
                        })
                    } else {
                        self.handleError("Error while converting results to Dictionary")
                    }
                }
            }
        }
    }
    
    func handleError(error: String) {
        dispatch_async(dispatch_get_main_queue(), {
            println("Error while retrieving studnet locations: \(error)")
        })
    }
}