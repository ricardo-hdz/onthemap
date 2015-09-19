//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/4/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

import UIKit

class ListViewController : ListMapViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var locationList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func displayStudentLocations(locations: [StudentLocation]) {
        self.locationList.reloadData()
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var locations = self.getStoredLocations()
        return locations.count
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let location = self.getSortedLocations()[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCell") as! ListMapViewCell
        cell.locationTitle.text = "\(location.firstName) \(location.lastName)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = self.getSortedLocations()[indexPath.row]
        if (Reachability.isConnectedToNetwork()) {
            if (!location.mediaURL.isEmpty) {
                let url = NSURL(string: location.mediaURL)
                if (url != nil && url?.scheme != nil && url?.host != nil) {
                    let app = UIApplication.sharedApplication()
                    app.openURL(url!)
                } else {
                    handleError("On the Map", error: "There is no media URL associated with this location.")
                }
            } else {
                handleError("On the Map", error: "There is no media URL associated with this location.")
            }
        } else {
            handleError("On the Map - Network Error", error: "No network connection detected.")
        }
    }
}