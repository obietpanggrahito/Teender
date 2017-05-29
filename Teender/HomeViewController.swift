//
//  HomeViewController.swift
//  Teender
//
//  Created by Obiet Panggrahito on 26/05/2017.
//  Copyright © 2017 Obiet Panggrahito. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var symbolImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nextPhotoImageView: UIImageView!
    @IBOutlet weak var coupleUsernameAndAgeLabel: UILabel!
    @IBOutlet weak var coupleWorkLabel: UILabel!
    
    @IBOutlet weak var dismissCoupleButton: UIButton! {
        didSet {
            dismissCoupleButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var photoView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(fetchCoupleDetail))
            photoView.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var profileButton: UIButton! {
        didSet {
                profileButton.addTarget(self, action: #selector(swipeToTheRight(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var chatButton: UIButton! {
        didSet {
                chatButton.addTarget(self, action: #selector(swipeToTheLeft(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var homeButton: UIButton! {
        didSet {
            homeButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var nopeButton: UIButton! {
        didSet {
            nopeButton.addTarget(self, action: #selector(nopeButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var likeButton: UIButton! {
        didSet {
            likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var superLikeButton: UIButton! {
        didSet {
            superLikeButton.addTarget(self, action: #selector(superLikeButtonTapped), for: .touchUpInside)
        }
    }
    
    var ref: DatabaseReference!
    var currentUserID = "JDHASKDHK38829D"
    
    var coupleAgeRange : [Int] = []
    var coupleImages : [UserIDAndImage] = []
    
    var indexInCoupleImage : Int = 0
    var nextIndexInCoupleImage : Int = 1
    
    var interestedIn : String = ""
    var selectedUserID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        setup()
    }
    
//MARK: SETUP
    
    func setup () {
     
        fetchCoupleAgeRange()
        setupProfileView()
        swipeGestureRecognizer()
    }
    
    func setupProfileView () {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            self.addChildViewController(controller)
            controller.currentUserID = currentUserID
            self.profileView.addSubview(controller.view)
        }
    }
    
    func setupMatchView () {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "MatchViewController") as? MatchViewController {
            self.addChildViewController(controller)
            controller.currentUserID = currentUserID
            self.chatView.addSubview(controller.view)
        }
    }
    
//MARK: PAN GESTURE
    
    @IBAction func panPhotoView(_ sender: UIPanGestureRecognizer) {
        let photoView = sender.view!
        let point = sender.translation(in: view)
        photoView.center = CGPoint(x: view.center.x + point.x, y: view.center.y - 68 + point.y)
        
        determiningTheSymbol()
        rotatingThePhoto()
        
        if sender.state == UIGestureRecognizerState.ended {
            determiningTheAction()
        }
    }
    
    func determiningTheSymbol () {
        let xFromCenter = photoView.center.x - view.center.x
        let yFromCenter = photoView.center.y - view.center.y
        
        if xFromCenter > 0 && -(yFromCenter) < abs(xFromCenter) {
            symbolImageView.image = UIImage(named: "like")
            symbolImageView.alpha = abs(xFromCenter) / view.center.x
        }
        else if xFromCenter < 0 && -(yFromCenter) < abs(xFromCenter) {
            symbolImageView.image = UIImage(named: "dislike")
            symbolImageView.alpha = abs(xFromCenter) / view.center.x
        }
        else if -(yFromCenter) > abs(xFromCenter) {
            symbolImageView.image = UIImage(named: "star (2)")
            symbolImageView.alpha = -(yFromCenter) / view.center.y
        }
    }
    
    func determiningTheAction () {
        
        if photoView.center.x < 50 {
            UIView.animate(withDuration: 0.4) {
                self.photoView.center = CGPoint(x: self.photoView.center.x - 500, y: self.photoView.center.y + 100)
                self.photoView.alpha = 0
                
                self.dislikeAction()
                self.nextImage()
            }
        }
                
        else if photoView.center.x > 325 {
            UIView.animate(withDuration: 0.4) {
                self.photoView.center = CGPoint(x: self.photoView.center.x + 500, y: self.photoView.center.y + 100)
                self.photoView.alpha = 0
                
                self.likeAction()
                self.nextImage()
            }
        }
                
        else if photoView.center.y < 100 {
            UIView.animate(withDuration: 0.4) {
                self.photoView.center = CGPoint(x: self.photoView.center.x, y: self.photoView.center.y + -1000)
                self.photoView.alpha = 0
                
                self.superLikeAction()
                self.nextImage()
            }
        }
        
        else {
            UIView.animate(withDuration: 0.4) {
                self.revertPhotoView()
            }
        }
    }
    
    func revertPhotoView () {
        
        self.photoView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 68)
        self.photoView.transform = CGAffineTransform.identity
        self.symbolImageView.alpha = 0
    }
    
    func rotatingThePhoto () {
        
        let xFromCenter = photoView.center.x - view.center.x
        let viewDivider : CGFloat = (view.frame.width/2) / 0.25
        photoView.transform = CGAffineTransform(rotationAngle: -(xFromCenter/viewDivider))
    }
    
    func nextImage () {
        
        revertPhotoView() // bug = reverting with animation although I didn't set any
        photoView.alpha = 1
        
        indexInCoupleImage = indexInCoupleImage + 1
        nextIndexInCoupleImage = nextIndexInCoupleImage + 1
        
        showImage()
    }
    
//MARK: TAP GESTURE
    
    func fetchCoupleDetail () {
        
        determiningSelectedUserID()
        ref.child("users").child(selectedUserID).child("profile").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? [String : Any]
            
            guard
                let username = dict?["username"] as? String,
                let work = dict?["work"] as? String,
                let age = dict?["age"] as? String
                else { return }
            
            self.coupleUsernameAndAgeLabel.text = "\(username), \(age)"
            self.coupleWorkLabel.text = work
            
            self.animation()
        })
    }
    
    func animation () {
        
        //Deactivate UIPanGestureRecognizer
        UIView.animate(withDuration: 0.4) { 
            
            self.photoImageView.frame = CGRect(x: 0, y: -50, width: 375, height: 480)
            
            self.chatButton.frame.origin.x = 475
            self.profileButton.frame.origin.x = -100
            
            self.homeButton.frame.origin.y = -100
            self.dismissCoupleButton.frame.origin.y = 25
            self.coupleUsernameAndAgeLabel.frame.origin.y = 515
            self.coupleWorkLabel.frame.origin.y = 540
        }
    }
    
    func dismissButtonTapped () {
        
        UIView.animate(withDuration: 0.4) { 
    
            self.dismissCoupleButton.frame.origin.y = -150
            self.coupleUsernameAndAgeLabel.frame.origin.y = 700
            self.coupleWorkLabel.frame.origin.y = 740
            self.photoImageView.frame = CGRect(x: 0, y: 0, width: 375, height: 533)
        }
        
        navigationBarRevert()
    }
    
//MARK: SWIPE GESTURE
    
    func swipeGestureRecognizer () {
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeToTheLeft(_ :)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeToTheRight(_ :)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @IBAction func swipeToTheLeft(_ sender: Any) {
        
        switch chatView.frame {
            
        case CGRect(x: 375.0, y: 70.0, width: 375.0, height: 597.0) :
           
            UIView.animate(withDuration: 0.4, animations: {
                
                self.chatView.frame = CGRect(x: 0.0, y: 70.0, width: 375.0, height: 597.0)
                self.homeView.frame = CGRect(x: -375.0, y: 70.0, width: 375.0, height: 597.0)
                self.profileView.frame = CGRect(x: -750.0, y: 70.0, width: 375.0, height: 597.0)
            })
            
            swipeToTheLeftNavigationBarTransformation()
            setupMatchView() // bug = it won't swipe at the first time because of tableView.reloadData()
            
        case CGRect(x: 750.0, y: 70.0, width: 375.0, height: 597.0) :
            
            revertFrames()
            navigationBarRevert()
            
        default:
            break
        }
    }
    
    @IBAction func swipeToTheRight(_ sender: Any) {
        
        switch profileView.frame {
            
        case CGRect(x: -375.0, y: 70.0, width: 375.0, height: 597.0) :
            
            UIView.animate(withDuration: 0.4, animations: {
                
                self.profileView.frame = CGRect(x: 0.0, y: 70.0, width: 375.0, height: 597.0)
                self.homeView.frame = CGRect(x: 375.0, y: 70.0, width: 375.0, height: 597.0)
                self.chatView.frame = CGRect(x: 750.0, y: 70.0, width: 375.0, height: 597.0)
            })
            
            swipeToTheRightNavigationBarTransformation()
            
        case CGRect(x: -750.0, y: 70.0, width: 375.0, height: 597.0) :
            
            revertFrames()
            navigationBarRevert()
            
        default:
            break
        }
    }
    
    func revertFrames () {
        
        UIView.animate(withDuration: 0.4, animations: {
            self.chatView.frame = CGRect(x: 375.0, y: 70.0, width: 375.0, height: 597.0)
            self.homeView.frame = CGRect(x: 0.0, y: 70.0, width: 375.0, height: 597.0)
            self.profileView.frame = CGRect(x: -375.0, y: 70.0, width: 375.0, height: 597.0)
        })
    }
    
//MARK: FETCHING DATA FROM FIREBASE
    
    func fetchCoupleAgeRange () {
        
        ref.child("users").child(currentUserID).child("coupleAgeRange").observe(.value, with: { (snapshot) in
            
            guard let range = snapshot.value as? String
                else { return }
            
            let rangeArray : [String] = range.components(separatedBy: " - ")
            
            guard
                let min = Int(rangeArray.first!),
                let max = Int(rangeArray.last!)
            else { return }
            
            self.coupleAgeRange = Array(min...max)
            self.fetchInterest()
        })
    }

    func fetchInterest () {
     
        ref.child("users").child(currentUserID).child("gender").observe(.value, with: { (snapshot) in
          
            if String(describing: snapshot.value!) == "male" {
                self.interestedIn = "female"
            }
            else {
                self.interestedIn = "male"
            }
            
            self.fetchImages()
        })
    }
    
    func fetchImages () {
        
        for each in coupleAgeRange {
            let age = String(each)
                
            self.ref.child("imageURLs").child(interestedIn).child(age).observe(.childAdded, with: { (snapshot) in
                
                let selectedUserID = snapshot.key
                
                guard
                    let imageURL = snapshot.value as? String
                    else { return }
                
                let data = UserIDAndImage(aSelectedUserID: selectedUserID, anImageURL: imageURL)
                self.coupleImages.append(data)
                
                if self.coupleImages.count >= 2 { // just an idiotic code to avoid unwrapped nil
                    self.showImage()
                }
            })
        }
    }
    
    func showImage () {
        
        if indexInCoupleImage == coupleImages.count {
            indexInCoupleImage = 0
        }
        
        let currentImage = (coupleImages[indexInCoupleImage]).imageURL
        self.photoImageView.loadImageUsingCacheWithUrlString(urlString: currentImage)
        
        if nextIndexInCoupleImage == coupleImages.count {
            nextIndexInCoupleImage = 0
        }
        
        let nextImage = (coupleImages[nextIndexInCoupleImage]).imageURL
        self.nextPhotoImageView.loadImageUsingCacheWithUrlString(urlString: nextImage)
    }

//MARK: SENDING DATA TO FIREBASE
    
    func determiningSelectedUserID () {
        
        selectedUserID = (coupleImages[indexInCoupleImage]).selectedUserID
    }
    
    func likeAction () {
        
        determiningSelectedUserID()
        let like : [String : String] = [currentUserID : "like"]
        ref.child("users").child(selectedUserID).child("likes").updateChildValues(like)
    }
    
    func dislikeAction () {
        
        determiningSelectedUserID()
        ref.child("users").child(selectedUserID).child("likes").child(currentUserID).removeValue()
        ref.child("users").child(selectedUserID).child("matches").child(currentUserID).removeValue()
        ref.child("users").child(currentUserID).child("matches").child(selectedUserID).removeValue()
    }

    func superLikeAction () {
        
        determiningSelectedUserID()
        let superLike : [String : String] = [currentUserID : "superLike"]
        ref.child("users").child(selectedUserID).child("likes").updateChildValues(superLike)
    }
    
//MARK: BUTTONS AT THE TOP (NAVIGATION BAR)
    
    func swipeToTheLeftNavigationBarTransformation () {
       
        UIView.animate(withDuration: 0.4) {
            
            self.chatButton.frame.origin.x = 167.5
            self.profileButton.frame.origin.x = -100
            self.homeButton.frame.origin.x = 16
            }
        }
    
    func swipeToTheRightNavigationBarTransformation () {
        
        UIView.animate(withDuration: 0.4) { 
            
            self.profileButton.frame.origin.x = 167.5
            self.chatButton.frame.origin.x = 475
            self.homeButton.frame.origin.x = 375 - 16 - 40
        }
    }
    
    func homeButtonTapped () {
        revertFrames()
        navigationBarRevert()
    }
    
    func navigationBarRevert () {
        
        UIView.animate(withDuration: 0.4) { 
            self.homeButton.frame.origin.x = 167.5
            self.homeButton.frame.origin.y = 25
            self.chatButton.frame.origin.x = 375 - 16 - 40
            self.profileButton.frame.origin.x = 16
        }
    }
    
//MARK: BUTTONS AT THE BOTTOM
    
    func nopeButtonTapped () {
        
        photoView.center.x = 49
        determiningTheAction()
    }
    
    func likeButtonTapped () {
        
        photoView.center.x = 326
        determiningTheAction()
    }
    
    func superLikeButtonTapped () {
        
        photoView.center.y = 99
        determiningTheAction()
    }

}

