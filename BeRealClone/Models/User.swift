//
//  User.swift
//  BeRealClone
//
//  Created by Gokul P on 09/03/24.
//

import Foundation
import ParseSwift

struct User: ParseUser {
    var authData: [String : [String : String]?]?
    
    var originalData: Data?
    
    var objectId: String?
    
    var createdAt: Date?
    
    var updatedAt: Date?
    
    var ACL: ParseSwift.ParseACL?
    
    var username: String?
    var email: String?
    var emailVerified: Bool?
    var password: String?

    var age: Int?
}
