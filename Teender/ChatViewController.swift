//
//  ChatViewController.swift
//  Teender
//
//  Created by Obiet Panggrahito on 27/05/2017.
//  Copyright © 2017 Obiet Panggrahito. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = imageView.frame.width/2
            imageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var sendButton: UIButton! {
        didSet {
            sendButton.addTarget(self, action: #selector(getTimeCreated), for: .touchUpInside)
        }
    }
    
    var ref: DatabaseReference!
    var messages : [Message] = []
    
    var currentUserID : String = ""
    var selectedUserID : String = ""
    var coupleUsername : String = ""
    var coupleImageURL : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        setup()
        fetchMessages()
    }
    
    func setup () {
        
        nameLabel.text = coupleUsername
        imageView.loadImageUsingCacheWithUrlString(urlString: coupleImageURL)
    }
    
    func fetchMessages () {
        
        ref.child("users").child(currentUserID).child("matches").child(selectedUserID).observe(.value, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String : String]
                else { return }
            
            for (key , value) in dict {
                
                let message = Message(aText: value, aTimeCreated: key)
                
                if self.messages.count <= Int(snapshot.childrenCount) {
                self.messages.append(message)
                self.tableView.reloadData()
                }
            }
        })
    }

    func backButtonTapped () {
        dismiss(animated: true, completion: nil) // bug : not going back to the MatchViewController
    }
    
    func getTimeCreated () {
        
        let currentDate = NSDate()
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy, HH:mm:ss"
        let timeCreated = dateFormatter.string(from: currentDate as Date)
        
        sendDataToFirebase(timeCreated: timeCreated)
    }
    
    func sendDataToFirebase (timeCreated : String) {
        
        guard
            let text = messageTextField.text
            else { return }
        
        let aMessage : [String : String] = [timeCreated : text]
        ref.child("users").child(currentUserID).child("matches").child(selectedUserID).updateChildValues(aMessage)
        ref.child("users").child(selectedUserID).child("matches").child(currentUserID).updateChildValues(aMessage)
        
        messages.removeAll()
        tableView.reloadData()
        messageTextField.text = ""
    }
    
    func showMessages (indexPath : IndexPath, cell: UITableViewCell) {
    
        messages.sort(by: { (firstMessage, secondMessage) -> Bool in
            return firstMessage.timeCreated < secondMessage.timeCreated
        })
        
        let currentMessage = messages[indexPath.row]
        cell.textLabel?.text = currentMessage.text
    }
}

extension ChatViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       guard let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell")
            else { return UITableViewCell() }
        
        showMessages(indexPath: indexPath, cell: cell)
        return cell
    }
}
