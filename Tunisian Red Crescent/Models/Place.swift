//
//  CrtPlace.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/29/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import ObjectMapper

class CrtPlace : Mappable {
    var id: String?
    var Title: String?
    var Location: CrtLocation?
    var PhoneNumber: String?
    var Address: NSDictionary?
    var marker: CustomPointAnnotation?

    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        Title <- map["Title"]
        Location <- map["Location"]
        PhoneNumber <- map["PhoneNumber"]
        Address <- map["Address"]
    }
}