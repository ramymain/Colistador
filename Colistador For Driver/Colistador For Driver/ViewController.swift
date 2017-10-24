//
//  ViewController.swift
//  Colistador For Driver
//
//  Created by Ramy Ferjani on 31/05/2017.
//  Copyright © 2017 Ramy Ferjani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var txtLabel: UILabel!
    
    @IBOutlet weak var nameTxt: UITextField!

    @IBOutlet weak var lastNameTxt: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func displayFullName(sender: AnyObject) {
        var user = User();
        
        user.name = nameTxt.text!;
        user.lastName = lastNameTxt.text!;
        
        txtLabel.text = "\(user.fullName)";
    }

}

