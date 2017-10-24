//
//  User.swift
//  Colistador For Driver
//
//  Created by Ramy Ferjani on 31/05/2017.
//  Copyright © 2017 Ramy Ferjani. All rights reserved.
//

import Foundation

class User {
    private var _name = "Name";
    private var _lastName = "Last Name";
    
    var name: String {
        get {
            return _name;
        }
        set {
            _name = newValue;
        }
    }
    
    var lastName: String {
        get {
            return _lastName;
        }
        set {
            _lastName = newValue;
        }
    }
    
    var fullName: String {
        get {
            return "\(name) \(lastName)"
        }
    }
    
}
