//
//  Call.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/30/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import UIKit

class Call {
    static let phoneNumbers = [
        ["title": "Police","number": "197","picture": "police.png"],
        ["title": "Civil Protection","number": "198","picture": "fire.png"],
        ["title": "Ambulance","number" : "190","picture" : "ambulance.png"],
        ["title": "Poison control center","number" : "71335500","picture" : "poison.png"],
        ["title": "Tunisian Red Crescent","number" : "71320630","picture" : "badge.png"]
    ]
    
    
    static func CallNumber(number:String){
        //UIApplication.sharedApplication().openURL(NSURL(string:"tel:0123456789"))
        UIApplication.sharedApplication().openURL(NSURL(string: "telprompt:" + number)!)
    }
}