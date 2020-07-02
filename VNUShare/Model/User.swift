//
//  User.swift
//  VNUShare
//
//  Created by MM on 6/19/20.
//  Copyright © 2020 MM. All rights reserved.
//

import Foundation

struct User: Codable {
    let uid: String
    let email: String
    let fullname: String
    let phonenumber: String
    let role: String
    var points: Int
}
