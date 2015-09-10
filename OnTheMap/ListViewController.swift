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
        println("Displaying \(locations.count) in list view")
        return locations.count
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let location = self.getStoredLocations()[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCell") as! ListMapViewCell
        cell.locationTitle.text = "\(location.firstName) \(location.lastName)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = self.getStoredLocations()[indexPath.row]
        let url = NSURL(string: location.mediaURL)
        let app = UIApplication.sharedApplication()
        app.openURL(url!)
    }
    
}