//
//  Socket.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/29/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import SocketIOClientSwift
import MapKit
import Kugel
import ObjectMapper
class Socket {
    static let url : String = "https://crt-server-ibicha.c9users.io/"
    static var IsConnectedToInternet = false
    static var socket = SocketIOClient(socketURL: NSURL(string: url)!, options: [.ForceNew(true)])
    static var LocationEventToken : KugelToken?
   
    static func Init(){
        Kugel.publish("OnConnecting")
        socket = SocketIOClient(socketURL: NSURL(string: url)!, options: [.ForceNew(true)])
        socket.on("connect") {data, ack in
            Kugel.publish("OnConnected")
            socket.emit("ios")
            IsConnectedToInternet = true;
            SendToken()
            socket.on("Members") {data, ack in
                if let members = data[0] as? NSArray {
                    for (_,member) in Members {
                        CrtMap.RemoveMemberMarker(member)
                    }
                    Members.removeAll()
                    for member in members {
                        if let mem = Mapper<CrtMember>().map(member) {
                            if !socket.sid!.contains(mem.id!) {
                                Members[mem.id!] = mem
                                CrtMap.UpdateMemberMarker(mem)
                            }
                        }
                    }
                }
            }
            
            socket.on("SharingOFF") {data, ack in
                if let theData = data[0] as? NSDictionary {
                    if let id = theData["id"] as? String {
                        if Members.has(id) && !socket.sid!.contains(id) {
                            CrtMap.RemoveMemberMarker(Members[id]!)
                            Members.removeValueForKey(id)
                        }
                    }
                }
            }
            
            socket.on("SharingON") {data, ack in
                if let member = data[0] as? NSDictionary {
                    if let mem = Mapper<CrtMember>().map(member) {
                        if  !socket.sid!.contains(mem.id!) {
                            if Members.has(mem.id!){
                                mem.marker = Members[mem.id!]!.marker
                            }
                            Members[mem.id!] = mem
                            CrtMap.UpdateMemberMarker(mem)
                        }
                    }
                }
            }
            socket.on("Accident") {data, ack in
                print("accident")
                if let accidentDict = data[0] as? NSDictionary {
                    if let accident = Mapper<CrtAccident>().map(accidentDict) {
                        if let oldAccident = Accidents[accident.id!] {
                            accident.marker = oldAccident.marker //Marker Reuse
                        }
                        Accidents[accident.id!] = accident
                        CrtMap.UpdateAccidentMarker(accident)
                        Kugel.publish("OnAccident",object: accident)
                    }
                }
            }
            socket.on("AccidentHandled") {data, ack in
                print("AccidentHandled")
                if let dataDict = data[0] as? NSDictionary {
                    if let accident = Accidents[dataDict["id"] as! String] {
                        accident.IsHandled = true
                        CrtMap.UpdateAccidentMarker(accident)
                    }
                }
            }
            socket.on("Message") {data, ack in
                if let messageDict = data[0] as? NSDictionary {
                    if let message = Mapper<CrtMessage>().map(messageDict) {
                        message.Save()
                        Kugel.publish("OnMessage", object: message)
                    }
                }
            }
            socket.on("Location") {data, ack in
                if let member = data[0] as? NSDictionary {
                    if let mem = Mapper<CrtMember>().map(member) {
                        if !socket.sid!.contains(mem.id!) {
                            if Members.has(mem.id!){
                                mem.marker = Members[mem.id!]!.marker
                            }
                            Members[mem.id!] = mem
                            CrtMap.UpdateMemberMarker(mem)
                        }
                    }
                }
            }
            socket.on("access_token") {data, ack in
                if UserSettings.autoShare {
                   Location.IsSharing = true
                }
                ShareLocation(Location.IsSharing);
            }
            
            socket.on("disconnect") {data, ack in
                print("disconnect")
                IsConnectedToInternet = false
                Kugel.publish("OnDisconnected")
                for (id,_) in Members {
                    CrtMap.RemoveMemberMarker(Members[id]!)
                    Members.removeValueForKey(id)
                }
            }
            socket.on("reconnect") {data, ack in
                print("reconnect")
                IsConnectedToInternet = false
                Kugel.publish("OnConnecting")
                for (id,_) in Members {
                    CrtMap.RemoveMemberMarker(Members[id]!)
                    Members.removeValueForKey(id)
                }
            }
        }
        socket.connect()
    }
    static func Reconnect(){
        ShareLocation(false)
        socket.disconnect()
        Init()
    }
    static func ShareLocation(share : Bool){
        if(share){
            socket.emit("SharingON", ["Location":Location.lastLocation.toJSON()])
            LocationEventToken = Kugel.subscribe("OnLocation", block: {notification in
                SendLocation()
            })
        }else{
            socket.emit("SharingOFF")
            if let token = LocationEventToken {
                Kugel.unsubscribeToken(token)
            }
        }
        Location.IsSharing = share
    }
    
    static func SendLocation(){
        if Location.IsSharing && Location.lastLocation.Timestamp != 0 {
            socket.emit("Location",["Location":Location.lastLocation.toJSON()])
        }
    }
    
    static func SendToken(){
        if WebService.Token != "" {
            socket.emit("access_token", WebService.Token);
        }
    }
}