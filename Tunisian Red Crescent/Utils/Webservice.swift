//
//  Webservice.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/29/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import MapKit
import Alamofire
import Alamofire_SwiftyJSON
import AlamofireObjectMapper
import Whisper
import RealmSwift
import EZLoadingActivity
import EZSwiftExtensions
import Kugel
import FBSDKLoginKit
class WebService{
    
    static let BaseUrl = "https://crt-server-ibicha.c9users.io/api/v1/"
    static var Token:String = ""
    
    static var IsConnected:Bool = false
    
    static func ChechServer(){
        if Reachability.isConnectedToNetwork() {
            Alamofire.request(.GET, BaseUrl + "ping")
                .responseSwiftyJSON({ (request, response, json, error) in
                    if json["success"].bool ?? false{
                        print("Server Is Up")
                    }else{
                        EZLoadingActivity.hide()
                        SweetAlert().showAlert("Oops", subTitle: "it seems that our servers are down for maintenance. sorry for the inconvenience.", style: AlertStyle.Warning)
                        print("Server is down")
                        print(error)
                    }
                })
        }else{
            print("No Internet")
        }
    }
    static func AddUser(firstName :String, lastname:String, email: String, birthdate: String, passwd:String){
        EZLoadingActivity.show("Creating new account...", disableUI: true)
        Notifications.BusyNavBar()

        let params = [
            "FirstName":firstName,
            "LastName":lastname,
            "Email":email,
            "BirthDate":birthdate,
            "Password":passwd
        ]
        Alamofire.request(.POST, BaseUrl+"user/add", parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                EZLoadingActivity.hide()
                Notifications.BusyNavBar(false)
                if json["success"].bool ?? false{
                    SweetAlert().showAlert("Success!", subTitle: "Account Created.", style: AlertStyle.Success)
                    Kugel.publish("OnSignup")
                }else{
                    SweetAlert().showAlert("Error creating account", subTitle: (json["message"].string ?? "Could not create user."), style: AlertStyle.Error)
                }
            })
    }

    
    static func Authenticate(username : String,passwd : String, silent : Bool=true){
        if !silent {
            EZLoadingActivity.show("Logging In...", disableUI: true)
        }
        Notifications.BusyNavBar()
        let params = [
            "Email":username,
            "Password":passwd
        ]
        Alamofire.request(.POST, BaseUrl+"authenticate", parameters: params)
            .responseSwiftyJSON({ (request, response, json, error) in
                if !silent {
                    EZLoadingActivity.hide()
                }
                Notifications.BusyNavBar(false)
                if json["success"].bool ?? false{
                    Token = json["token"].string ?? ""
                    IsConnected = true
                    Socket.SendToken()
                    GetUserInfo()
                    GetMessages()
                }else if !silent{
                    SweetAlert().showAlert("Login Error", subTitle: (json["message"].string ?? "Could not login."), style: AlertStyle.Error)
                }else{
                    Whistle(Murmur(title: "Failed to authenticate user.",duration: 5))
                }
            })
    }
    static func FacebookAuthenticate(fb_access_token : String, silent : Bool=true){
        if !silent {
            EZLoadingActivity.show("Logging In...", disableUI: true)
        }
        Notifications.BusyNavBar()
        let headers = [
            "access_token": fb_access_token
        ]
        Alamofire.request(.GET, BaseUrl + "facebookauth", headers: headers)
            .responseSwiftyJSON({ (request, response, json, error) in
                if !silent {
                    EZLoadingActivity.hide()
                }
                Notifications.BusyNavBar(false)
                if json["success"].bool ?? false{
                    Token = json["token"].string ?? ""
                    IsConnected = true
                    Socket.SendToken()
                    GetUserInfo()
                    GetMessages()
                }else if !silent{
                    SweetAlert().showAlert("Login Error", subTitle: (json["message"].string ?? "Could not login."), style: AlertStyle.Error)
                }else{
                    Whistle(Murmur(title: "Failed to authenticate user.",duration: 5))
                }
            })
    }

    static func Logout(){
        let headers = [
            "access_token": Token
        ]
        Alamofire.request(.GET, BaseUrl + "logout", headers: headers)
            .responseSwiftyJSON({ (request, response, json, error) in
        })
        FBSDKLoginManager().logOut()
        Socket.Reconnect()
        Token=""
        IsConnected = false
    }
    
    static func RequestMembership() {
        EZLoadingActivity.show("Requesting Membership...", disableUI: true)
        Notifications.BusyNavBar()

        let headers = [
            "access_token": Token
        ]
        Alamofire.request(.GET, BaseUrl + "user/requestmembership", headers: headers)
            .responseSwiftyJSON({ (request, response, json, error) in
                EZLoadingActivity.hide()
                Notifications.BusyNavBar(false)

                if json["success"].bool ?? false{
                    SweetAlert().showAlert("Success!", subTitle:(json["message"].string ?? "Done.") , style: AlertStyle.Success)
                }else{
                    SweetAlert().showAlert("Membership Error", subTitle: (json["message"].string ?? "Could not finish request."), style: AlertStyle.Error)
                }
            })
    }
    
    static func RequestAdminship() {
        EZLoadingActivity.show("Requesting Adminship...", disableUI: true)
        Notifications.BusyNavBar()

        let headers = [
            "access_token": Token
        ]
        Alamofire.request(.GET, BaseUrl + "user/requestadminship", headers: headers)
            .responseSwiftyJSON({ (request, response, json, error) in
                EZLoadingActivity.hide()
                Notifications.BusyNavBar(false)

                if json["success"].bool ?? false{
                    SweetAlert().showAlert("Success!", subTitle:(json["message"].string ?? "Done.") , style: AlertStyle.Success)
                }else{
                    SweetAlert().showAlert("Adminship Error", subTitle: (json["message"].string ?? "Could not finish request."), style: AlertStyle.Error)
                }
                
            })

    }
    
    static func GetMessages(){
        let headers = [
            "access_token": Token
        ]
        
        let req = Alamofire.request(.GET, BaseUrl + "messages", headers: headers)
        req.responseSwiftyJSON({ (request, response, json, error) in
                if json["success"].bool ?? false{
                    req.responseArray(keyPath: "messages") { (response: Response<[CrtMessage], NSError>) in
                        if let Messages = response.result.value {
                            let realm = try! Realm()
                            for msg in Messages {
                                let oldMessage = realm.objectForPrimaryKey(CrtMessage.self, key: msg.id!)
                                if oldMessage == nil {
                                    msg.Save()
                                }
                            }
                            Kugel.publish("OnMessage")
                        }
                    }
                }else{
                    Whistle(Murmur(title: (json["message"].string ?? "Error retriving messages."),duration: 5))
                }
            })
    }
    static func SendMessage(title: String, descr: String, audience: String, image: UIImage?) {
        EZLoadingActivity.show("Sending...", disableUI: true)
        Notifications.BusyNavBar()
        let headers = [
            "access_token": Token
        ]
        Alamofire.upload(.POST,BaseUrl+"message/send",headers: headers,
                         multipartFormData: { multipartFormData in
                            if image != nil {
                                if let imageData = UIImageJPEGRepresentation(image!, 0.5) {
                                    multipartFormData.appendBodyPart(data: imageData, name: "ImageFile", fileName: "file.jpg", mimeType: "image/jpeg")
                                }
                            }
                            multipartFormData.appendBodyPart(data: audience.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"Audience")
                            multipartFormData.appendBodyPart(data: descr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"Description")
                            multipartFormData.appendBodyPart(data: title.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"Title")
                            
            },
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .Success(let upload, _, _):
                                upload.responseSwiftyJSON({ (request, response, json, error) in
                                    EZLoadingActivity.hide()
                                    Notifications.BusyNavBar(false)
                                    if json["success"].bool ?? false{
                                        SweetAlert().showAlert("Success!", subTitle: "Message Sent.", style: AlertStyle.Success)
                                    }else{
                                        SweetAlert().showAlert("Error sending message", subTitle: (json["message"].string ?? "Could not send message."), style: AlertStyle.Error)
                                    }
                                })
                            case .Failure(let encodingError):
                                EZLoadingActivity.hide()
                                Notifications.BusyNavBar(false)
                                print(encodingError)
                                SweetAlert().showAlert("Error encoding image", subTitle: ("Could not send message: something went wrong with encoding. please try another image."), style: AlertStyle.Error)
                                
                            }
            }
        )

    }
    static func EditUser(firstName :String, lastname:String, email: String, username: String, birthdate: String, passwd:String){
        EZLoadingActivity.show("Updating...", disableUI: true)
        Notifications.BusyNavBar()

        let headers = [
            "access_token": Token
        ]
        let params = [
            "FirstName":firstName,
            "LastName":lastname,
            "Email":email,
            "Username":username,
            "BirthDate":birthdate,
            "Password":passwd
        ]
        Alamofire.request(.POST, BaseUrl+"user/edit", parameters: params, headers: headers)
            .responseSwiftyJSON({ (request, response, json, error) in
                EZLoadingActivity.hide()
                Notifications.BusyNavBar(false)
                if json["success"].bool ?? false{
                    SweetAlert().showAlert("Success!", subTitle: "Account Updated.", style: AlertStyle.Success)
                    GetUserInfo()
                }else{
                    SweetAlert().showAlert("Error updating account", subTitle: (json["message"].string ?? "Could not update user."), style: AlertStyle.Error)
                }
            })
    }
    static func SubmitUserImage(image: UIImage){
        EZLoadingActivity.show("Uploading...", disableUI: true)
        Notifications.BusyNavBar()
        let headers = [
            "access_token": Token
        ]
        Alamofire.upload(.POST,BaseUrl+"user/submitimage",headers: headers,
            multipartFormData: { multipartFormData in
                    if let imageData = UIImageJPEGRepresentation(image, 0.5) {
                        multipartFormData.appendBodyPart(data: imageData, name: "ImageFile", fileName: "file.jpg", mimeType: "image/jpeg")
                    }
                
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseSwiftyJSON({ (request, response, json, error) in
                        EZLoadingActivity.hide()
                        Notifications.BusyNavBar(false)
                        if json["success"].bool ?? false{
                            SweetAlert().showAlert("Success!", subTitle: "Image updated.", style: AlertStyle.Success)
                            GetUserInfo()
                        }else{
                            SweetAlert().showAlert("Error uploading image", subTitle: (json["message"].string ?? "Could not update image."), style: AlertStyle.Error)
                        }
                    })
                case .Failure(let encodingError):
                    EZLoadingActivity.hide()
                    Notifications.BusyNavBar(false)
                    print(encodingError)
                    SweetAlert().showAlert("Error encoding image", subTitle: ("Could not update image: something went wrong with encoding. please try another image."), style: AlertStyle.Error)
                    
                }
            }
        )
    }
    
    static func GetUserInfo(){
        let headers = [
            "access_token": Token
        ]
        let req = Alamofire.request(.GET, BaseUrl + "user/me", headers: headers)
            req.responseSwiftyJSON({ (request, response, json, error) in
                if json["success"].bool ?? false{
                    req.responseObject(keyPath: "user") { (response: Response<CrtUser, NSError>) in
                        CrtUser.Me = response.result.value!
                        
                        print("Got User " + CrtUser.Me.FirstName! + " " + CrtUser.Me.LastName!)
                        Kugel.publish("OnUserInfo")
                        if CrtUser.Me.IsMember {
                            GetAccidents()
                        }
                    }
                }else{
                    Whistle(Murmur(title: "Error Getting User Info.",duration: 5))
                }
            })
    }
    
    static func ReportAccident(descr : String, image: UIImage?){
        if Location.lastLocation.Timestamp == 0 {
            SweetAlert().showAlert("Location Error", subTitle: "Could not get your location to report accident.", style: AlertStyle.Error)
            return
        }
        EZLoadingActivity.show("Reporting...", disableUI: true)
        Notifications.BusyNavBar()
        let headers = [
            "access_token": Token
        ]
        Alamofire.upload(.POST,BaseUrl+"accident/report",headers: headers,
            multipartFormData: { multipartFormData in
                if image != nil {
                    if let imageData = UIImageJPEGRepresentation(image!, 0.5) {
                        multipartFormData.appendBodyPart(data: imageData, name: "ImageFile", fileName: "file.jpg", mimeType: "image/jpeg")
                    }
                }
                multipartFormData.appendBodyPart(data: descr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"Description")
                multipartFormData.appendBodyPart(data: Location.lastLocation.toJSONString()!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"Location")
            
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseSwiftyJSON({ (request, response, json, error) in
                        EZLoadingActivity.hide()
                        Notifications.BusyNavBar(false)
                        if json["success"].bool ?? false{
                            SweetAlert().showAlert("Success!", subTitle: "Accident Reported.", style: AlertStyle.Success)
                            Kugel.publish("OnAccidentReported")
                        }else{
                            SweetAlert().showAlert("Error reporting accident", subTitle: (json["message"].string ?? "Could not report accident."), style: AlertStyle.Error)
                        }
                    })
                case .Failure(let encodingError):
                    EZLoadingActivity.hide()
                    Notifications.BusyNavBar(false)
                    print(encodingError)
                    SweetAlert().showAlert("Error encoding image", subTitle: ("Could not report accident: something went wrong with encoding. please try another image."), style: AlertStyle.Error)
                    
                }
            }
        )

    }
    
    static func HandleAccident(id : String){
        EZLoadingActivity.show("Handling...", disableUI: true)
        Notifications.BusyNavBar()

        let headers = [
            "access_token": Token
        ]
        Alamofire.request(.GET, BaseUrl + "accident/handle/" + id, headers: headers)
            .responseSwiftyJSON({ (request, response, json, error) in
                EZLoadingActivity.hide()
                Notifications.BusyNavBar(false)
                if json["success"].bool ?? false{
                    if let accident = Accidents[id] {
                        accident.IsHandled = true
                        CrtMap.UpdateAccidentMarker(accident)
                    }
                    SweetAlert().showAlert("Success!", subTitle:(json["message"].string ?? "Accident was handled.") , style: AlertStyle.Success)
                }else{
                    SweetAlert().showAlert("Error handling accident", subTitle: (json["message"].string ?? "Could not finish request."), style: AlertStyle.Error)
                }
                
            })
    }
    
    static func GetAccidents(){
        let headers = [
            "access_token": Token
        ]
        
        let req = Alamofire.request(.GET, BaseUrl + "accidents", headers: headers)
        req.responseSwiftyJSON({ (request, response, json, error) in
            if json["success"].bool ?? false{
                req.responseArray(keyPath: "accidents") { (response: Response<[CrtAccident], NSError>) in
                    if let accidents = response.result.value {
                        for accident in accidents {
                                if let oldAccident = Accidents[accident.id!]{
                                    if oldAccident.marker != nil {
                                        accident.marker = oldAccident.marker
                                    }
                                }
                            
                            Accidents[accident.id!] = accident
                            CrtMap.UpdateAccidentMarker(accident)
                        }
                    }
                }
                //Notify
            }else{
                Whistle(Murmur(title: (json["message"].string ?? "Error retriving accidents."),duration: 5))
            }
        })
    }
    
    static func GetCrtPlaces(){
        let req = Alamofire.request(.GET, BaseUrl + "crtplaces")
        req.responseSwiftyJSON({ (request, response, json, error) in
            if json["success"].bool ?? false{
                req.responseArray(keyPath: "crtplaces") { (response: Response<[CrtPlace], NSError>) in
                    if let crtPlaces = response.result.value {
                        for crtPlace in crtPlaces {
                            CrtMap.SetCrtPlaceMarker(crtPlace)
                        }
                    }
                }
            }else{
                Whistle(Murmur(title: (json["message"].string ?? "Error retriving places."),duration: 5))
            }
        })
    }
}
