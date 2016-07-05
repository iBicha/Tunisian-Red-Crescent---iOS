//
//  LoginViewController.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 5/5/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import UIKit
import Kugel
import Spring
import EZSwiftExtensions
import RealmSwift
import FBSDKLoginKit

final class LoginViewController : UIViewController{
    
    @IBOutlet weak var emailTxt: HTYTextField!
    @IBOutlet weak var passTxt: HTYTextField!
    
    @IBOutlet weak var rememberMe: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        Kugel.subscribe("OnUserInfo", block: {notification in
            self.popVC()
        })
        emailTxt.rightPlaceholder = "Email/Username"
        passTxt.rightPlaceholder = "Password"

        if UserSettings.rememberMe {
            emailTxt.SetText(UserSettings.username, delay: 0.3)
            passTxt.SetText(UserSettings.password,delay: 0.5)
        }
        ez.runThisAfterDelay(seconds: 0.7, after: {
            self.rememberMe.setOn(UserSettings.rememberMe, animated: true)
        })
    }
    
    @IBAction func onLoginClicked(sender: AnyObject) {
        if emailTxt.text == "" {
            WiggleText(emailTxt)
            return
        }
        if passTxt.text == "" {
            
            WiggleText(passTxt)
            return
        }
        UserSettings.Save {
            UserSettings.username = rememberMe.on ? emailTxt.text! : ""
            UserSettings.password = rememberMe.on ? passTxt.text! : ""
        }
        dismissKeyboard()
        WebService.Authenticate(emailTxt.text!, passwd: passTxt.text!,silent: false)
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
    
    @IBAction func onRememberMeChnaged(sender: AnyObject) {
        UserSettings.Save {
            UserSettings.rememberMe = rememberMe.on
        }
    }
    
    @IBAction func onFacebookLoginClicked(sender: AnyObject) {
        let fbLoginManager = FBSDKLoginManager()
        //"user_birthday" requires review. fuck it.
        fbLoginManager.logInWithReadPermissions(["email"], fromViewController: self, handler: { (result, error) -> Void in
            if error == nil{
                if !result.isCancelled
                {
                    WebService.FacebookAuthenticate(result.token.tokenString, silent: false)
                }
            }
            else {
                SweetAlert().showAlert("Facebook login error", subTitle: (error.localizedFailureReason ?? error.localizedDescription), style: AlertStyle.Error)
            }
        })
    }
}