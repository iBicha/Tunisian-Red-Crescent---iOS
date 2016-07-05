//
//  Map.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/30/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import MapKit
class CrtMap {
    static var MapView : MKMapView?
    static var userMarker : CustomPointAnnotation!

    static func UpdateUserMarker(){
        if let map = MapView {
            if userMarker == nil {
                userMarker = CustomPointAnnotation()
                userMarker.coordinate = Location.lastLocation.GetLocation2D()
                userMarker.title = "Me"
                userMarker.imageName = R.image.male_shadow.name
                map.addAnnotation(userMarker)
                ZoomPan(Location.lastLocation)
            }
            userMarker.coordinate = Location.lastLocation.GetLocation2D()
        }
    }
    static func ZoomPan(location : CrtLocation, ForceZoom:Bool = false){
        if let map = MapView {
            let center = location.GetLocation2D()
            if center.latitude != 0 && center.longitude != 0 {
                let coordinateSpan = MKCoordinateSpan(latitudeDelta: min(map.region.span.latitudeDelta, 0.03) , longitudeDelta: min(map.region.span.longitudeDelta, 0.03) )
                let region = MKCoordinateRegion(center: center, span: coordinateSpan)
                map.setRegion(region, animated: true)
            }
        }
    }
    static func UpdateMemberMarker(member : CrtMember){
        if let map = MapView {
            if member.marker == nil {
                member.marker = CustomPointAnnotation()
                member.marker!.coordinate = member.Location!.GetLocation2D()
                member.marker!.title = "Member"
                member.marker!.imageName = R.image.member_shadow.name
                map.addAnnotation(member.marker!)
            }
            member.marker!.coordinate = member.Location!.GetLocation2D()
        }
    }
    
    static func RemoveMemberMarker(member : CrtMember){
        if let map = MapView {
            if member.marker != nil {
                map.removeAnnotation(member.marker!)
            }
        }
    }
    
    static func UpdateAccidentMarker(accident : CrtAccident, recreateCircle: Bool = false){
        if let map = MapView {
            if accident.marker == nil {
                let annotation = CustomPointAnnotation()
                annotation.title = accident.Description
                annotation.coordinate = accident.Location!.GetLocation2D()
                if accident.IsHandled {
                    annotation.imageName = "accidentOk.png"
                }else{
                    annotation.imageName = "accident.png"
                    annotation.useCicle = true
                }
                annotation.accident = accident
                map.addAnnotation(annotation)
                accident.marker = annotation
            }else{
                accident.marker!.coordinate = accident.Location!.GetLocation2D()
                if accident.IsHandled {
                    accident.marker!.AnimateCicle(false)
                    accident.marker!.SetMarkerImage("accidentOk.png")
                }else{
                    accident.marker!.SetMarkerImage("accident.png")
                    accident.marker!.AnimateCicle(true, recreateCircle: recreateCircle)
                }
            }
        }
    }
    static func RemoveAccidentMarker(accident : CrtAccident){
        if let map = MapView {
            if accident.marker != nil {
                accident.marker?.AnimateCicle(false, recreateCircle: false)
                map.removeAnnotation(accident.marker!)
            }
        }
    }

    static func SetCrtPlaceMarker(crtPlace : CrtPlace){
        if let map = MapView {
            let annotation = CustomPointAnnotation()
            annotation.coordinate = crtPlace.Location!.GetLocation2D()
            annotation.title = crtPlace.Title
            annotation.imageName = R.image.crtPlace.name
            map.addAnnotation(annotation)
        }
        
    }
}