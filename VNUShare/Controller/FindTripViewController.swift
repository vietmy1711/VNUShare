//
//  FindTripViewController.swift
//  VNUShare
//
//  Created by MM on 6/20/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import Firebase

class FindTripViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    var trips: [Trip] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTrips()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
    }
    
    func getTrips() {
        db.collection("trips").whereField("status", isEqualTo: "waiting")
        .addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.trips.removeAll()
            for document in documents {
                let distanceNS: NSNumber = document.get("distance") as! NSNumber
                let distance = distanceNS.intValue
                let moneyNS: NSNumber = document.get("money") as! NSNumber
                let money = moneyNS.intValue
                let originName: String = document.get("originName") as! String
                let originAddress: String = document.get("originAddress") as! String
                let originLatitudeNS: NSNumber = document.get("originLatitude") as! NSNumber
                let originLatitude = originLatitudeNS.floatValue
                let originLongitudeNS: NSNumber = document.get("originLongitude") as! NSNumber
                let originLongitude = originLongitudeNS.floatValue
                let destinationName: String = document.get("destinationName") as! String
                let destinationAddress: String = document.get("destinationAddress") as! String
                let destinationLatitudeNS: NSNumber = document.get("destinationLatitude") as! NSNumber
                let destinationLatitude = destinationLatitudeNS.floatValue
                let destinationLongitudeNS: NSNumber = document.get("destinationLongitude") as! NSNumber
                let destinationLongitude = destinationLongitudeNS.floatValue
                let customerName: String = document.get("customerName") as! String
                let customerPhoneNumber: String = document.get("customerPhoneNumber") as! String
                let status: String = document.get("status") as! String
                let trip = Trip(id: document.documentID, distance: distance, money:money, originName: originName, originAddress: originAddress, originLatitude: originLatitude, originLongitude: originLongitude, destinationName: destinationName, destinationAddress: destinationAddress, destinationLatitude: destinationLatitude, destinationLongitude: destinationLongitude, customerName: customerName, customerPhoneNumber: customerPhoneNumber, status: status)
                self.trips.append(trip)
                print(trip)
            }
        }
    }
}
