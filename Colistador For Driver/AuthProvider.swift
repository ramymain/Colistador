//
//  AuthProvider.swift
//  Colistador For Driver
//
//  Created by Ramy Ferjani on 12/05/2017.
//  Copyright © 2017 Ramy Ferjani. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias LoginHandler = (_ msg: String?) -> Void;

struct LoginErrorCode {
    static let INVALID_EMAIL = "Invalid Email Address";
    static let WRONG_PASSWORD = "Wrong Password";
    static let PROBLEM_CONNECTING = "Problem Connecting To Database";
    static let USER_NOT_FOUND = "User Not Found";
    static let EMAIL_ALREADY_IN_USE = "Email Already In Use";
    static let WEAK_PASSWORD = "Password Should Be At Least 6 Characters Long";
    
}

class AuthProvider { // Classe de type singleton
    private static let _instance = AuthProvider();
    
    static var Instance: AuthProvider {
        return _instance;
    }
    
    private var _uid = ""; //Variable uniqueID de l'utilisateur
    
    var uid : String {
        get {               //getter
            return _uid;
        }
    }
    
    func logIn(withEmail: String, password: String, loginHandler: LoginHandler?) { //Fonction permettant de se connecter
        
        Auth.auth().signIn(withEmail: withEmail, password: password) { (user, error) in //Utilise la fonction de connexion de Firebase
            
            if error != nil { //Si erreur appelle la fonction qui affiche le message d'erreur
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler)
            } else {
                loginHandler?(nil);
            }
        }
    }
    
    func signUp(withEmail: String, password: String, loginHandler: LoginHandler?) { //Fonction permettant de s'inscrire
        
        Auth.auth().createUser(withEmail: withEmail, password: password) { (user, error) in //Utilise la fonction d'inscription de Firebase
            
            if error != nil { //Si erreur appelle la fonction qui affiche le message d'erreur
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler);
            } else {
                if user?.uid != nil {
                    self._uid = user!.uid; // Stock l'uniqueID
                    DBProvider.Instance.saveUser(withID: user!.uid, email: withEmail, password: password);
                    self.logIn(withEmail: withEmail, password: password, loginHandler: loginHandler);
                }
            }
        }
    }
    
    func logOut() -> Bool {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut(); //Utilise la fonction de déconnexion de Firebase
                return true;
            } catch {
                return false;
            }
        }
        return true;
    }
    
    private func handleErrors(err: NSError, loginHandler: LoginHandler?) {
        
        if let errCode = AuthErrorCode(rawValue: err.code) { //Selon le type d'erreur affiche un message
            switch errCode {
            case .wrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD);
                break;
            case .invalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL);
                break;
            case .userNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND);
                break;
            case .emailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE);
                break;
            case .weakPassword:
                loginHandler?(LoginErrorCode.WEAK_PASSWORD);
                break;
            default:
                loginHandler?(LoginErrorCode.PROBLEM_CONNECTING);
                break;
            }
        }
    }
    
}
