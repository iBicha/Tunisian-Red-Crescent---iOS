//
//  SettingsViewController.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 5/11/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import UIKit
import SwiftyButton
import Kugel
import RealmSwift
final class SettingsViewController : UIViewController{

    @IBOutlet weak var autoConnect: UISwitch!
    @IBOutlet weak var autoShare: UISwitch!
    @IBOutlet weak var requestMembership: SwiftyButton!
    @IBOutlet weak var requestAdminship: SwiftyButton!
    @IBOutlet weak var logout: SwiftyButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoConnect.on = UserSettings.autoConnect
        autoShare.on = UserSettings.autoShare
        
        Kugel.subscribe("OnUserInfo", block: {notification in
            self.SetButtonsVisible()
        })
        SetButtonsVisible()
    }

    func SetButtonsVisible() {
        requestAdminship.hidden = !WebService.IsConnected
        requestMembership.hidden = !WebService.IsConnected
        logout.hidden = !WebService.IsConnected
    }
    
    @IBAction func onAutoConnectToggle(sender: AnyObject) {
        UserSettings.Save {
            UserSettings.autoConnect = autoConnect.on
        }
    }

    @IBAction func onAutoShareToggle(sender: AnyObject) {
        UserSettings.Save {
            UserSettings.autoShare = autoShare.on
        }
    }

    @IBAction func onMembershipClicked(sender: AnyObject) {
        WebService.RequestMembership()
    }
    
    @IBAction func onAdminshipClicked(sender: AnyObject) {
        WebService.RequestAdminship()
    }
    
    @IBAction func onLogoutClicked(sender: AnyObject) {
        //clean messages
        let realm = try! Realm()
        let messages = realm.objects(CrtMessage)
        try! realm.write{
            realm.delete(messages)
        }
        MenuViewController.SetMenuOptionEnabled("Messages", enabled: false)
        //clean accidents
        for (_,accident) in Accidents {
            CrtMap.RemoveAccidentMarker(accident)
        }
        Accidents.removeAll()
        //Reset User
        CrtUser.Me = CrtUser()
        //Logout
        WebService.Logout()
        popVC()
    }

}