//
//  CustomArrays.swift
//  Teender
//
//  Created by Obiet Panggrahito on 29/05/2017.
//  Copyright © 2017 Obiet Panggrahito. All rights reserved.
//

import Foundation

class UserIDAndImage {
    
    var selectedUserID : String
    var imageURL : String
    
    init() {
        selectedUserID = ""
        imageURL = ""
    }
    
    init(aSelectedUserID: String, anImageURL: String) {
        selectedUserID = aSelectedUserID
        imageURL = anImageURL
    }
}

class Message {
    
    var text : String
    var timeCreated : String
    
    init() {
        text = ""
        timeCreated = ""
    }
    
    init(aText: String, aTimeCreated: String) {
        text = aText
        timeCreated = aTimeCreated
    }
}
