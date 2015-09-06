//
//  MenuTabController.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/5/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//  NOT USED DELETE
//
//

import Foundation
import UIKit

class MenuTabController: UITabBarController {

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        setNavigationBarItems()
    }
    
    /**
    Sets the navigation bar buttons
    **/
    func setNavigationBarItems() {
        var logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutAction")
        self.navigationItem.leftBarButtonItem = logoutButton
        
        var refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshAction")
        let pinImage = UIImage(named: "pin")
        var pinButton = UIBarButtonItem(image: pinImage!, style: UIBarButtonItemStyle.Plain, target: self, action: "pinAction")
        self.navigationItem.rightBarButtonItems = [pinButton, refreshButton]
        
        self.tabBarController?.tabBar.hidden = false
    }
}