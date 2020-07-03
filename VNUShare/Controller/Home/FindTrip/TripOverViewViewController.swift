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
import Alamofire
import SwiftyJSON

protocol TripOverViewViewControllerDelegate {
    func didNotAcceptTrip(trip: Trip)
}

class TripOverViewViewController: UIViewController {
    
    var trip: Trip?
    
    var user: User?
    
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
        getUser()
        setupUI()
    }
    
    override func loadView() {
        super.loadView()
        checkLocation()
        setupMap()
        setupMarker()
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
        let origin = CLLocationCoordinate2DMake(CLLocationDegrees(trip!.originLatitude), CLLocationDegrees(trip!.originLongitude))
        let destination = CLLocationCoordinate2DMake(CLLocationDegrees(trip!.destinationLatitude), CLLocationDegrees(trip!.destinationLongitude))
        originMarker = GMSMarker(position: origin)
        originMarker?.map = mapView
        destinationMarker = GMSMarker(position: destination)
        destinationMarker?.map = mapView
        drawRoute(origin, destination)
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
                    polyline.strokeColor = .systemBlue
                    polyline.strokeWidth = 10.0
                    polyline.map = self.mapView
                }
                let bounds: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: originCoordinate, coordinate: destinationCoordinate)
                self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 20.0))
            }
            catch {
                print(error)
            }
        }
    }
    
    func getUser() {
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if document!.exists {
                let uid = Auth.auth().currentUser!.uid
                let email: String = document!.get("email") as! String
                let fullname: String = document!.get("fullname") as! String
                let phonenumber: String = document!.get("phonenumber") as! String
                let role: String = document!.get("role") as! String
                let pointsNS: NSNumber = document!.get("points") as! NSNumber
                let points: Int = pointsNS.intValue
                self.user = User(uid: uid,email: email, fullname: fullname, phonenumber: phonenumber, role: role, points: points)
            } else {
                print("not exist")
            }
        }
    }
    
    @objc func acceptBtnClicked() {
        db.collection("trips").document(trip!.id).getDocument { (document, error) in
            if let error = error {
                print(error)
            }
            if let document = document, document.exists {
                let status: String = document.get("status") as! String
                if status != "accepted", let user = self.user {
                    self.db.collection("trips").document(document.documentID).updateData(
                        [
                            "driverId": user.uid,
                            "driverName": user.fullname,
                            "driverPhoneNumber": user.phonenumber,
                            "status": "accepted"
                    ]) { (error) in
                        if let error = error {
                            print(error)
                        } else {
                            self.trip?.driverId = user.uid
                            self.trip?.driverName = user.fullname
                            self.trip?.driverPhoneNumber = user.phonenumber
                            self.trip?.status = "accepted"
                            let tripDriverVC = TripDriverViewController()
                            tripDriverVC.trip = self.trip
                            self.navigationController?.pushViewController(tripDriverVC, animated: true)
                        }
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
