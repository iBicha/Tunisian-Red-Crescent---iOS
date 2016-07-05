//
//  UserLocatioin.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/30/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import MapKit
import EZSwiftExtensions
import Kugel
import PermissionScope

class UserLocation: NSObject, CLLocationManagerDelegate {
    
    var IsSharing = false
    
    var locationManager = CLLocationManager()
    
    var lastLocation = CrtLocation()
    
    class var manager: UserLocation {
        return Location
    }
    
    override init () {
        super.init()
      
    }
    
    func Start() {
        let pscope = PermissionScope()
        pscope.addPermission(LocationAlwaysPermission(),message: "Please allow location settings to use the map.")
        pscope.show({ finished, results in
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
        }, cancelled: { (results) -> Void in

        })
    }
    
    func  Stop() {
        self.locationManager.stopUpdatingLocation()
    }
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        lastLocation.Latitude = newLocation.coordinate.latitude
        lastLocation.Longitude = newLocation.coordinate.longitude
        lastLocation.Timestamp = newLocation.timestamp
        lastLocation.Accuracy = newLocation.horizontalAccuracy
        Kugel.publish("OnLocation", object: self.lastLocation)
        //TODO: do this only once.
        MenuViewController.SetMenuOptionEnabled("Report Accident", enabled: true)

    }
}

let Location = UserLocation()
