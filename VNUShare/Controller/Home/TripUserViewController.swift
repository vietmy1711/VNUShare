//
//  TripUserViewController.swift
//  VNUShare
//
//  Created by MM on 6/22/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import Firebase

class TripUserViewController: UIViewController {
    
    var trip: Trip?
    
    let db = Firestore.firestore()
    
    var originMarker: GMSMarker?
    var destinationMarker: GMSMarker?
    var driverMarker: GMSMarker?
    
    var locationManager = CLLocationManager()
    
    var firstTime = true
    
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
    
    let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let vwSeperator: UIView = {
        let vw = UIView()
        vw.backgroundColor = .systemGray6
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    let btnStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let imvDriverAvatar: UIImageView = {
        let imv = UIImageView()
        imv.layer.masksToBounds = true
        imv.contentMode = .scaleAspectFill
        imv.layer.cornerRadius = 25
        imv.backgroundColor = .systemGray6
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    let lblDriverName: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        lbl.font = UIFont(name: "Helvetica", size: 17)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let lblDriverPhoneNumber: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        lbl.font = UIFont(name: "Helvetica", size: 17)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let btnCall: UIButton = {
        let btn = UIButton()
        btn.setTitle("Gọi", for: .normal)
        btn.titleLabel?.font = UIFont(name: "Helvetica", size: 17)
        btn.setTitleColor(.systemPink, for: .normal)
        btn.addTarget(self, action: #selector(callBtnClicked), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let btnMessage: UIButton = {
        let btn = UIButton()
        btn.setTitle("Nhắn tin", for: .normal)
        btn.titleLabel?.font = UIFont(name: "Helvetica", size: 17)
        btn.setTitleColor(.systemPink, for: .normal)
        btn.addTarget(self, action: #selector(messageBtnClicked), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let btnCancel: UIButton = {
        let btn = UIButton()
        btn.setTitle("Hủy chuyến", for: .normal)
        btn.titleLabel?.font = UIFont(name: "Helvetica", size: 17)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 2
        btn.addTarget(self, action: #selector(cancelBtnClicked), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDriver()
        setupUI()
        listenForStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func loadView() {
        super.loadView()
        checkLocation()
        setupMap()
        getDriverPosition()
    }
    
    func setupUI() {
        view.addSubview(vwContainer)
        
        vwContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        vwContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        vwContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        vwContainer.addSubview(imvDriverAvatar)
        vwContainer.addSubview(verticalStackView)
        
        imvDriverAvatar.topAnchor.constraint(equalTo: vwContainer.topAnchor, constant: 24).isActive = true
        imvDriverAvatar.leftAnchor.constraint(equalTo: vwContainer.leftAnchor, constant: 24).isActive = true
        imvDriverAvatar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imvDriverAvatar.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        verticalStackView.topAnchor.constraint(equalTo: vwContainer.topAnchor, constant: 30).isActive = true
        verticalStackView.leftAnchor.constraint(equalTo: imvDriverAvatar.rightAnchor, constant: 24).isActive = true
        verticalStackView.rightAnchor.constraint(equalTo: vwContainer.rightAnchor, constant: -24).isActive = true
        
        verticalStackView.addArrangedSubview(lblDriverName)
        verticalStackView.addArrangedSubview(lblDriverPhoneNumber)
        
        view.addSubview(vwSeperator)
        
        vwSeperator.topAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 20).isActive = true
        vwSeperator.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        vwSeperator.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        vwSeperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        vwContainer.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: vwSeperator.bottomAnchor, constant: 10).isActive = true
        stackView.bottomAnchor.constraint(equalTo: vwContainer.bottomAnchor, constant: -10).isActive = true
        stackView.leftAnchor.constraint(equalTo: vwContainer.leftAnchor, constant: 10).isActive = true
        stackView.rightAnchor.constraint(equalTo: vwContainer.rightAnchor, constant: -10).isActive = true
        
        stackView.addArrangedSubview(btnStackView)
        
        btnStackView.addArrangedSubview(btnCall)
        btnStackView.addArrangedSubview(btnMessage)
        
        stackView.addArrangedSubview(btnCancel)
        
        btnCancel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func checkLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways  {
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func getDriver() {
        db.collection("users").document(trip!.driverId!).getDocument { (document, error) in
            if let error = error {
                print(error)
            } else {
                if let document = document {
                    let avatarData = document.get("avatar")
                    self.imvDriverAvatar.image = UIImage(data: avatarData as! Data)
                    self.lblDriverName.text = self.trip!.customerName
                    self.lblDriverPhoneNumber.text = self.trip!.customerPhoneNumber
                }
            }
        }
    }
    
    func getDriverPosition() {
        db.collection("users").document((trip?.driverId)!)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                let latNS: NSNumber = document.get("lat") as! NSNumber
                let lonNS: NSNumber = document.get("lon") as! NSNumber
                let lat = latNS.floatValue
                let lon = lonNS.floatValue
                let position = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(lon))
                self.driverMarker?.map = nil
                self.driverMarker = GMSMarker(position: position)
                self.driverMarker?.icon = UIImage(named: "img_driver")
                self.driverMarker?.map = self.mapView
                self.driverMarker?.title = "Tài xế"
                self.setupMarker()
                self.drawRoute(self.driverMarker!.position, self.originMarker!.position)
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
        let origin = CLLocationCoordinate2DMake(CLLocationDegrees(trip!.originLatitude), CLLocationDegrees(trip!.originLongitude))
        let destination = CLLocationCoordinate2DMake(CLLocationDegrees(trip!.destinationLatitude), CLLocationDegrees(trip!.destinationLongitude))
        originMarker = GMSMarker(position: origin)
        originMarker?.icon = GMSMarker.markerImage(with: .systemBlue)
        originMarker?.appearAnimation = .pop
        originMarker?.title = trip?.originName
        originMarker?.snippet = trip?.originAddress
        originMarker?.map = mapView
        destinationMarker = GMSMarker(position: destination)
        destinationMarker?.map = mapView
        destinationMarker?.icon = GMSMarker.markerImage(with: .systemPink)
        destinationMarker?.appearAnimation = .pop
        destinationMarker?.title = trip?.destinationName
        destinationMarker?.snippet = trip?.destinationAddress
    }
    
    func drawRoute(_ originCoordinate: CLLocationCoordinate2D, _ destinationCoordinate: CLLocationCoordinate2D) {
        let origin = "\(originCoordinate.latitude),\(originCoordinate.longitude)"
        let destination = "\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)"
        let apiKey = API().APIKey
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(apiKey)"
        
        AF.request(url).responseJSON { response in
            do {
                let json = try JSON(data: response.data!)
                let routes = json["routes"].arrayValue
                for route in routes
                {
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    let points = routeOverviewPolyline?["points"]?.stringValue
                    let path = GMSPath.init(fromEncodedPath: points!)
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeColor = .systemGreen
                    polyline.strokeWidth = 10.0
                    polyline.map = self.mapView
                }
                if self.firstTime == true {
                    let bounds: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: originCoordinate, coordinate: destinationCoordinate)
                    bounds.includingCoordinate(self.driverMarker!.position)
                    self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 20.0))
                    self.firstTime = false
                }
            }
            catch {
                print(error)
            }
        }
    }
    
    func listenForStatus() {
        db.collection("trips").document(trip!.id)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                let status = document.get("status") as! String
                
                if status == "arrived" {
                    let alert = UIAlertController(title: "Tài xế đã đến", message: "Tài xế đã đến nơi và đang đợi bạn", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Xác nhận", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else if status == "going" {
                    self.btnCancel.isEnabled = false
                } else if status == "finished" {
                    self.navigationController?.popToRootViewController(animated: true)
                    return
                }
        }
    }
    
    @objc func callBtnClicked() {
        guard let number = URL(string: "tel://" + trip!.driverPhoneNumber!) else { return }
        UIApplication.shared.open(number)
    }
    
    @objc func messageBtnClicked() {
        
    }
    
    @objc func cancelBtnClicked() {
        let alert = UIAlertController(title: "Hủy chuyến", message: "Bạn có chắc chắn muốn hủy chuyến?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Xác nhận", style: .destructive, handler: { (_) in
            self.db.collection("trips").document(self.trip!.id).updateData([
                "status": "canceled"
            ]) { (error) in
                if let error = error {
                    print(error)
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Trở về", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

