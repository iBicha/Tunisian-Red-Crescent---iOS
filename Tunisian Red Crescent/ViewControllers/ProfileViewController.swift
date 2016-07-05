//
//  ProfileViewController.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 5/4/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import UIKit
import Spring
import Kugel
import PermissionScope
final class ProfileViewController : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var profilePic: SpringImageView!
    @IBOutlet weak var nameLabel: SpringLabel!
    @IBOutlet weak var username: SpringLabel!
    @IBOutlet weak var email: SpringLabel!
   
    @IBOutlet weak var birthday: SpringLabel!
    
    @IBOutlet weak var galleryButton: SpringButton!
    @IBOutlet weak var cameraButton: SpringButton!
    
    
    @IBOutlet weak var txtFirstName: SpringTextField!
    @IBOutlet weak var txtLastName: SpringTextField!
    @IBOutlet weak var txtUsername: SpringTextField!
    @IBOutlet weak var txtEmail: SpringTextField!
    @IBOutlet weak var txtPassword: SpringTextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = editButtonItem()
        self.hideKeyboardWhenTappedAround()
        ScrollToTextFieldWhenKeyboard()
        nameLabel.text = CrtUser.Me.FirstName! + " " + CrtUser.Me.LastName!
        username.text = "Username : " +  (CrtUser.Me.Username ?? "N/A")
        email.text = "Email : " +  (CrtUser.Me.Email ?? "N/A")
        if let birthdate = CrtUser.Me.BirthDate {
            if let date = NSDate(fromString: birthdate, format: "dd/MM/yyyy") {
                birthday.text = "Birthday : " + date.toString(format: "dd MMM yyyy")
            }
        }else{
            birthday.text = "Birthday : N/A"
        }
        Kugel.subscribe("OnUserImage", block: {notification in
            self.SetProfilePic()
        })
        SetProfilePic()
    }
    func SetProfilePic() {
        if let image = CrtUser.Me.ProfileImage {
            self.profilePic.image = image
            self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2
            self.profilePic.clipsToBounds = true
        }
    }
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            newImage = nil
            
            txtFirstName.text = CrtUser.Me.FirstName ?? ""
            txtLastName.text = CrtUser.Me.LastName ?? ""
            txtEmail.text = CrtUser.Me.Email ?? ""
            txtUsername.text = CrtUser.Me.Username ?? ""
            txtPassword.text  = ""
            if let birthdate = CrtUser.Me.BirthDate {
                if let date = NSDate(fromString: birthdate, format: "dd/MM/yyyy") {
                    datePicker.date = date
                    datePicker.hidden = false
                }
            }
            
            cameraButton.hidden = false
            galleryButton.hidden = false
            cameraButton.animation = "zoomIn"
            galleryButton.animation = "zoomIn"
            galleryButton.delay = 0.2
            
            nameLabel.hidden = false
            username.hidden = false
            email.hidden = false
            birthday.hidden = false
            
            txtFirstName.hidden = false
            txtLastName.hidden = false
            txtUsername.hidden = false
            txtEmail.hidden = false
            txtPassword.hidden = false

            nameLabel.animation = "zoomOut"
            username.animation = "zoomOut"
            email.animation = "zoomOut"
            birthday.animation = "zoomOut"
            nameLabel.duration = 1
            username.duration = 1
            email.duration = 1
            birthday.duration = 1
            txtFirstName.animation = "squeezeLeft"
            txtLastName.animation = "squeezeLeft"
            txtUsername.animation = "squeezeLeft"
            txtEmail.animation = "squeezeLeft"
            txtPassword.animation = "squeezeLeft"
            txtLastName.delay = 0.2
            txtUsername.delay = 0.4
            txtEmail.delay = 0.6
            txtPassword.delay = 0.8

            txtFirstName.animate()
            txtLastName.animate()
            txtUsername.animate()
            txtEmail.animate()
            txtPassword.animate()

            nameLabel.animate()
            username.animate()
            email.animate()
            birthday.animate()
            cameraButton.animate()
            galleryButton.animate()
        }else{
            
            nameLabel.animation = "zoomIn"
            username.animation = "zoomIn"
            email.animation = "zoomIn"
            birthday.animation = "zoomIn"
            nameLabel.duration = 1
            username.duration = 1
            email.duration = 1
            birthday.duration = 1
            
            cameraButton.animation = "zoomOut"
            galleryButton.animation = "zoomOut"
            galleryButton.delay = 0.2
         
            txtFirstName.animation = "zoomOut"
            txtLastName.animation = "zoomOut"
            txtUsername.animation = "zoomOut"
            txtEmail.animation = "zoomOut"
            txtPassword.animation = "zoomOut"
            txtFirstName.animate()
            txtLastName.animate()
            txtUsername.animate()
            txtEmail.animate()
            txtPassword.animate()
            
            nameLabel.animate()
            username.animate()
            email.animate()
            birthday.animate()
            cameraButton.animate()
            galleryButton.animate()
            cameraButton.animate()
            galleryButton.animate()
            datePicker.hidden = true

            dismissKeyboard()
            
            //Apply changes
            if newImage != nil {
                WebService.SubmitUserImage(newImage!)
            }
            var changes = false
            if CrtUser.Me.FirstName != txtFirstName.text ||
            CrtUser.Me.LastName != txtLastName.text ||
            CrtUser.Me.Username != txtUsername.text ||
            CrtUser.Me.Email != txtEmail.text ||
            !txtPassword.text!.isEmpty
            {
                changes = true
            }
            if let birthdate = CrtUser.Me.BirthDate {
                let dateStr = datePicker.date.toString(format: "dd/MM/yyyy")
                if birthdate != dateStr {
                    changes = true
                }
            }
            if changes {
                nameLabel.text = txtFirstName.text! + " " + txtLastName.text!
                email.text = "Email : " + txtEmail.text!
                username.text = "Username : " +  txtUsername.text!
                birthday.text = "Birthday : " + datePicker.date.toString(format: "dd/MM/yyyy")
                WebService.EditUser(txtFirstName.text!, lastname: txtLastName.text!, email: txtEmail.text!,username: txtUsername.text!, birthdate: datePicker.date.toString(format: "dd/MM/yyyy"), passwd: txtPassword.text!)
            }
        }
    }
    
    @IBAction func onGalleryClicked(sender: AnyObject) {
        PickImage(false)
    }
    
    @IBAction func onCameraClicked(sender: AnyObject) {
        PickImage(true)
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
            self.profilePic.image = image
            self.newImage = image
        })
        
    }
    
    // MARK : TextFieldKeyboardHelper
    func ScrollToTextFieldWhenKeyboard() {
        originalFrame = self.view.frame
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(textFieldDidBeginEditing(_:)), name: UITextFieldTextDidBeginEditingNotification, object: nil)
        center.addObserver(self, selector: #selector(textFieldDidEndEditing(_:)), name: UITextFieldTextDidEndEditingNotification, object: nil)
        
    }
    
    var currentEditingTextField: UITextField?
    var originalFrame: CGRect?
    func textFieldDidBeginEditing(notification: NSNotification) {
        currentEditingTextField = notification.object as? UITextField
        
    }
    func textFieldDidEndEditing(notification: NSNotification) {
        currentEditingTextField = nil
    }
    func keyboardWillShow(notification: NSNotification) {
        if let textfield = currentEditingTextField {
            let info:NSDictionary = notification.userInfo!
            let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
            let keyboardHeight: CGFloat = keyboardSize.height
            if self.view.bounds.height - keyboardHeight < textfield.frame.origin.y + textfield.frame.height {
                let duration: NSTimeInterval = NSTimeInterval(info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
                UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.view.frame = CGRectMake(0, (self.originalFrame!.origin.y - keyboardHeight), self.view.bounds.width, self.view.bounds.height)
                    }, completion: nil)
            }
            
        }
        
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