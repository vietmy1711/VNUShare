//
//  Messages.swift
//  VNUShare
//
//  Created by nam on 7/7/20.
//  Copyright © 2020 MM. All rights reserved.
//

import Foundation

struct Messages {
    let id: String
    let user1: String
    let user2: String
    var content: [String]
    var sender: [String]
    var last: Double
    
    func getLastestMessage(_ user: String) -> String? {
        if content.isEmpty != true && sender.isEmpty != true {
            return "\(user): \(String(describing: content.last!))"
        }
        return nil
    }
}
