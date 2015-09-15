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
    @IBOutlet weak var emailNotification: UILabel!
    @IBOutlet weak var passwordNotification: UILabel!
    @IBOutlet weak var errorNotification: UILabel!
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
            self.displayLoginError("Couldn't log in with Facebook at this time")
        } else if (result.isCancelled) {
            self.displayLoginError("Facebook Log In Cancelled")
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
        errorNotification.hidden = true
        if (self.validateFields()) {
            toggleActivityIndicator(true)
            var email = emailTextfield.text
            var password = passwordTextfield.text
            var payload: [String: AnyObject] = [
                "udacity": [
                    OnTheMapHelper.API.Parameters.username: email,
                    OnTheMapHelper.API.Parameters.password: password
                ]
            ]
            self.createSession(payload)
        }
    }
    
    func loginWithFacebook(token: String) {
        self.activityIndicator.startAnimating()
        var credentials: [String : AnyObject] = [
            "facebook_mobile": [
                "access_token": token
            ]
        ]
        self.createSession(credentials)
    }
    
    // Requests a session with the given credentials
    func createSession(credentials: [String: AnyObject]) {
        let serviceEndpoint = OnTheMapHelper.API.udacityEndpoint + OnTheMapHelper.API.udacityApi + OnTheMapHelper.API.Methods.session
        
        let headers: NSMutableDictionary = [:]
        
        var task = OnTheMapHelper.getInstance().serviceRequest("POST", serviceEndpoint: serviceEndpoint, headers: headers, jsonBody: credentials, postProcessor: OnTheMapHelper.getInstance().trimResponse) { result, error in
            if let error = error {
                self.displayLoginError(error.localizedDescription)
            } else {
                let account = result.valueForKey(OnTheMapHelper.Response.Session.account) as? NSDictionary
                let session = result.valueForKey(OnTheMapHelper.Response.Session.session) as? NSDictionary
                if (account != nil && session != nil) {
                    let userId = account?.valueForKey(OnTheMapHelper.Response.Session.accountKey) as? String
                    let sessionId = session?.valueForKey(OnTheMapHelper.Response.Session.sessionId) as? String
                    self.getUdacityProfile(userId!)
                } else {
                    if let svcError = result.valueForKey("error") as? String {
                        self.displayLoginError(svcError)
                    }
                }
            }
        }
    }
    
    
    func getUdacityProfile(userId: String) {
        var method = OnTheMapHelper.getInstance().replaceParamsInUrl(OnTheMapHelper.API.Methods.users, paramId: "userId", paramValue: userId)
        var endpoint = OnTheMapHelper.API.udacityEndpoint + OnTheMapHelper.API.udacityApi + method!
        
        let headers: NSMutableDictionary = [:]

        var task = OnTheMapHelper.getInstance().serviceRequest("GET", serviceEndpoint: endpoint, headers: headers, jsonBody: nil, postProcessor: OnTheMapHelper.getInstance().trimResponse) { result, error in
            if let error = error {
                self.displayLoginError("Couldn't get Udacity profile")
            } else {
                if let user = result.valueForKey("user") as? NSDictionary {
                    let firstName = user.valueForKey("first_name") as? String
                    let lastName = user.valueForKey("last_name") as? String
                    // create profile
                    var profile = UdacityProfile(userId: userId, firstName: firstName!, lastName: lastName!)
                    // store it
                    self.setSessionProfile(profile)
                    // segue to map view
                    self.displayMapView()
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
    
    func displayLoginError(error: String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.toggleActivityIndicator(false)
            self.errorNotification.text = error
            self.errorNotification.hidden = false
            println("Error while login: \(error)")
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
            emailNotification.text = "Please enter your email"
            emailNotification.hidden = false
            return false
        }
        if (!isValidEmail(email)) {
            emailNotification.text = "Please enter a valid email address"
            emailNotification.hidden = false
            return false
        }
        passwordTextfield.resignFirstResponder()
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