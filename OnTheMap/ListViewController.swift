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
        self.getStudentLocations() {
            self.locationList.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("Displaying \(self.studentLocations.count) in list view")
        return self.studentLocations.count
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // implement
        let location = self.studentLocations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCell") as! ListMapViewCell
        cell.locationTitle.text = "\(location.firstName) \(location.lastName)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // implement
    }
    
}