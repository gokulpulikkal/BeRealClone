//
//  Comment.swift
//  BeRealClone
//
//  Created by Gokul P on 18/03/24.
//

import Foundation
import ParseSwift

struct Comment: ParseObject, Codable {
    var originalData: Data?
    
    var objectId: String?
    
    var createdAt: Date?
    
    var updatedAt: Date?
    
    var ACL: ParseSwift.ParseACL?
    
    var userName: String?
    var text: String?
    var user: Pointer<User>?
    var post: Pointer<Post>?
    
}
