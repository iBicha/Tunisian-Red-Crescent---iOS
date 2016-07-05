//
//  CallViewController.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 5/5/16.
//  Copyright © 2016 Esprit. All rights reserved.
//
import Foundation
import UIKit

final class CallViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var numbersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numbersTableView.delegate = self
        numbersTableView.dataSource = self

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Call.phoneNumbers.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhoneNumber")! as! PhoneCellView
        cell.title.text = Call.phoneNumbers[indexPath.row]["title"]
        cell.phoneNumber.text = Call.phoneNumbers[indexPath.row]["number"]
        cell.icon.image = UIImage(named: Call.phoneNumbers[indexPath.row]["picture"]!)
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        Call.CallNumber(Call.phoneNumbers[indexPath.row]["number"]!)
    }
    
}
