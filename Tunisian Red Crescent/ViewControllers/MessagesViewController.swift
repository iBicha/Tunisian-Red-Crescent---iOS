//
//  MessagesViewController.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 5/4/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import UIKit
import Kugel
import RealmSwift
import EZSwiftExtensions
final class MessagesViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var messagesTableView: UITableView!
    
    var messages : Results<CrtMessage>?
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesTableView.delegate = self
        messagesTableView.dataSource = self

        Kugel.subscribe("OnMessage", block: {notification in
            self.ReloadMessages()
        })
        
        ReloadMessages()
    }
    func ReloadMessages() {
        let realm = try! Realm()
        messages = realm.objects(CrtMessage).sorted("SubmitDate", ascending: false)
        messagesTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages != nil {
            return messages!.count
        }
        return 0
    }
    var selectedIndex = -1
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCellView
        if messages != nil {
            let message = messages![indexPath.row] as CrtMessage
            cell.title.text = message.Title
            cell.desc.text = message.Description
            cell.time.text = message.SubmitDate?.timePassed()
            if !message.Seen {
                cell.title.font = UIFont.boldSystemFontOfSize(22)
                cell.desc.font = UIFont.boldSystemFontOfSize(15)
                cell.time.font = UIFont.boldSystemFontOfSize(19)
            }else{
                cell.title.font = UIFont.systemFontOfSize(20)
                cell.desc.font = UIFont.systemFontOfSize(15)
                cell.time.font = UIFont.systemFontOfSize(17)
            }
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("GoToMessageDetail", sender: self)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "GoToMessageDetail") {
            let viewController = segue.destinationViewController as! MessageViewController
            viewController.message = messages![selectedIndex]
        }
    }
}