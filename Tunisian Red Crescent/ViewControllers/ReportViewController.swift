//
//  ReportViewController.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 5/5/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import UIKit
import Spring
import PermissionScope
import Kugel
import SwiftyButton
import MessageUI
import SwiftyJSON

final class ReportViewController : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MFMessageComposeViewControllerDelegate{
   
    @IBOutlet weak var reportButton: SwiftyButton!
    @IBOutlet weak var imagePlaceholder: UIImageView!
    
    @IBOutlet weak var txtDescription: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        ScrollToTextViewWhenKeyboard()
        Kugel.subscribe("OnAccidentReported", block: {notification in
            self.popVC()
        })
        
        
        Kugel.subscribe("OnConnected", block: {notification in
            self.SetButtonText()
        })
        Kugel.subscribe("OnDisconnected", block: {notification in
            self.SetButtonText()
        })
        Kugel.subscribe("OnConnecting", block: {notification in
            self.SetButtonText()
        })
        Kugel.subscribe("OnUserInfo", block: {notification in
            self.SetButtonText()
        })
        SetButtonText()
    }
    
    func SetButtonText() {
        if Socket.IsConnectedToInternet && WebService.IsConnected{
            reportButton.setTitle("Report!", forState: UIControlState.Normal)
        }else {
            reportButton.setTitle("Report! (SMS)", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func onCameraClicked(sender: AnyObject) {
        dismissKeyboard()
        PickImage()
    }
    @IBAction func onReportClicked(sender: AnyObject) {
        dismissKeyboard()
        if Socket.IsConnectedToInternet && WebService.IsConnected{
            WebService.ReportAccident(txtDescription.text, image: newImage)
        }else {
            SweetAlert().showAlert("Are you sure?", subTitle: "Offline/Logged out. Sending report through sms. continue?", style: AlertStyle.Warning, buttonTitle:"Cancel", buttonColor:UIColorFromRGB(0xD0D0D0) , otherButtonTitle:  "Yes, Send!", otherButtonColor: UIColorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
                if isOtherButton == true {
                    print("Cancel Button  Pressed")
                }
                else {
                    self.SendSms()
                }
            }
        }
    }
    
    func SendSms() {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            let body : JSON = [
                "x": Location.lastLocation.Latitude!.toString,
                "y": Location.lastLocation.Longitude!.toString,
                "t": JsTimestampTransform().transformToJSON(Location.lastLocation.Timestamp)!,
                "d": txtDescription.text
            ]
            
            controller.body = body.rawString(options: NSJSONWritingOptions())
            controller.recipients = ["+18704556288"]
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }else{
            SweetAlert().showAlert("SMS Error", subTitle: ("Not able to text messages."), style: AlertStyle.Error)

        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResultCancelled.rawValue :
            break
            
        case MessageComposeResultFailed.rawValue :
            SweetAlert().showAlert("Error reporting accident", subTitle: ("Could not report accident through sms."), style: AlertStyle.Error)
                break
        case MessageComposeResultSent.rawValue :
            SweetAlert().showAlert("Success!", subTitle: "Accident Reported through sms.", style: AlertStyle.Success)
            popVC()
            break
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK : image picker
    
    var imagePicker: UIImagePickerController!
    var newImage: UIImage?
    func RequestPickImage(wantsCamera: Bool = true) {
        let pscope = PermissionScope()
        if wantsCamera {
            pscope.addPermission(CameraPermission(), message: "Allow the camera to change your profile picture.")
        }else{
            pscope.addPermission(PhotosPermission(), message: "Allow photos to change your profile picture.")
        }
        pscope.show({ finished, results in
            self.PickImage(wantsCamera)
            }, cancelled: { (results) -> Void in
                
        })
    }
    func PickImage(wantsCamera: Bool = true) {
        if wantsCamera && UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .Camera
            presentViewController(self.imagePicker, animated: true, completion: nil)
        }else if !wantsCamera && UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .PhotoLibrary
            presentViewController(imagePicker, animated: true, completion: nil)
        }else{
            SweetAlert().showAlert("Oops", subTitle: "It seems that this option is not available on your phone.", style: AlertStyle.Error)
            
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: {
            self.imagePlaceholder.image = image
            self.newImage = image
        })
        
    }

    // MARK : TextFieldKeyboardHelper
    func ScrollToTextViewWhenKeyboard() {
        originalFrame = self.view.frame
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    var originalFrame: CGRect?
    func keyboardWillShow(notification: NSNotification) {
            let info:NSDictionary = notification.userInfo!
            let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
            let keyboardHeight: CGFloat = keyboardSize.height
                let duration: NSTimeInterval = NSTimeInterval(info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
                UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.view.frame = CGRectMake(0, (self.originalFrame!.origin.y - keyboardHeight), self.view.bounds.width, self.view.bounds.height)
                    }, completion: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        //let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        //let keyboardHeight: CGFloat = keyboardSize.height
        let duration: NSTimeInterval = NSTimeInterval(info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
        
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.frame = self.originalFrame!
            }, completion: nil)
        
    }

}