//
//  NewMessageViewController.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 5/11/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import UIKit
import PermissionScope
import Kugel
final class NewMessageViewController : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imagePlaceholder: UIImageView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    
    @IBOutlet weak var segAudience: UISegmentedControl!
    
    
    var audiences = [
        "[\""+"Admins"+"\"]",
        "[\""+"Admins"+"\",\""+"Members"+"\"]",
        "[\""+"Admins"+"\",\""+"Members"+"\",\""+"Users"+"\"]"

    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        ScrollToTextViewWhenKeyboard()
        
        if !CrtUser.Me.IsAdmin {
            segAudience.removeAllSegments()
            segAudience.insertSegmentWithTitle("Admins", atIndex: 0, animated: false)
            audiences = ["[\""+"Admins"+"\"]"]

        }

        segAudience.selectedSegmentIndex = 0
        Kugel.subscribe("OnMessage", block: {notification in
            self.popVC()
        })
        
    }


    @IBAction func onCameraClicked(sender: AnyObject) {
        dismissKeyboard()
        PickImage(true)
    }

    @IBAction func onGalleryClicked(sender: AnyObject) {
        dismissKeyboard()
        PickImage(false)
    }

    @IBAction func onSendClicked(sender: AnyObject) {
        dismissKeyboard()
        let audience = audiences[segAudience.selectedSegmentIndex]
        WebService.SendMessage(txtTitle.text!, descr: txtDescription.text!, audience: audience , image: newImage)
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