//
//  PostLocationViewController.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/6/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

import MapKit
import UIKit

class PostLocationViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var locationMap: MKMapView!
    
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var aboutTextfield: CustomTextfield!
    @IBOutlet weak var locationTextfield: CustomTextfield!
    
    @IBOutlet weak var mapItButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    var search: MKLocalSearch!
    var searchRequest: MKLocalSearchRequest!
    var searchResponse: MKLocalSearchResponse!
    
    var annotation: MKAnnotation!
    var annotationPoint: MKPointAnnotation!
    var annotationView: MKAnnotationView!
    var mapSpan: MKCoordinateSpan!
    var mapRegion: MKCoordinateRegion!
    
    var keyboardHeight: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextfield.delegate = self
        aboutTextfield.delegate = self
        self.subscribeToKeyboardNotifications()
    }

    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.mapItButton.layer.cornerRadius = 5
        
        self.whereLabel.hidden = false
        self.locationTextfield.hidden = false
        self.mapItButton.hidden = false
        self.submitButton.hidden = true
        self.errorLabel.hidden = true
        self.locationMap.hidden = true
        self.aboutTextfield.hidden = true
        
        /*self.upperView.backgroundColor = UIColor(red: 170.0, green: 170.0, blue: 170.0, alpha: 1.0)
        
        self.bottomView.backgroundColor = UIColor(red: 45, green: 109, blue: 229, alpha: 1.0)*/
        
        self.setNavigationBar()
    }
    
    func setNavigationBar() {
        var cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelAction")
        self.navigationItem.rightBarButtonItem = cancelButton
        self.navigationController?.navigationBar.barTintColor = UIColor.lightGrayColor()
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }
    
    @IBAction func mapIt(sender: AnyObject) {
        if (!locationTextfield.text.isEmpty) {
            // Clear map before new search
            clearMapAnnotations()
            searchLocation()
        }
    }
    
    @IBAction func postLocation(sender: AnyObject) {
        // Post data
        if (aboutTextfield.text.isEmpty || aboutTextfield.text == "Tell us about you!") {
            self.handleLocationSearchError("Don't be shy. Share something with us.")
        } else {
            //post
            
        }
    }
    
    // Handler for cancel button
    func cancelAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func searchLocation() {
        searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = locationTextfield.text
        search = MKLocalSearch(request: searchRequest)
        search.startWithCompletionHandler() { response, error in
            if let error = error {
                self.handleLocationSearchError("Location not found. Please try again.")
                println("Error while searching for location: \(error.localizedDescription)")
            } else {
                if (response == nil) {
                    self.handleLocationSearchError("Location not found. Please try again.")
                } else {
                    // display location in map
                    self.annotationPoint = MKPointAnnotation()
                    self.annotationPoint.title = self.locationTextfield.text
                    var locationCoord = CLLocationCoordinate2D(latitude: response.boundingRegion.center.latitude, longitude: response.boundingRegion.center.longitude)
                    self.annotationPoint.coordinate = locationCoord
                    
                    self.annotationView = MKAnnotationView(annotation: self.annotationPoint, reuseIdentifier: nil)
                    self.locationMap.center = self.annotationView.center
                    self.locationMap.addAnnotation(self.annotationView.annotation)
                    
                    // Set Region
                    self.mapSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                    self.mapRegion = MKCoordinateRegion(center: locationCoord, span: self.mapSpan)
                    self.locationMap.setRegion(self.mapRegion, animated: true)
                    
                    
                    // Hide UI
                    // Display UI
                    self.whereLabel.hidden = true
                    self.locationTextfield.hidden = true
                    self.mapItButton.hidden = true
                    self.submitButton.hidden = false
                    self.errorLabel.hidden = true
                    self.aboutTextfield.hidden = false
                    
                    /*self.upperView.backgroundColor = UIColor(red: 45, green: 109, blue: 229, alpha: 1.0)*/
                    
                    self.locationMap.hidden = false
                }
            }
        }
    }
    
    func handleLocationSearchError(error: String) {
        self.errorLabel.text = error
        self.errorLabel.hidden = false
    }
    
    func clearMapAnnotations() {
        if (self.locationMap.annotations.count != 0) {
            annotation = self.locationMap.annotations[0] as! MKAnnotation
            self.locationMap.removeAnnotation(annotation)
        }
    }
    
    /**
    Subscriber to keyboard notifications
    **/
    func subscribeToKeyboardNotifications() {
        // Show keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        // Hide keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    Repositions view frame when keyboard displays
    **/
    func keyboardWillShow(notification: NSNotification) {
        //if self.bottomText.isFirstResponder() {
        setKeyboardHeight(notification)
        self.view.frame.origin.y -= self.keyboardHeight!
        //}
    }
    
    /**
    Repositions view frame when keyboard hides
    **/
    func keyboardWillHide(notification: NSNotification) {
        if (self.keyboardHeight != nil) {
            self.view.frame.origin.y += self.keyboardHeight!
            self.keyboardHeight = nil
        }
    }
    
    /**
    Gets the keyboard height
    **/
    func setKeyboardHeight(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        self.keyboardHeight = keyboardSize.CGRectValue().height
    }

    
    
}
