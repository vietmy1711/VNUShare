//
//  HistoryViewController.swift
//  VNUShare
//
//  Created by MM on 6/20/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import Firebase

class HistoryViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    var user: User?
    
    var trips: [Trip] = []
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl.didMoveToSuperview()
        tableView.addSubview(refreshControl)
        tableView.register(UINib(nibName: "TripTableViewCell", bundle: nil), forCellReuseIdentifier: "TripTableViewCell")
        getTrips()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        
    }
    
    func getTrips() {
        db.collection("users").document(user!.uid).getDocument { (document, error) in
            if let error = error {
                print(error)
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                return
            } else if let document = document {
                self.trips.removeAll()
                let completeds = document.get("completed") as! [String]
                for completed in completeds {
                    self.db.collection("trips").document(completed).getDocument { (document, error) in
                        if let error = error {
                            print(error)
                            return
                        } else if let document = document {
                            let distanceNS: NSNumber = document.get("distance") as! NSNumber
                            let distance = distanceNS.intValue
                            let durationNS: NSNumber = document.get("duration") as! NSNumber
                            let duration = durationNS.intValue
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
                            let customerId: String = document.get("customerId") as! String
                            let customerName: String = document.get("customerName") as! String
                            let customerPhoneNumber: String = document.get("customerPhoneNumber") as! String
                            let driverId: String = document.get("driverId") as! String
                            let driverName: String = document.get("driverName") as! String
                            let driverPhoneNumber: String = document.get("driverPhoneNumber") as! String
                            let status: String = document.get("status") as! String
                            let trip = Trip(id: document.documentID, distance: distance, duration: duration, money:money, originName: originName, originAddress: originAddress, originLatitude: originLatitude, originLongitude: originLongitude, destinationName: destinationName, destinationAddress: destinationAddress, destinationLatitude: destinationLatitude, destinationLongitude: destinationLongitude, customerId: customerId, customerName: customerName, customerPhoneNumber: customerPhoneNumber, driverId: driverId, driverName: driverName, driverPhoneNumber: driverPhoneNumber, status: status)
                            self.trips.append(trip)
                            self.tableView.reloadData()
                        }
                        if self.refreshControl.isRefreshing {
                            self.refreshControl.endRefreshing()
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func refreshData() {
        getTrips()
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripTableViewCell", for: indexPath) as! TripTableViewCell
        cell.configWithTrip(trip: trips[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}


