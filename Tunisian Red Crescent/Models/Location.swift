//
//  Location.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/29/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import MapKit
import ObjectMapper

class CrtLocation : Mappable {

    var Latitude: Double?
    var Longitude: Double?
    var Timestamp: NSDate?
    var Accuracy: Double?

    required init?(_ map: Map){
        
    }
    init(){
        
    }
    func mapping(map: Map) {
        Latitude <- map["Latitude"]
        Longitude <- map["Longitude"]
        Timestamp <- (map["Timestamp"], JsTimestampTransform())
        Accuracy <- map["Accuracy"]
    }
    
    func GetLocation2D() -> CLLocationCoordinate2D{
        return CLLocationCoordinate2D(
            latitude: (Latitude ?? 0) as CLLocationDegrees,
            longitude: (Longitude ?? 0) as CLLocationDegrees
        )
    }
    
}