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
                print("trip accepted")
                self.timer?.invalidate()
                self.timer = nil
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
        self.dismiss(animated: true, completion: nil)
    }
}
