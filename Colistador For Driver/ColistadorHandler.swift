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
    func acceptDelivery(shopLat: Double, shopLong: Double, deliveryLat: Double, deliveryLong: Double, address: String, addressShop: String, trackingNumber: String);
    func canceledDelivery();
    func deliveryCanceled();
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
    
    func observerMessagesForDriver() { //Fonction pour Firebase pour gérer différents évenements
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) {
            (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let shop_latitude = data[Constants.SHOP_LATITUDE] as? Double {
                    if let shop_longitude = data[Constants.SHOP_LONGITUDE] as? Double {
                        if let delivery_latitude = data[Constants.DELIVERY_LATITUDE] as? Double {
                            if let delivery_longitude = data[Constants.DELIVERY_LONGITUDE] as? Double {
                                if let address = data[Constants.ADDRESS] as? String {
                                    if let address_shop = data[Constants.ADDRESSSHOP] as? String {
                                    if let tracking_number = data[Constants.TRACKING_NUMBER] as? String {
                                self.delegate?.acceptDelivery(shopLat: shop_latitude, shopLong: shop_longitude, deliveryLat: delivery_latitude, deliveryLong: delivery_longitude, address: address, addressShop: address_shop, trackingNumber: tracking_number);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if let id = data[Constants.ID] as? String {
                    self.delivery_id = id;
                }
            }
            // CUSTOMER CANCELED DELIVERY
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved, with: { (snapshot: DataSnapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let id = data[Constants.ID] as? String {
                        if id == self.delivery_id {
                            self.delivery_id = "";
                            self.delegate?.canceledDelivery();
                        }
                    }
                }
            });
        }
        

        // DRIVER ACCEPTS DELIVERY
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.driver_id = snapshot.key;
                    }
                }
            }
        }
        
        // DRIVER CANCELD DELIVERY
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.delegate?.deliveryCanceled();
                    }
                }
            }
        }
    }
    
    func deliveryAccepted(lat: Double, long: Double, trackingNumber: String) { //Le livreur accepte la commande
        let data: Dictionary<String, Any> = [Constants.NAME: driver, Constants.LATITUDE: lat, Constants.LONGITUDE: long];
        
        DBProvider.Instance.requestAcceptedRef.child(trackingNumber).setValue(data);
    }
    
    func cancelDeliveryForDriver() { //Le livreur annule la commande
        DBProvider.Instance.requestAcceptedRef.child(driver_id).removeValue();
    }
    
    func updateDriverLocation(lat: Double, long: Double) { //Mettre a jour la localisation
        DBProvider.Instance.requestAcceptedRef.child(self.driver_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long]);
    }
}
