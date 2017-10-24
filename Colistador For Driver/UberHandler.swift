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
    func acceptColistador(lat: Double, long: Double);
}

class ColistadorHandler {
    private static let _instance = ColistadorHandler();
    
    weak var delegate: ColistadorController?;
    
    var driver = "";
    var driver_id = "";
    
    static var Instance: ColistadorHandler {
        return _instance;
    }
    
    func observerMessagesForDriver() {
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) {
            (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        self.delegate?.acceptColistador(lat: latitude, long: longitude);
                    }
                }
            }
        }
    }
}
