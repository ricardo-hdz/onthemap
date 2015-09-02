//
//  LoginTextfield.swift
//  OnTheMap
//
//  Created by Ricardo Hdz on 9/1/15.
//  Copyright (c) 2015 Ricardo Hdz. All rights reserved.
//

import Foundation
import UIKit

class LoginTextfield: UITextField, UITextFieldDelegate {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Adds a padding to textfields
        let paddingTextfield = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 30))
        self.leftView = paddingTextfield
        self.leftViewMode = UITextFieldViewMode.Always
    }
    
    /* Textfield delegate methios */
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
}