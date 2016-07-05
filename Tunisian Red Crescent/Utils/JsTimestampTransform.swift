//
//  JsTimestampTransform.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 5/7/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import ObjectMapper
import EZSwiftExtensions

public class JsTimestampTransform: TransformType {
    public typealias Object = NSDate
    
    public typealias JSON = String
    
    public init() {}
    
    public func transformFromJSON(value: AnyObject?) -> NSDate? {
        if let date = value as? String {
            return NSDate(timeIntervalSince1970: Double(date)!/1000)
        }
        if let date = value as? Int64 {
            return NSDate(timeIntervalSince1970: Double(date)/1000)
        }
        if let date = value as? Double {
            return NSDate(timeIntervalSince1970: date/1000)
        }
        if let date = value as? Int {
            return NSDate(timeIntervalSince1970: Double(date)/1000)
        }
        return nil
    }
    
    public func transformToJSON(value: NSDate?) -> String? {
        if let value = value {
            return String(Int64(value.timeIntervalSince1970 * 1000))
        }
        return nil
    }
}
