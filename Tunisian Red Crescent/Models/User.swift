//
//  User.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/29/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireImage
import Kugel

class CrtUser : Mappable{
    var id: String?
    var FirstName: String?
    var LastName: String?
    var Username: String?
    var Email: String?
    var BirthDate: String?
    var ImageFile: String?
    var IsAdmin = false
    var IsMember = false
    
    var Address: NSDictionary?
    
    var ProfileImage: UIImage?

    required init?(_ map: Map){
        
    }
    
    init(){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        FirstName <- map["FirstName"]
        LastName <- map["LastName"]
        Username <- map["Username"]
        Email <- map["Email"]
        BirthDate <- map["BirthDate"]
        ImageFile <- map["ImageFile"]
        IsAdmin <- map["IsAdmin"]
        IsMember <- map["IsMember"]
        Address <- map["Address"]
        
        if let imageUrl = ImageFile {
            Alamofire.request(.GET, imageUrl)
                .responseImage { response in
                    if let image = response.result.value {
                        self.ProfileImage = image
                        Kugel.publish("OnUserImage")
                    }
            }
        }
        
    }

    
    static var Me = CrtUser()
    
}