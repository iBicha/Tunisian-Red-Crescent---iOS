//
//  RealmObject.swift
//  Tunisian Red Crescent
//
//  Created by Brahim Hadriche on 4/29/16.
//  Copyright © 2016 Esprit. All rights reserved.
//

import Foundation
import RealmSwift

class RealmObject : Object {
    
    /* 
    let realm = try! Realm()
    let messages = realm.objects(CrtMessage)
    */
    
    func Save() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(self, update: true)
            
        }
    }
    func Save(@noescape block: (() -> Void)) {
        let realm = try! Realm()
        try! realm.write (block)
    }
    func GetType() -> Any.Type {
        let anyMirror = Mirror(reflecting: self)
        return anyMirror.subjectType
    }
    
    func Delete() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self)
        }
    }
    
    static func UpdateAll(objects: [RealmObject]){
        let realm = try! Realm()
        try! realm.write {
            realm.add(objects, update: true)
        }
    }
    static func DropDatabase(){
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    
    static func DeleteFile(){
        do {
            try NSFileManager.defaultManager().removeItemAtURL(Realm.Configuration.defaultConfiguration.fileURL!)

        } catch {
            print("Could not delete realm file.")
        }
        
    }
}
 