//
//  TrackingNumberVC.swift
//  Colistador For Customer
//
//  Created by Ramy Ferjani on 11/09/2017.
//  Copyright © 2017 Ramy Ferjani. All rights reserved.
//

import UIKit
import FirebaseDatabase

class TrackingNumberVC: UIViewController {
    
    private let MAP_SEGUE = "TrackingMapVC"
    
    @IBOutlet weak var trackingNumText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func Track(_ sender: Any) {
        if trackingNumText.text != "" {
            
            let ref = Database.database().reference();
            ref.child("Delivery_Accepted").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                
                if snapshot.hasChild(self.trackingNumText.text!){
                    ColistadorHandler.Instance.driver = self.trackingNumText.text!;
                    self.performSegue(withIdentifier: self.MAP_SEGUE, sender: nil);
                    
                } else {
                    self.alertUser(title: "Problem With Tracking Number", message: "Tracking Number Not Found");
                }
            })
        } else {
            self.alertUser(title: "Problem With Tracking Number", message: "Tracking Number Is Required");
        }
    }
    
    private func alertUser(title: String, message: String) { //Fonction qui alerte l'utilisateur en cas d'erreur
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }
    
}
