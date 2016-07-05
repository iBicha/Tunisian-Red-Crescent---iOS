//
//  JsDateTransform.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/30/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import ObjectMapper
import EZSwiftExtensions

public class JsDateTransform: TransformType {
    public typealias Object = NSDate
    
    public typealias JSON = String
    
    public init() {}
    
    public func transformFromJSON(value: AnyObject?) -> NSDate? {
        if let date = value as? String {
            return NSDate(fromString: date , format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        }
        return nil
    }
    
    public func transformToJSON(value: NSDate?) -> String? {
        if let value = value {
            return value.toString(format: "yyyy/MM/dd HH:mm:ss")
        }
        return nil
    }
}
