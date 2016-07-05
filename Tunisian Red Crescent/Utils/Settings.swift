//
//  Settings.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/30/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import UIKit

class Settings {
    
    static var MainViewController:UINavigationController?
    static var MenuOptions = [
        ["name":"Profile" , "enabled": true],
        ["name":"Messages" , "enabled": false],
        ["name":"Report Accident" , "enabled": false],
        ["name":"Emergency Numbers" , "enabled": true],
        ["name":"Settings" , "enabled": true],
        ["name":"About" , "enabled": true]
    ]

    static func InitializeApp(){
        //Permissions
        Permissions.RequestBasic()
        //Notification System
        Notifications.Init()
        //Gps : ON
        Location.Start()
        //Connect to server
        Socket.Init()
        //Check if server is down
        WebService.ChechServer()
        //Check saved user settings
        CrtSettings.LoadSetting()
        //WebService.Authenticate silently
        //WebService.Authenticate("brahim", passwd: "123456", silent: true)

        WebService.GetCrtPlaces()

    }
    

}