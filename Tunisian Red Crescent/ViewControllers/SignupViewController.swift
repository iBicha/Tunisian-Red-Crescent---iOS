//
//  SignupViewController.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 5/10/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import UIKit
import Kugel
final class SignupViewController : UIViewController{
    
    
    @IBOutlet weak var FirstName: HTYTextField!
    @IBOutlet weak var LastName: HTYTextField!
    @IBOutlet weak var Email: HTYTextField!
    @IBOutlet weak var Password: HTYTextField!
    @IBOutlet weak var Password2: HTYTextField!
    
    @IBOutlet weak var birthday: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        FirstName.rightPlaceholder = "First Name"
        LastName.rightPlaceholder = "Last Name"
        Email.rightPlaceholder = "Email"
        Password.rightPlaceholder = "Password"
        Password2.rightPlaceholder = "Password"
        
        Kugel.subscribe("OnSignup", block: {notification in
            if let navContr = self.navigationController {
                for vc in navContr.viewControllers {
                    if vc.isKindOfClass(LoginViewController) {
                        let LoginVC = vc as! LoginViewController
                        LoginVC.emailTxt.text = self.Email.text
                        LoginVC.passTxt.text = self.Password.text
                    }
                }
            }
            self.popVC()
        })
    }

    @IBAction func signupClicked(sender: AnyObject) {
        for textfield in [FirstName, LastName, Email, Password, Password2] {
            if textfield.text == "" {
                WiggleText(textfield)
                return
            }
        }

        if !Email.text!.isEmail {
            SweetAlert().showAlert("Invalid Email", subTitle: "Please enter a valid email.", style: AlertStyle.Error)
            return
        }
        if Password.text != Password2.text {
            SweetAlert().showAlert("Password Mismatch", subTitle: "Please verify your password fields.", style: AlertStyle.Error)
            return
        }
        
        WebService.AddUser(FirstName.text!, lastname: LastName.text!, email: Email.text!, birthdate: birthday.date.toString(format: "dd/MM/yyyy"), passwd: Password.text!)

    }
    
    func WiggleText(txt:HTYTextField) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(txt.center.x - 10, txt.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(txt.center.x + 10, txt.center.y))
        txt.layer.addAnimation(animation, forKey: "position")
    }

}