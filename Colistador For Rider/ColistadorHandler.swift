//
//  ColistadorHandler.swift
//  Colistador For Driver
//
//  Created by Ramy Ferjani on 26/06/2017.
//  Copyright © 2017 Ramy Ferjani. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol ColistadorController: class {
    func updateDriversLocation(lat: Double, long: Double);
}

class ColistadorHandler {
    private static let _instance = ColistadorHandler();
    
    weak var delegate: ColistadorController?;
    
    var delivery_id = "";
    var driver = "";
    var driver_id = "";
    
    static var Instance: ColistadorHandler {
        return _instance;
    }
    
    func observerMessagesForDriver() {
        //PACKAGE UPDATING LOCATION
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let lat = data[Constants.LATITUDE] as? Double {
                    if let long = data[Constants.LONGITUDE] as? Double {
                        self.delegate?.updateDriversLocation(lat: lat, long: long);
                    }
                }
            }
        }
    }
}
