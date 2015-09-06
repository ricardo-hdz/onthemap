//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/1/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//
import UIKit
import Foundation

class LoginViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var facebookLogin: UIButton!
    @IBOutlet weak var emailNotification: UILabel!
    @IBOutlet weak var passwordNotification: UILabel!
    @IBOutlet weak var errorNotification: UILabel!
    
    var keyboardHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        self.subscribeToKeyboardNotifications()
        
        /* Configure tap recognizer */
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return self.emailTextfield.isFirstResponder() || self.passwordTextfield.isFirstResponder()
    }

    
    @IBAction func loginAction(sender: AnyObject) {
        displayMapViewDirect()
        /*errorNotification.hidden = true
        if (self.validateFields()) {
            var email = emailTextfield.text
            var password = passwordTextfield.text
            var payload: [String: AnyObject] = [
                "udacity": [
                    OnTheMapHelper.API.Parameters.username: email,
                    OnTheMapHelper.API.Parameters.password: password
                ]
            ]
            
            var task = OnTheMapHelper.getInstance().taskforPOST(OnTheMapHelper.API.Methods.session, jsonBody: payload) { result, error in
                if let error = error {
                    self.displayLoginError(error.localizedDescription)
                } else {
                    let sessionId = result.valueForKey(OnTheMapHelper.Response.Session.id) as? String
                    let userId = result.valueForKey(OnTheMapHelper.Response.Account.key) as? String
                    if (sessionId != nil && userId != nil) {
                        var profile = UdacityProfile(sessionId: sessionId!, userId: userId!)
                        println("SessionId: \(sessionId)")
                        println("UserId: \(userId)")
                        self.displayMapView()
                    } else {
                        if let svcError = result.valueForKey("error") as? String {
                            self.displayLoginError(svcError)
                        }
                    }
                }
            }
        }*/
    }
    
    @IBAction func signupAction(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: OnTheMapHelper.API.udacityEndpoint)!)
    }
    
    func displayMapView() {
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapViewController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func displayMapViewDirect() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapTabBarController") as! UITabBarController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func displayLoginError(error: String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.errorNotification.text = error
            self.errorNotification.hidden = false
            println("Error while login: \(error)")
        })
    }
    
    /* Validates input fields */
    func validateFields() -> Bool {
        var email = emailTextfield.text
        if (email.isEmpty || emailTextfield.text == "Email") {
            emailNotification.text = "Please enter your email"
            emailNotification.hidden = false
            return false
        }
        if (!isValidEmail(email)) {
            emailNotification.text = "Please enter a valid email address"
            emailNotification.hidden = false
            return false
        }
        var password = passwordTextfield.text
        if (password.isEmpty || passwordTextfield.text == "Password") {
            passwordNotification.hidden = false
            return false
        }
        emailNotification.hidden = true
        passwordNotification.hidden = true
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
        if (textField == self.emailTextfield) {
            emailNotification.hidden = true
        } else if (textField == self.passwordTextfield) {
            passwordNotification.hidden = true
        }
    }
    
    /* Validates email address */
    func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        var test = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        var result = test.evaluateWithObject(email)
        return result
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