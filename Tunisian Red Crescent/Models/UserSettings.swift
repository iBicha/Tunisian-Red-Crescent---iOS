//
//  CrtSettings.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 5/6/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
class CrtSettings : RealmObject {
    override class func primaryKey() -> String? {
        return "id"
    }
    dynamic var id = "Settings"
    dynamic var username = ""
    dynamic var password = ""
    dynamic var rememberMe = false
    dynamic var autoConnect = false
    dynamic var autoShare = false
    
    static func LoadSetting() {
        let realm = try! Realm()
        if let s = realm.objectForPrimaryKey(CrtSettings.self, key: "Settings"){
            UserSettings = s
        }else{
            UserSettings.Save()
        }
    }
}

var UserSettings = CrtSettings()