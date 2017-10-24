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
    
    var dbRef : DatabaseReference! { //Reference a la bdd
        return Database.database().reference();
    }
    
    var driversRef: DatabaseReference { //Reference a la table des drivers
        return dbRef.child(Constants.DRIVERS);
    }
    
    var requestRef: DatabaseReference { //Reference a la table des commandes en attentes
        return dbRef.child(Constants.DELIVERY_REQUEST);
    }
    
    var requestAcceptedRef: DatabaseReference { //Reference a la table des commandes acceptés
        return dbRef.child(Constants.DELIVERY_ACCEPTED);
    }
    
    func saveUser(withID: String, email: String, password: String) { //Fonction pour enregistrer un nouvel utilisateur
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password];
        
        driversRef.child(withID).child(Constants.DATA).setValue(data);
    }
    
    
}
