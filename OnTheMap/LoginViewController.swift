//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/1/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//
import UIKit
import Foundation

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var facebookLogin: UIButton!
    @IBOutlet weak var emailNotification: UILabel!
    @IBOutlet weak var passwordNotification: UILabel!
    @IBOutlet weak var errorNotification: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        errorNotification.hidden = true
        if (self.validateFields()) {
            
        }
    }
    
    /* Validates input fields */
    func validateFields() -> Bool {
        var email = emailTextfield.text
        if (email.isEmpty) {
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
        if (password.isEmpty) {
            passwordNotification.hidden = false
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
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
    
    
    
}