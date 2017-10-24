//
//  SignInVC.swift
//  Colistador For Driver
//
//  Created by Ramy Ferjani on 12/05/2017.
//  Copyright © 2017 Ramy Ferjani. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SignInVC: UIViewController {
    
    private let DRIVER_SEGUE = "DriverVC";

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logIn(_ sender: Any) { //Fonction de login
    
        if emailTextField.text! != "" && passwordTextField.text! != "" {
            
            AuthProvider.Instance.logIn(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertUser(title: "Problem With Authentification", message: message!);
                } else {
                    ColistadorHandler.Instance.driver = self.emailTextField.text!;
                    
                    self.emailTextField.text = "";
                    self.passwordTextField.text = "";
                    
                    self.performSegue(withIdentifier: self.DRIVER_SEGUE, sender: nil);
                }
            })
        } else {
            alertUser(title: "Email And Password Are Required", message: "Please enter email and password in the text fields");
        }
    
    }
    
    @IBAction func signUp(_ sender: Any) { //Fonction d'inscription
        if emailTextField.text! != "" && passwordTextField.text! != "" {
            AuthProvider.Instance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertUser(title: "Problem With Creating A New User", message: message!);
                } else {
                    ColistadorHandler.Instance.driver = self.emailTextField.text!;
                    
                    self.emailTextField.text = "";
                    self.passwordTextField.text = "";
                    
                    self.performSegue(withIdentifier: self.DRIVER_SEGUE, sender: nil);
                }
            })
        } else {
            alertUser(title: "Email And Password Are Required", message: "Please enter email and password in the text fields");
        }
    }
    
    private func alertUser(title: String, message: String) { //Fonction pour afficher les message d'erreur
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }

}
