//
//  ProfileViewController.swift
//  Teender
//
//  Created by Obiet Panggrahito on 27/05/2017.
//  Copyright © 2017 Obiet Panggrahito. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var nameAndAgeLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = imageView.frame.width/2
            imageView.layer.masksToBounds = true
            
        }
    }

    @IBOutlet weak var settingButton: UIButton! {
        didSet {
            settingButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var editButton: UIButton! {
        didSet {
            editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        }
    }
    
    var ref: DatabaseReference!
    var currentUserID = ""
    
    var username : String = ""
    var work : String = ""
    var imageURL : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        setupProfile()
    }
    
    func setupProfile () {
        
        ref.child("users").child(currentUserID).child("profile").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? [String : Any]
            
            guard
            let username = dict?["username"] as? String,
            let work = dict?["work"] as? String,
            let imageURL = dict?["imageURL"] as? String,
            let age = dict?["age"] as? String
                else { return }
            
            self.username = username
            self.work = work
            self.imageURL = imageURL
            
            self.nameAndAgeLabel.text = "\(username), \(age)"
            self.workLabel.text = work
            self.imageView.loadImageUsingCacheWithUrlString(urlString: imageURL)
        })
    }

    func settingButtonTapped () {
        
    }
    
    func editButtonTapped () {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "EditViewController") as? EditViewController {
            
            controller.currentUserID = currentUserID
            controller.username = username
            controller.work = work
            controller.imageURL = imageURL
            
            present(controller, animated: true, completion: nil)
        }
    }
}
