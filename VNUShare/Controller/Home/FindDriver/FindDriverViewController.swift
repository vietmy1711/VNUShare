//
//  FindDriverViewController.swift
//  VNUShare
//
//  Created by MM on 6/21/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase

protocol FindDriverViewControllerDelegate {
    func didCancelFindingDriver()
}

class FindDriverViewController: UIViewController {
    
    var delegate: FindDriverViewControllerDelegate?
    
    let db = Firestore.firestore()
    
    var user: User?
    
    var tripId: String?
    
    var timer: Timer?
    var isTimerStillRunning = true
    
    let lblStatus: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "Helvetica", size: 17)
        lbl.textAlignment = .center
        lbl.text = "Đang tìm tài xế cho bạn"
        lbl.textColor = .black
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let btnCancel: UIButton = {
        let btn = UIButton()
        btn.setTitle("Hủy", for: .normal)
        btn.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 17)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemPink
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let indicatorView: NVActivityIndicatorView = {
        let indicatorView = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .systemPink, padding: 0)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setTimer()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(lblStatus)
        view.addSubview(indicatorView)
        view.addSubview(btnCancel)
        
        lblStatus.bottomAnchor.constraint(equalTo: indicatorView.topAnchor, constant: -20).isActive = true
        lblStatus.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        lblStatus.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        
        btnCancel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        btnCancel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        btnCancel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        btnCancel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        indicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        indicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        indicatorView.startAnimating()
    }
    
    func setTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(failToFindDriver), userInfo: nil, repeats: false)
        db.collection("trips").document(tripId!)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let status: String = document.get("status") as? String else {
                    print("Document data was empty.")
                    return
                }
                if status == "accepted" {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.lblStatus.text = "Đã tìm đc tài xế cho bạn"
                    self.isTimerStillRunning = false
                    self.btnCancel.isEnabled = false
                    self.btnCancel.alpha = 0.5
                    self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.foundDriver), userInfo: nil, repeats: false)
                }
        }
    }
    
    
    @objc func foundDriver() {
        indicatorView.stopAnimating()
        db.collection("trips").document(tripId!).getDocument { (document, error) in
            if let error = error {
                print(error)
                return
            } else {
                if let document = document {
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
                    let tripUserVC = TripUserViewController()
                    tripUserVC.trip = trip
                    tripUserVC.user = self.user
                    self.navigationController?.pushViewController(tripUserVC, animated: true)
                }
            }
        }
        
    }
    
    @objc func failToFindDriver() {
        delegate?.didCancelFindingDriver()
        lblStatus.text = "Hiện tại cuộc sống của các tài xế hơi bộn bề, xin hãy thử lại sau"
        isTimerStillRunning = false
        indicatorView.stopAnimating()
    }
    
    @objc func cancelButtonPressed() {
        if isTimerStillRunning {
            delegate?.didCancelFindingDriver()
        }
        indicatorView.stopAnimating()
        navigationController?.popViewController(animated: true)
    }
}
