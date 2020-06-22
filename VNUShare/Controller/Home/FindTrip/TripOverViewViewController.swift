//
//  TripOverViewViewController.swift
//  VNUShare
//
//  Created by MM on 6/22/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

protocol TripOverViewViewControllerDelegate {
    func didNotAcceptTrip(trip: Trip)
}

class TripOverViewViewController: UIViewController {

    var trip: Trip?
    
    var delegate: TripOverViewViewControllerDelegate?
    
    let db = Firestore.firestore()

    var originMarker: GMSMarker?
    var destinationMarker: GMSMarker?
    
    var locationManager = CLLocationManager()
    
    var mapView: GMSMapView = {
        var mapView = GMSMapView()
        mapView.isMyLocationEnabled = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    let vwContainer: UIView = {
        let vw = UIView()
        vw.backgroundColor = .white
        vw.layer.cornerRadius = 8
        vw.layer.shadowColor = UIColor.black.cgColor
        vw.layer.shadowOffset = CGSize(width: 0, height: 4)
        vw.layer.shadowRadius = 2
        vw.layer.shadowOpacity = 0.1
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let btnAccept: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 17)
        btn.setTitle("Nhận cuốc", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemPink
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(acceptBtnClicked), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let btnBack: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 17)
        btn.setTitle("Trở về", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 2
        btn.addTarget(self, action: #selector(backBtnClicked), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
        setupUI()
        setupMarker()
    }
    
    override func loadView() {
        super.loadView()
        checkLocation()
        setupMap()
    }
    
    func setupUI() {
        view.addSubview(vwContainer)
        vwContainer.addSubview(stackView)
        
        vwContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        vwContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        vwContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        stackView.topAnchor.constraint(equalTo: vwContainer.topAnchor, constant: 10).isActive = true
        stackView.bottomAnchor.constraint(equalTo: vwContainer.bottomAnchor, constant: -10).isActive = true
        stackView.leftAnchor.constraint(equalTo: vwContainer.leftAnchor, constant: 10).isActive = true
        stackView.rightAnchor.constraint(equalTo: vwContainer.rightAnchor, constant: -10).isActive = true

        stackView.addArrangedSubview(btnAccept)
        stackView.addArrangedSubview(btnBack)
        
        btnAccept.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnBack.heightAnchor.constraint(equalToConstant: 40).isActive = true

    }
    
    func checkLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways  {
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 16)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        self.view.addSubview(mapView)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
    
    func setupMarker() {
        
    }
    
    @objc func acceptBtnClicked() {
        db.collection("trips").document(trip!.id).getDocument { (document, error) in
            if let error = error {
                print(error)
            }
            if let document = document, document.exists {
                let status: String = document.get("status") as! String
                if status != "accepted" {
                    self.db.collection("trips").document(document.documentID).updateData(["status": "accepted"]) { (error) in
                        if let error = error {
                            print(error)
                        }
                        let tripDriverVC = TripDriverViewController()
                        self.navigationController?.pushViewController(tripDriverVC, animated: true)
                    }
                } else { //someone has accepted it
                    let alert = UIAlertController(title: "Rất tiếc", message: "Đã có người nhận cuốc này rồi, thử lại sau nha!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Đồng ý", style: .default, handler: { (_) in
                        self.delegate?.didNotAcceptTrip(trip: self.trip!)
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc func backBtnClicked() {
        delegate?.didNotAcceptTrip(trip: trip!)
        navigationController?.popViewController(animated: true)
    }
}
