//
//  TripDriverViewController.swift
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

class TripDriverViewController: UIViewController {
    
    var trip: Trip?
    
    let db = Firestore.firestore()
    
    var originMarker: GMSMarker?
    var destinationMarker: GMSMarker?
    
    var locationManager = CLLocationManager()
    
    var currentLocation: CLLocationCoordinate2D?
    
    var firstTime = true
    var state = "accepted"
    
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
    
    let imvCustomerAvatar: UIImageView = {
        let imv = UIImageView()
        imv.layer.masksToBounds = true
        imv.contentMode = .scaleAspectFill
        imv.layer.cornerRadius = 25
        imv.backgroundColor = .systemGray6
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    let lblCustomerName: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        lbl.font = UIFont(name: "Helvetica", size: 17)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let lblCustomerPhoneNumber: UILabel = {
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
    
    let btnChangeState: UIButton = {
        let btn = UIButton()
        btn.setTitle("Đợi khách", for: .normal)
        btn.titleLabel?.font = UIFont(name: "Helvetica", size: 17)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemPink
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(changeStateBtnClicked), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        getCustomer()
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
        setupMarker()
    }
    
    func setupUI() {
        view.addSubview(vwContainer)
        
        vwContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        vwContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        vwContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        vwContainer.addSubview(imvCustomerAvatar)
        vwContainer.addSubview(verticalStackView)
        
        imvCustomerAvatar.topAnchor.constraint(equalTo: vwContainer.topAnchor, constant: 24).isActive = true
        imvCustomerAvatar.leftAnchor.constraint(equalTo: vwContainer.leftAnchor, constant: 24).isActive = true
        imvCustomerAvatar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imvCustomerAvatar.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        verticalStackView.topAnchor.constraint(equalTo: vwContainer.topAnchor, constant: 30).isActive = true
        verticalStackView.leftAnchor.constraint(equalTo: imvCustomerAvatar.rightAnchor, constant: 24).isActive = true
        verticalStackView.rightAnchor.constraint(equalTo: vwContainer.rightAnchor, constant: -24).isActive = true
        
        verticalStackView.addArrangedSubview(lblCustomerName)
        verticalStackView.addArrangedSubview(lblCustomerPhoneNumber)
        
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
        
        stackView.addArrangedSubview(btnChangeState)
        
        btnChangeState.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func getCustomer() {
        db.collection("users").document(trip!.customerId).getDocument { (document, error) in
            if let error = error {
                print(error)
            } else {
                if let document = document {
                    let avatarData = document.get("avatar")
                    self.imvCustomerAvatar.image = UIImage(data: avatarData as! Data)
                    self.lblCustomerName.text = self.trip!.customerName
                    self.lblCustomerPhoneNumber.text = self.trip!.customerPhoneNumber
                }
            }
        }
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
        mapView.clear()
        setupMarker()
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
                    let bounds: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: originCoordinate, coordinate: self.mapView.myLocation!.coordinate)
                    self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 20.0))
                    self.firstTime = false
                }
            }
            catch {
                print(error)
            }
        }
    }
    
    func drawWithState() {
        switch self.state {
        case "accepted":
            let origin = CLLocationCoordinate2DMake(CLLocationDegrees(trip!.originLatitude), CLLocationDegrees(trip!.originLongitude))
            drawRoute(currentLocation!, origin)
        case "finished":
            mapView.clear()
        default:
            let destination = CLLocationCoordinate2DMake(CLLocationDegrees(trip!.destinationLatitude), CLLocationDegrees(trip!.destinationLongitude))
            drawRoute(currentLocation!, destination)
        }
    }
    
    @objc func callBtnClicked() {
        guard let number = URL(string: "tel://" + trip!.customerPhoneNumber) else { return }
        UIApplication.shared.open(number)
    }
    
    @objc func messageBtnClicked() {
        
    }
    
    @objc func changeStateBtnClicked() {
        btnChangeState.isEnabled = false
        switch state {
        case "accepted":
            btnChangeState.setTitle("Đón khách", for: .normal)
            setState(state: "arrived")
        case "arrived":
            btnChangeState.setTitle("Trả khách", for: .normal)
            setState(state: "going")
        default:
            setState(state: "finished")
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
                if status == "finished" {
                    self.navigationController?.popToRootViewController(animated: true)
                    return
                }
                if status == "canceled" {
                    let alert = UIAlertController(title: "Hủy chuyến", message: "Khách hàng vừa hủy chuyến", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Xác nhận", style: .default, handler: { (_) in
                        self.navigationController?.popToRootViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
    
    func setState(state: String) {
        db.collection("trips").document(trip!.id).updateData([
            "status": state
        ]) { (error) in
            if let error = error {
                print(error)
            }
            self.state = state
            self.btnChangeState.isEnabled = true
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension TripDriverViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            currentLocation = CLLocationCoordinate2DMake(lat, lon)
            mapView.animate(toLocation: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            if let locationFromMap = mapView.myLocation {
                db.collection("users").document(Auth.auth().currentUser!.uid).updateData(
                    [
                        "lat": locationFromMap.coordinate.latitude,
                        "lon": locationFromMap.coordinate.longitude,
                        "course": locationFromMap.course
                        
                ]) { err in
                    if let err = err {
                        print(err)
                    } else {
                        self.drawWithState()
                    }
                }
            }
        }
        else {
            print("No location")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did fail with error: \(error)")
    }
}
