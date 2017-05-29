//
//  LoginViewController.swift
//  Teender
//
//  Created by Obiet Panggrahito on 28/05/2017.
//  Copyright © 2017 Obiet Panggrahito. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    var ref: DatabaseReference!
    var age : String = ""
    var gender : String? = ""
    var work : String? = ""
    var ageRange : String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        setupFacebookLoginButton()
        if FBSDKAccessToken.current() != nil {
            directToHomeViewController()
        }
    }
    
    func setupFacebookLoginButton () {
        
        let facebookButton : FBSDKLoginButton = FBSDKLoginButton()
        facebookButton.center = self.view.center
        self.view.addSubview(facebookButton)
        
        facebookButton.readPermissions = ["public_profile", "email", "user_friends"]
        facebookButton.delegate = self
    }
    
    func directToHomeViewController () {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
            present(controller, animated: true, completion: nil)
        }
    }
    
    func saveUserDetails () {
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signIn(with: credential) { (user, error) in
            
            if let err = error {
                print("Facebook Loggin Error : \(err.localizedDescription)")
                return
            }
        
            self.ref.child("users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                let snapshot = snapshot.value as? NSDictionary
                
                if(snapshot == nil) {
                    
                    self.getAdditionalDetails()
                    
                    guard
                        let imageURL = user?.photoURL,
                        let email = user?.email,
                        let displayName = user?.displayName,
                        let work = self.work,
                        let gender = self.gender,
                        let ageRange = self.ageRange
                        else { return }
                    
                    let saveDetails : [String : Any] = ["imageURL" : imageURL, "email" : email, "username" : displayName, "work" : work, "gender" : gender, "age" : self.age, "ageRange" : ageRange]
                    self.ref.child("users").childByAutoId().updateChildValues(saveDetails)
                }
                
                self.directToHomeViewController()
            })
        }
    }
    
    func getAdditionalDetails () {
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "birthday, age_range, gender, work"]).start { (completion, result, err) in
            
            if err != nil {
                print("Failed the graph request")
                return
            }
            
            let dict = result as? [String : Any]
            
            self.gender = dict?["gender"] as? String
            self.work = dict?["work"] as? String
            self.ageRange = dict?["age_range"] as? String
            
            guard let birthday = dict?["birthday"] as? String
                else { return }
            
            self.convertBirthdayToAge(birthday: birthday)
        }
    }
    
    func yearsBetween(date1: Date, date2: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.year], from: date1, to: date2)
        return components.year ?? 0
    }
    
    func convertBirthdayToAge (birthday : String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date1 = dateFormatter.date(from: birthday)
        let date2 = Date()
        age = String(self.yearsBetween(date1:date1!, date2:date2))
    }
}

extension LoginViewController : FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error == nil {
            if (FBSDKAccessToken.current() == nil) {
                dismiss(animated: true, completion: nil)
            }
            else {
                saveUserDetails()
            }
        }
        else {
            print("SignIn Error : \(error.localizedDescription)")
            dismiss(animated: true, completion: nil)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User logged out")
    }
}
