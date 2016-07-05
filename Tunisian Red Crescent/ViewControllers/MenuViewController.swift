//
//  MenuViewController.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 5/2/16.
//  Copyright © 2016 Esprit. All rights reserved.
//


import UIKit
import PermissionScope
import EZSwiftExtensions
import Kugel

final class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var shareSwitch: UISwitch!
    @IBOutlet weak var menuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.delegate = self
        menuTableView.dataSource = self
        Kugel.subscribe("OnUserInfo", block: {notification in
            self.SetProfileInfo()
            self.SetupShareSwitch()
        })
        Kugel.subscribe("OnUserImage", block: {notification in
            self.SetProfileInfo()
        })
        Kugel.subscribe("OnMessage", block: {notification in
            MenuViewController.SetMenuOptionEnabled("Messages", enabled: true)
            ez.runThisInMainThread({
                self.menuTableView.reloadData()
            })
        })
        if WebService.IsConnected {
            MenuViewController.SetMenuOptionEnabled("Messages", enabled: true)
        }
        SetProfileInfo()
        SetupShareSwitch()
    }
    func SetProfileInfo() {
        if CrtUser.Me.id != nil {
            nameLabel.text = CrtUser.Me.FirstName! + " " + CrtUser.Me.LastName!
            if let image = CrtUser.Me.ProfileImage {
                logo.image = image
                
                logo.layer.cornerRadius = logo.frame.size.width / 2
                logo.clipsToBounds = true
            }
        }
    }
    
    func SetupShareSwitch() {
        if CrtUser.Me.IsMember {
            shareView.hidden = false
            shareSwitch.on = Location.IsSharing
        }else{
            shareView.hidden = true
        }
    }
    
    static func GetCount() -> Int {
        var count = 0
        for opt in Settings.MenuOptions {
            if (opt["enabled"] as! Bool)  {
                count+=1
            }
        }
        return count;
    }
    static func SetMenuOptionEnabled(name:String, enabled:Bool) {
        for index in Settings.MenuOptions.count.range {
            if Settings.MenuOptions[index]["name"] == name {
                Settings.MenuOptions[index]["enabled"] = enabled
            }
        }
    }
    static func GetItemTitle(index: Int) -> String {
        var searchIndex = -1
        for opt in Settings.MenuOptions {
            if (opt["enabled"] as! Bool)  {
                searchIndex += 1
                if searchIndex == index {
                    return opt["name"] as! String
                }
            }
        }
        return ""
    }
  
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuViewController.GetCount()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell")! as! MenuCellView
        cell.title.text = MenuViewController.GetItemTitle(indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let option = MenuViewController.GetItemTitle(indexPath.row)
        switch option {
        case "Profile":
            if WebService.IsConnected && CrtUser.Me.id != nil{
                performSegueWithIdentifier("GoToProfile", sender: self)
            }else {
                performSegueWithIdentifier("GoToLogin", sender: self)
            }
            break
        case "Messages":
            performSegueWithIdentifier("GoToMessages", sender: self)
            break
        case "Report Accident":
            performSegueWithIdentifier("GoToReportAccident", sender: self)
            break
        case "Emergency Numbers":
            performSegueWithIdentifier("GoToCall", sender: self)
            break
        case "Settings":
            performSegueWithIdentifier("GoToSettings", sender: self)
            break
        case "About":
            performSegueWithIdentifier("GoToAbout", sender: self)
            break
        default: break
            
        }
    }
    
    @IBAction func onShareChanged(sender: AnyObject) {
        Socket.ShareLocation(shareSwitch.on)
    }
}