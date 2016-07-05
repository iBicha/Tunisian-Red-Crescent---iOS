//
//  Notifications.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/29/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import UIKit
import Whisper
import EZSwiftExtensions
import PermissionScope
import Kugel
import BusyNavigationBar

class Notifications {
    static func Init()
    {
        Kugel.subscribe("OnAccident", block: {notification in
            if let accident = notification.object as? CrtAccident {
                OnAccident(accident)
            }
        })
        Kugel.subscribe("OnMessage", block: {notification in
            if let message = notification.object as? CrtMessage {
                OnMessage(message)
            }
        })
        Kugel.subscribe("OnConnected", block: {notification in
            OnConnected()
        })
        Kugel.subscribe("OnConnecting", block: {notification in
            OnConnecting()
        })
        Kugel.subscribe("OnDisconnected", block: {notification in
            OnDisconnected()
        })
    }
    
    static func OnAccident(accident: CrtAccident)
    {
        let notification = UILocalNotification()
        notification.alertAction = "open"
        notification.userInfo = ["id": accident.id!]
        notification.category = "Accident"
        notification.alertBody = accident.Description
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    static func OnMessage(message: CrtMessage)
    {
        let notification = UILocalNotification()
        notification.alertAction = "open"
        notification.userInfo = ["id": message.id!]
        notification.category = "Message"
        notification.alertBody = message.Description
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    //Whisper
    static func OnConnected()
    {
        BusyNavBar(false)
        let message = Message(title: "Connected.", backgroundColor: UIColor.greenColor())
        Whisper(message,to: Settings.MainViewController ?? ez.topMostVC as! UINavigationController, action: .Show)
    }
    
    static func OnConnecting()
    {
        BusyNavBar()
        let message = Message(title: "Connecting to server...", backgroundColor: UIColor.orangeColor())
        Whisper(message,to: Settings.MainViewController ?? ez.topMostVC as! UINavigationController, action: .Present)
    }
    
    static func OnDisconnected()
    {
        BusyNavBar(true,speed: -0.1)
        let message = Message(title: "Disconnected from server.", backgroundColor: UIColor.redColor())
        Whisper(message,to: Settings.MainViewController ?? ez.topMostVC as! UINavigationController, action: .Present)

    }
    
    static func BusyNavBar(start: Bool=true, speed:Float=1){
        let options = BusyNavigationBarOptions()
        options.color = UIColor.redColor()
        options.speed = speed
        options.transparentMaskEnabled = true
        if let navController = Settings.MainViewController ?? ez.topMostVC as? UINavigationController {
            if(start){
                navController.navigationBar.start(options)
            }else{
                navController.navigationBar.stop()
            }
        }
    }
}