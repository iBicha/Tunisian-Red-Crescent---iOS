//
//  Accident.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/29/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireImage

class CrtAccident : Mappable {
    var id: String?
    var Description: String?
    var ImageFile: String?
    var IsHandled: Bool = false
    var Location: CrtLocation?
    var marker: CustomPointAnnotation?
    
    var Image: UIImage?

    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        Description <- map["Description"]
        ImageFile <- map["ImageFile"]
        Location <- map["Location"]
        IsHandled <- map["IsHandled"]
        
        if let imageUrl = ImageFile {
            Alamofire.request(.GET, imageUrl)
                .responseImage { response in
                    if let image = response.result.value {
                        self.Image = image
                    }
            }
        }
    }
}

var Accidents = Dictionary<String,CrtAccident>()