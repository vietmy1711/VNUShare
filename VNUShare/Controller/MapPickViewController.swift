//
//  MapPickViewController.swift
//  VNUShare
//
//  Created by MM on 5/25/20.
//  Copyright © 2020 MM. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON
import Firebase

class MapPickViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    var user: User?
    
    var createdId: String?
    
    var locationManager = CLLocationManager()
    
    var placesClient = GMSPlacesClient()
    var resultsViewController = GMSAutocompleteResultsViewController()
    
    var lat: Double = 0
    var lon: Double = 0
    
    var totalDistance: Int = 0
    var totalMoney: Int = 0
    
    var sourceMarker: GMSMarker?
    var sourcePlace: Place?
    
    var destinationMarker: GMSMarker?
    var destinationPlace: Place?
    
    let vwContainer: UIView = {
        let vw = UIView()
        vw.layer.cornerRadius = 10
        vw.layer.shadowColor = UIColor.black.cgColor
        vw.layer.shadowOpacity = 0.2
        vw.layer.shadowOffset = .zero
        vw.layer.shadowRadius = 0.8
        vw.backgroundColor = .white
        //vw.backgroundColor = UIColor(red: 246/255, green: 248/255, blue: 251/255, alpha: 1)
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    let lblDistance: UILabel = {
        let lbl = UILabel()
        lbl.text = "   Khoảng cách: "
        lbl.font = UIFont(name: "Helvetica", size: 17)
        lbl.textColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let lblDuration: UILabel = {
        let lbl = UILabel()
        lbl.text = "   Thời gian: "
        lbl.font = UIFont(name: "Helvetica", size: 17)
        lbl.textColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let lblMoney: UILabel = {
        let lbl = UILabel()
        lbl.text = "   Thành tiền: "
        lbl.font = UIFont(name: "Helvetica", size: 17)
        lbl.textColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let stackViewBtn: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let vwCurrent: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    let imvCurrent: UIImageView = {
        let imv = UIImageView()
        imv.image = UIImage(systemName: "location")
        imv.tintColor = .gray
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    let vwToGo: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    let imvToGo: UIImageView = {
        let imv = UIImageView()
        imv.image = UIImage(systemName: "car")
        imv.tintColor = .gray
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    let btnConfirm: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .systemPink
        btn.layer.cornerRadius = 10
        btn.setTitle("Đặt", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 17)
        btn.addTarget(self, action: #selector(confirmButtonClicked), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let btnCancel: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 2
        btn.setTitle("Hủy", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 17)
        btn.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let txfCurrent: UITextField = {
        let txf = UITextField()
        txf.backgroundColor = .white
        txf.font = UIFont(name: "Helvetica", size: 17)
        txf.textColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        txf.placeholder = "Vị trí hiện tại"
        txf.clearButtonMode = .whileEditing
        txf.spellCheckingType = .no
        txf.addTarget(self, action: #selector(autocompleteClicked(_:)), for: .touchDown)
        txf.translatesAutoresizingMaskIntoConstraints = false
        return txf
    }()
    
    let txfToGo: UITextField = {
        let txf = UITextField()
        txf.backgroundColor = .white
        txf.textColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        txf.font = UIFont(name: "Helvetica", size: 17)
        txf.placeholder = "Nơi cần đến"
        txf.clearButtonMode = .whileEditing
        txf.spellCheckingType = .no
        txf.addTarget(self, action: #selector(autocompleteClicked(_:)), for: .touchDown)
        txf.translatesAutoresizingMaskIntoConstraints = false
        return txf
    }()
    
    let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var mapView: GMSMapView = {
        var mapView = GMSMapView()
        mapView.isMyLocationEnabled = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        placesClient = GMSPlacesClient.shared()
        setupUI()
    }
    
    override func loadView() {
        super.loadView()
        mapView.delegate = self
        locationManager.delegate = self
        checkLocation()
        getUserLocation()
        getCurrentPlaceName()
        setupMap()
        locationManager.requestLocation()
    }
    
    func setupUI() {
        
        view.addSubview(vwContainer)
        
        vwContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6).isActive = true
        vwContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 6).isActive = true
        vwContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -6).isActive = true
        vwContainer.addSubview(verticalStackView)
        
        verticalStackView.topAnchor.constraint(equalTo: vwContainer.topAnchor, constant: 10).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: vwContainer.bottomAnchor, constant: -10).isActive = true
        verticalStackView.leftAnchor.constraint(equalTo: vwContainer.leftAnchor, constant: 10).isActive = true
        verticalStackView.rightAnchor.constraint(equalTo: vwContainer.rightAnchor, constant: -10).isActive = true
        
        verticalStackView.addArrangedSubview(lblDistance)
        verticalStackView.addArrangedSubview(lblDuration)
        verticalStackView.addArrangedSubview(lblMoney)
        verticalStackView.addArrangedSubview(vwCurrent)
        verticalStackView.addArrangedSubview(vwToGo)
        verticalStackView.addArrangedSubview(stackViewBtn)
        
        stackViewBtn.addArrangedSubview(btnCancel)
        stackViewBtn.addArrangedSubview(btnConfirm)
        
        vwCurrent.addSubview(imvCurrent)
        vwCurrent.addSubview(txfCurrent)
        
        vwCurrent.heightAnchor.constraint(equalToConstant: 40).isActive = true
        vwToGo.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnConfirm.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnCancel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        imvCurrent.topAnchor.constraint(equalTo: vwCurrent.topAnchor, constant: 10).isActive = true
        imvCurrent.bottomAnchor.constraint(equalTo: vwCurrent.bottomAnchor, constant: -10).isActive = true
        imvCurrent.leftAnchor.constraint(equalTo: vwCurrent.leftAnchor, constant: 10).isActive = true
        imvCurrent.rightAnchor.constraint(equalTo: txfCurrent.leftAnchor, constant: -16).isActive = true
        
        imvCurrent.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imvCurrent.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        txfCurrent.topAnchor.constraint(equalTo: vwCurrent.topAnchor, constant: 0).isActive = true
        txfCurrent.bottomAnchor.constraint(equalTo: vwCurrent.bottomAnchor, constant: 0).isActive = true
        txfCurrent.rightAnchor.constraint(equalTo: vwCurrent.rightAnchor, constant: 0).isActive = true
        
        vwToGo.addSubview(imvToGo)
        vwToGo.addSubview(txfToGo)
        
        imvToGo.topAnchor.constraint(equalTo: vwToGo.topAnchor, constant: 10).isActive = true
        imvToGo.bottomAnchor.constraint(equalTo: vwToGo.bottomAnchor, constant: -10).isActive = true
        imvToGo.leftAnchor.constraint(equalTo: vwToGo.leftAnchor, constant: 10).isActive = true
        imvToGo.rightAnchor.constraint(equalTo: txfToGo.leftAnchor, constant: -16).isActive = true
        
        imvToGo.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imvToGo.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        txfToGo.topAnchor.constraint(equalTo: vwToGo.topAnchor, constant: 0).isActive = true
        txfToGo.bottomAnchor.constraint(equalTo: vwToGo.bottomAnchor, constant: 0).isActive = true
        txfToGo.rightAnchor.constraint(equalTo: vwToGo.rightAnchor, constant: 0).isActive = true
        
    }
    
    func getCurrentPlaceName() {
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
            (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            if let currentPlace = placeLikelihoodList?.last?.place {
                let name = currentPlace.name ?? "No name"
                let address = currentPlace.formattedAddress ?? "No address"
                let coordinate = currentPlace.coordinate
                let current = Place(name: name, address: address, coordinate: coordinate)
                self.setCurrentWithPlace(place: current)
            }
        })
    }
    
    func getUserLocation() {
        locationManager.desiredAccuracy = .greatestFiniteMagnitude
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = 1
    }
    
    func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 16)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        self.view.addSubview(mapView)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
    }
    
    // Present the Autocomplete view controller when the button is pressed.
    @objc func autocompleteClicked(_ sender: UITextField) {
        let autocompleteController = SearchMapViewController()
        if sender == txfToGo {
            autocompleteController.toGo = true
        }
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @objc func confirmButtonClicked() {
        
        if let destination = destinationPlace, let source = sourcePlace {
            var ref: DocumentReference? = nil
            
            ref = db.collection("trips").addDocument (data: [
                "distance": totalDistance,
                "money": totalMoney,
                "time": Date().timeIntervalSince1970,
                "originName": source.name,
                "originAddress": source.address,
                "originLatitude": source.coordinate.latitude,
                "originLongitude": source.coordinate.longitude,
                "destinationName": destination.name,
                "destinationAddress": destination.address,
                "destinationLatitude": destination.coordinate.latitude,
                "destinationLongitude": destination.coordinate.longitude,
                "customerId": user!.uid,
                "customerName": user!.fullname,
                "customerPhoneNumber": user!.phonenumber,
                "status": "waiting"
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    self.createdId = ref!.documentID
                    let findDriverVC = FindDriverViewController()
                    findDriverVC.modalPresentationStyle = .fullScreen
                    findDriverVC.delegate = self
                    self.present(findDriverVC, animated: true) {
                        
                    }
                }
            }
        }
    }
    
    @objc func cancelButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways  {
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func setToGoWithPlace(place: Place) {
        txfToGo.text = place.name
        destinationPlace = place
        mapView.clear()
        destinationMarker = GMSMarker(position: place.coordinate)
        destinationMarker?.icon = GMSMarker.markerImage(with: .systemPink)
        destinationMarker?.appearAnimation = .pop
        destinationMarker?.title = place.name
        destinationMarker?.snippet = place.address
        destinationMarker?.map = mapView
        mapView.animate(toLocation: destinationPlace!.coordinate)
        if var origin = sourcePlace {
            if origin.coordinate.latitude == -180 && origin.coordinate.longitude == -180 {
                origin.coordinate = CLLocationCoordinate2DMake(lat, lon)
                sourcePlace!.coordinate = CLLocationCoordinate2DMake(lat, lon)
            }
            sourceMarker = GMSMarker(position: origin.coordinate)
            sourceMarker?.icon = GMSMarker.markerImage(with: .blue)
            sourceMarker?.appearAnimation = .pop
            sourceMarker?.title = origin.name
            sourceMarker?.snippet = origin.address
            sourceMarker?.map = mapView
            drawRoute(origin, destinationPlace!)
        }
    }
    
    func setCurrentWithPlace(place: Place) {
        txfCurrent.text = place.name
        sourcePlace = place
        mapView.clear()
        sourceMarker = GMSMarker(position: place.coordinate)
        sourceMarker?.icon = GMSMarker.markerImage(with: .blue)
        sourceMarker?.appearAnimation = .pop
        sourceMarker?.title = place.name
        sourceMarker?.snippet = place.address
        sourceMarker?.map = mapView
        mapView.animate(toLocation: sourcePlace!.coordinate)
        if let destination = destinationPlace {
            destinationMarker = GMSMarker(position: destination.coordinate)
            destinationMarker?.icon = GMSMarker.markerImage(with: .systemPink)
            destinationMarker?.appearAnimation = .pop
            destinationMarker?.title = destination.name
            destinationMarker?.snippet = destination.address
            destinationMarker?.map = mapView
            drawRoute(sourcePlace!, destination)
        }
    }
    
    func calculate(distance: Int, duration: Int) {
        totalDistance = distance
        totalMoney = distance/1000 * 3000
        lblDistance.text = "   Khoảng cách: ~\(Float(totalDistance)/1000) km"
        lblDuration.text = "   Thời gian: ~\((duration)/60) phút"
        lblMoney.text = "   Thành tiền: \(totalMoney) VND"
    }
    
    func drawRoute(_ originPlace: Place, _ destinationPlace: Place) {
        let origin = "\(originPlace.coordinate.latitude),\(originPlace.coordinate.longitude)"
        let destination = "\(destinationPlace.coordinate.latitude),\(destinationPlace.coordinate.longitude)"
        let apiKey = API().APIKey
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(apiKey)"
        
        AF.request(url).responseJSON { response in
            do {
                let json = try JSON(data: response.data!)
                let routes = json["routes"].arrayValue
                var distance: Int = 0 //1000 distance = 1km
                var duration: Int = 0 //1 duration = 1 second
                for route in routes
                {
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    let points = routeOverviewPolyline?["points"]?.stringValue
                    let path = GMSPath.init(fromEncodedPath: points!)
                    
                    let legs = route["legs"].arrayValue
                    for leg in legs {
                        let distanceJSON = leg["distance"].dictionary
                        distance += (distanceJSON?["value"]!.intValue)!
                        let durationJSON = leg["duration"].dictionary
                        duration += (durationJSON?["value"]!.intValue)!
                    }
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeColor = .systemBlue
                    polyline.strokeWidth = 10.0
                    polyline.map = self.mapView
                }
                self.calculate(distance: distance, duration: duration)
            }
            catch {
                print(error)
            }
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension MapPickViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            lat = location.coordinate.latitude
            lon = location.coordinate.longitude
            mapView.animate(toLocation: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }
        else {
            print("No location")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did fail with error: \(error)")
    }
}

//MARK: - SearchMapViewControllerDelegate

extension MapPickViewController: SearchMapViewControllerDelegate {
    
    func didUpdateWithPlace(place: Place, toGo: Bool) {
        if toGo == true {
            setToGoWithPlace(place: place)
        } else {
            setCurrentWithPlace(place: place)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

extension MapPickViewController: FindDriverViewControllerDelegate {
    func didFoundDriver() {
        
    }
    
    func didCancelFindingDriver() {
        if let createdId = createdId {
            db.collection("trips").document(createdId).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
    }
}

extension MapPickViewController: GMSMapViewDelegate {
    
}
