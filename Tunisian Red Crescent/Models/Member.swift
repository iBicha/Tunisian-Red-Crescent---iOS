//
//  Member.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 5/4/16.
//  Copyright © 2016 Esprit. All rights reserved.
//
import Foundation
import ObjectMapper
import Alamofire
import AlamofireImage
import Kugel

class CrtMember : Mappable{
    var id: String?
    var Location: CrtLocation?
    var marker: CustomPointAnnotation?
    required init?(_ map: Map){
        
    }
    
    init(){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        Location <- map["Location"]
    }
}
var Members = Dictionary<String,CrtMember>()