//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/1/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//
import UIKit
import Foundation

class LoginViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var keyboardHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayFacebookButton()
        
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        self.subscribeToKeyboardNotifications()
        
        /* Configure tap recognizer */
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
        
        // Log in with FB, if credentials are available
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            println("Login with valid facebook")
            self.loginWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    func displayFacebookButton() {
        let loginView: FBSDKLoginButton = FBSDKLoginButton()
        self.view.addSubview(loginView)
        var x_coord = (self.view.frame.size.width - loginView.frame.size.width)
        var y_coord = (self.view.frame.size.height - loginView.frame.size.height)
        loginView.center = CGPoint(x: x_coord, y: y_coord)
        loginView.readPermissions = [
            "public_profile",
            "email"
        ]
        loginView.delegate = self
    }
    
    // Facebook Delegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (error != nil) {
            handleError("On the Map - Login", error: "Couldn't log in with Facebook at this time")
        } else if (result.isCancelled) {
            handleError("On the Map - Login", error: "Facebook Log In Cancelled")
        } else {
            if (result.token != nil) {
                // login to udacity
                self.loginWithFacebook(result.token.tokenString)
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {}
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return self.emailTextfield.isFirstResponder() || self.passwordTextfield.isFirstResponder()
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        if (self.validateFields()) {
            toggleActivityIndicator(true)
            var email = emailTextfield.text
            var password = passwordTextfield.text
            var credentials: [String: AnyObject] = [
                "udacity": [
                    OnTheMapHelper.API.Parameters.username: email,
                    OnTheMapHelper.API.Parameters.password: password
                ]
            ]
            //self.createSession(payload)
            loginWithCredentials(credentials)
        }
    }
    
    func loginWithFacebook(token: String) {
        self.activityIndicator.startAnimating()
        var credentials: [String : AnyObject] = [
            "facebook_mobile": [
                "access_token": token
            ]
        ]
        loginWithCredentials(credentials)
    }
    
    func loginWithCredentials(credentials: [String: AnyObject]) {
        LoginHelper.createSession(credentials) { userId, sessionId, error in
            if let error = error {
                self.handleError("On the Map - Login", error: error)
            } else {
                LoginHelper.getUdacityProfile(userId!) { profile, error in
                    if let error = error {
                        self.handleError("On the Map - Login", error: error)
                    } else {
                        self.setSessionProfile(profile!)
                        self.displayMapView()
                    }
                }
            }
        }
    }
    
    @IBAction func signupAction(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: OnTheMapHelper.API.udacityEndpoint)!)
    }
    
    // Sets the profile in the appdelegate for future reference
    func setSessionProfile(profile: UdacityProfile) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.udacityProfile = profile
    }
    
    func displayMapView() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapTabBarController") as! UITabBarController
        self.activityIndicator.stopAnimating()
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func handleError(alertTitle: String, error: String) {
        let alertController = UIAlertController(title: alertTitle, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func toggleActivityIndicator(display: Bool) {
        if (display) {
            self.activityIndicator.startAnimating()
            self.activityIndicator.hidden = false
        } else {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
        }
    }
    
    /* Validates input fields */
    func validateFields() -> Bool {
        emailTextfield.resignFirstResponder()
        var email = emailTextfield.text
        if (email.isEmpty || emailTextfield.text == "Email") {
            self.handleError("On the Map - Login", error: "Please enter your email")
            return false
        }
        if (!isValidEmail(email)) {
            self.handleError("On the Map - Login", error: "Please enter a valid email address")
            return false
        }
        passwordTextfield.resignFirstResponder()
        var password = passwordTextfield.text
        if (password.isEmpty || passwordTextfield.text == "Password") {
            self.handleError("On the Map - Login", error: "Please enter yor password")
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
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