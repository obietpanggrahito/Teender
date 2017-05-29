//
//  MatchViewController.swift
//  Teender
//
//  Created by Obiet Panggrahito on 27/05/2017.
//  Copyright © 2017 Obiet Panggrahito. All rights reserved.
//

import UIKit
import Firebase

class MatchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.register(MatchTableViewCell.cellNib, forCellReuseIdentifier: MatchTableViewCell.cellIdentifier)
        }
    }
    
    var ref: DatabaseReference!
    var currentUserID = ""
    
    var peopleWhoLikedMe : [String] = []
    var peopleWhoILikedBack : [String] = []
    var coupleIDs : [String] = []
    
    var coupleUsername : String = ""
    var coupleImageURL : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        checkWhoLikedMe()
    }
    
    func checkWhoLikedMe () {
        
        ref.child("users").child(currentUserID).child("likes").observe(.value, with: { (snapshot) in
            for (key, _) in snapshot.value as! [String : String] {
             
                self.peopleWhoLikedMe.append(key)
                if self.peopleWhoLikedMe.count == Int(snapshot.childrenCount) {
                    self.checkIfILikedThem()
                }
            }
        })
    }
    
    func checkIfILikedThem () {
        
        for each in peopleWhoLikedMe {
            ref.child("users").child(each).child("likes").observe(.value, with: { (snapshot) in
                
                if snapshot.hasChild(self.currentUserID) {
                    
                    self.peopleWhoILikedBack.append(each)
                    self.reloadData(coupleID: each)
                }
            })
        }
    }
    
    func reloadData (coupleID : String) {
        
        coupleIDs.append(coupleID)
        if coupleIDs.count == peopleWhoILikedBack.count {
            tableView.reloadData()
        }
    }
    
    func fetchCouplesDetails (cell : MatchTableViewCell) {
        
        for each in coupleIDs {
            ref.child("users").child(each).child("profile").observe(.value, with: { (snapshot) in
                let dict = snapshot.value as? [String : Any]
                
                guard
                    let username = dict?["username"] as? String,
                    let work = dict?["work"] as? String,
                    let imageURL = dict?["imageURL"] as? String
                    else { return }
                
                self.coupleUsername = username
                self.coupleImageURL = imageURL
                
                cell.usernameLabel.text = username
                cell.workLabel.text = work
                cell.photoImageView.loadImageUsingCacheWithUrlString(urlString: imageURL)
            })
        }
    }
    
    func presentChatViewController (indexPath : IndexPath) {
     
        let selectedUserID = coupleIDs[indexPath.row]
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            
            controller.selectedUserID = selectedUserID
            controller.currentUserID = currentUserID
            controller.coupleUsername = coupleUsername
            controller.coupleImageURL = coupleImageURL
            
            present(controller, animated: true, completion: nil)
        }
    }
}

extension MatchViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coupleIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MatchTableViewCell.cellIdentifier) as? MatchTableViewCell
            else { return UITableViewCell() }
        
        fetchCouplesDetails(cell: cell)
        return cell
    }
}

extension MatchViewController : UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentChatViewController(indexPath: indexPath)
    }
}
