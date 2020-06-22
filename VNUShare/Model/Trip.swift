//
//  Trip.swift
//  VNUShare
//
//  Created by MM on 6/20/20.
//  Copyright © 2020 MM. All rights reserved.
//

import Foundation

struct Trip {
    let id: String
    let distance: Int
    let duration: Int
    let money: Int
    let originName: String
    let originAddress: String
    let originLatitude: Float
    let originLongitude: Float
    let destinationName: String
    let destinationAddress: String
    let destinationLatitude: Float
    let destinationLongitude: Float
    let customerName: String
    let customerPhoneNumber: String
    var status: String
}
