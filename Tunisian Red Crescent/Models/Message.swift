//
//  Message.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/29/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

//
//  Message.swift
//  FlowingMenuExample
//
//  Created by Brahim Hadriche on 4/21/16.
//  Copyright © 2016 Yannick LORIOT. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import EZSwiftExtensions

class CrtMessage : RealmObject, Mappable{
    override class func primaryKey() -> String? {
        return "id"
    }
    dynamic var id: String?
    dynamic var Title: String?
    dynamic var SubmitDate: NSDate?
    dynamic var Description: String?
    dynamic var ImageFile: String?
    var Location: CrtLocation?
    dynamic var Seen:Bool = false
    
    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["id"]
        Title <- map["Title"]
        SubmitDate <- (map["SubmitDate"], JsDateTransform())
        ImageFile <- map["ImageFile"]
        Description <- map["Description"]
        Location <- map["Location"]
    }
 }