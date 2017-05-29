//
//  MatchTableViewCell.swift
//  Teender
//
//  Created by Obiet Panggrahito on 29/05/2017.
//  Copyright © 2017 Obiet Panggrahito. All rights reserved.
//

import UIKit

class MatchTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView! {
        didSet {
            photoImageView.layer.cornerRadius = photoImageView.frame.width/2
            photoImageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    
    static let cellIdentifier = "MatchTableViewCell"
    static let cellNib = UINib(nibName: MatchTableViewCell.cellIdentifier, bundle: Bundle.main)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame = CGRect(x: 0, y: 0, width: 375, height: 100)
    }
}
