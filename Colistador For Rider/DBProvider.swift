//
//  DBProvider.swift
//  Colistador For Driver
//
//  Created by Ramy Ferjani on 12/05/2017.
//  Copyright © 2017 Ramy Ferjani. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    private static let _instance = DBProvider();
    
    static var Instance: DBProvider {
        return _instance;
    }
    
    var dbRef : DatabaseReference! {
        return Database.database().reference();
    }
    
    var driversRef: DatabaseReference {
        return dbRef.child(Constants.DRIVERS);
    }
    
    var requestRef: DatabaseReference {
        return dbRef.child(Constants.DELIVERY_REQUEST);
    }
    
    var requestAcceptedRef: DatabaseReference {
        return dbRef.child(Constants.DELIVERY_ACCEPTED);
    }
    
    func saveUser(withID: String, email: String, password: String) {
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password];
        
        driversRef.child(withID).child(Constants.DATA).setValue(data);
    }
    
    
}
