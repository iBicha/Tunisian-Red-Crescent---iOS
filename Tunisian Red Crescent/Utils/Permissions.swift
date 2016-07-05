//
//  Permissions.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 5/2/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import PermissionScope

class Permissions {
    static func RequestBasic(){
        let pscope = PermissionScope()
        pscope.addPermission(LocationAlwaysPermission(),message: "Please allow location settings to use the map.")
        pscope.addPermission(NotificationsPermission(),message: "Please allow notifications to notify you when messages arrive.")
        
        pscope.show({ finished, results in
            
            }, cancelled: { (results) -> Void in
                
        })
    }
   }