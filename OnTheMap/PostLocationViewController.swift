//
//  PostLocationViewController.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/6/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

import MapKit
import UIKit

class PostLocationViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var locationMap: MKMapView!
    
    @IBOutlet weak var topViewStepOne: UIView!
    @IBOutlet weak var bottomViewStepOne: UIView!
    @IBOutlet weak var topViewStepTwo: UIView!
    
    @IBOutlet weak var whereLabel: UILabel!
    
    @IBOutlet weak var tellsUsAboutTextfield: CustomTextfield!
    @IBOutlet weak var locationTextfield: CustomTextfield!
    
    @IBOutlet weak var mapItButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var search: MKLocalSearch!
    var searchRequest: MKLocalSearchRequest!
    var searchResponse: MKLocalSearchResponse!
  
    var annotationView: MKAnnotationView!
    
    var keyboardHeight: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationTextfield.delegate = self
        self.tellsUsAboutTextfield.delegate = self
        self.subscribeToKeyboardNotifications()
        
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.mapItButton.layer.cornerRadius = 5
        self.displayControls()
        self.setNavigationBar()
    }
    
    func displayControls() {
        // Views
        self.topViewStepOne.hidden = false
        self.bottomViewStepOne.hidden = false
        self.topViewStepTwo.hidden = true
        self.locationMap.hidden = true
        
        // Controls - Step 1
        self.whereLabel.hidden = false
        self.locationTextfield.hidden = false
        self.mapItButton.hidden = false
        
        // Controls - Step 2
        self.tellsUsAboutTextfield.hidden = true
        self.submitButton.hidden = true
        self.submitButton.enabled = false
    }
    
    func displayControlsMap() {
        // Views
        self.topViewStepOne.hidden = true
        self.bottomViewStepOne.hidden = true
        self.topViewStepTwo.hidden = false
        self.locationMap.hidden = false
        
        // Controls - Step 1
        self.whereLabel.hidden = true
        self.locationTextfield.hidden = true
        self.mapItButton.hidden = true
        
        // Controls - Step 2
        self.tellsUsAboutTextfield.hidden = false
        self.submitButton.hidden = false
        self.submitButton.enabled = true
    }
    
    func setNavigationBar() {
        var cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelAction")
        self.navigationItem.rightBarButtonItem = cancelButton
        self.navigationController?.navigationBar.barTintColor = UIColor.lightGrayColor()
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }
    
    @IBAction func mapIt(sender: AnyObject) {
        if (!locationTextfield.text.isEmpty && locationTextfield.text != "Location") {
            activityIndicator.startAnimating()
            // Clear map before new search
            clearMapAnnotations()
            searchLocation()
        } else {
            activityIndicator.stopAnimating()
            handleAlert("On the Map - Location", error: "Please enter your location")
        }
    }
    
    @IBAction func postLocation(sender: AnyObject) {
        // Post data
        if (self.tellsUsAboutTextfield.text.isEmpty || self.tellsUsAboutTextfield.text == "Tell us about You!") {
            handleAlert("On the Map - URL", error: "Please share something with us!")
        } else {
            let profile = self.getSessionProfile()
            
            println("Profile user id: \(profile.userId)")
            println("Profile user id: \(profile.firstName)")
            println("Profile user id: \(profile.lastName)")
            println("Location user id: \(locationTextfield.text)")
            println("Profile user id: \(self.annotationView.annotation.coordinate.latitude)")
            println("Profile user id: \(self.annotationView.annotation.coordinate.longitude)")
            
            var location: [String: AnyObject] = [
                "uniqueKey": profile.userId!,
                "firstName": profile.firstName!,
                "lastName": profile.lastName!,
                "mapString": locationTextfield.text,
                "mediaURL": tellsUsAboutTextfield.text,
                "latitude": self.annotationView.annotation.coordinate.latitude,
                "longitude": self.annotationView.annotation.coordinate.longitude
            ]
            
            LocationHelper.postLocation(location) { result, error in
                if let error = error {
                    self.handleAlert("On the Map - Network error", error: error)
                } else if result {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            }
        }
    }
    
    func getSessionProfile() ->  UdacityProfile {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.udacityProfile!
    }
    
    // Handler for cancel button
    func cancelAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func searchLocation() {
        LocationHelper.searchGeocodeByString(locationTextfield.text) { placemark, error in
            if let error = error {
                self.handleAlert("On the Map - Location Error", error: error)
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    var annotationPoint = MKPointAnnotation()
                    annotationPoint.title = self.locationTextfield.text
                    var locationCoord = CLLocationCoordinate2DMake(placemark!.location.coordinate.latitude, placemark!.location.coordinate.longitude)
                    annotationPoint.coordinate = locationCoord
                    var annotationView = MKAnnotationView(annotation: annotationPoint, reuseIdentifier: nil)
                    
                    self.annotationView = annotationView
                    self.locationMap.center = annotationView!.center
                    self.locationMap.addAnnotation(annotationView!.annotation)
                    
                    var mapSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                    var mapRegion = MKCoordinateRegion(center: locationCoord, span: mapSpan)
                    self.locationMap.setRegion(mapRegion, animated: true)
                    
                    // display controls
                    self.activityIndicator.stopAnimating()
                    self.displayControlsMap()
                })
            }
        }
    }
    
    func handleAlert(alertTitle: String, error: String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.stopAnimating()
            let alertController = UIAlertController(title: alertTitle, message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func clearMapAnnotations() {
        if (self.locationMap.annotations.count != 0) {
            var annotation = self.locationMap.annotations[0] as! MKAnnotation
            self.locationMap.removeAnnotation(annotation)
        }
    }
    
    // Gesture recognizer - Delegate methods
    func setTapRecognizer() {
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return self.locationTextfield.isFirstResponder() || self.tellsUsAboutTextfield.isFirstResponder()
    }
    
    // Textfield Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        return false
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
        setKeyboardHeight(notification)
        self.view.frame.origin.y -= self.keyboardHeight!
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
